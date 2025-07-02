//
//  AppModel.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
@MainActor
class AppModel {
    static let shared = AppModel()
    
    var applications: [Application] = []
    var shortcuts: [Shortcut] = []
    var selectedApplication: Application?
    var selectedShortcut: Shortcut?
    var selectedTag: String?
    var searchText = ""
    var isScanning = false
    var showSettingsWindow = false
    var showNewShortcutSheet = false
    var showCaptureWindow = false
    var hiddenApplications = Set<String>()
    
    var modelContext: ModelContext?
    private let appScanner = ApplicationScannerService.shared
    private let shortcutCapture = ShortcutCaptureService()
    private let accessibilityExtractor = AccessibilityShortcutExtractor()
    
    private init() {
        setupNotifications()
        loadHiddenApplications()
    }
    
    func setup(with context: ModelContext) {
        self.modelContext = context
        fetchData()
        
        if UserDefaults.standard.bool(forKey: "autoScanOnLaunch") && applications.isEmpty {
            Task {
                await scanForAllApplications()
            }
        }
    }
    
    // MARK: - Data Management
    
    func fetchData() {
        guard let context = modelContext else { return }
        
        let shortcutDescriptor = FetchDescriptor<Shortcut>()
        let appDescriptor = FetchDescriptor<Application>()
        
        do {
            shortcuts = try context.fetch(shortcutDescriptor)
            applications = try context.fetch(appDescriptor)
        } catch {
            print("Error fetching data: \(error)")
        }
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Application Management
    
    func scanForAllApplications() async {
        isScanning = true
        
        await appScanner.scanForApplications { [weak self] scannedApps in
            guard let self = self, let context = self.modelContext else { return }
            
            for scannedApp in scannedApps {
                if !self.applications.contains(where: { $0.bundleIdentifier == scannedApp.bundleIdentifier }) {
                    context.insert(scannedApp)
                }
            }
            
            self.saveContext()
            self.fetchData()
            self.isScanning = false
        }
    }
    
    func extractShortcutsFromRunningApp(_ app: Application) async {
        guard !app.bundleIdentifier.isEmpty else { return }
        
        let extractedShortcuts = await accessibilityExtractor.extractShortcuts(from: app.bundleIdentifier)
        
        for shortcutInfo in extractedShortcuts {
            // Check if shortcut already exists
            if !shortcuts.contains(where: { 
                $0.application == app && $0.keyCombination == shortcutInfo.keyCombination 
            }) {
                let shortcut = Shortcut(
                    title: shortcutInfo.title,
                    keyCombination: shortcutInfo.keyCombination,
                    shortcutDescription: shortcutInfo.description,
                    category: shortcutInfo.category,
                    application: app
                )
                
                modelContext?.insert(shortcut)
            }
        }
        
        saveContext()
        fetchData()
    }
    
    // MARK: - Shortcut Management
    
    func addShortcut(
        title: String,
        keyCombination: String,
        description: String,
        category: String,
        application: Application?,
        tags: [String]
    ) {
        guard let context = modelContext else { return }
        
        let shortcut = Shortcut(
            title: title,
            keyCombination: keyCombination,
            shortcutDescription: description,
            category: category.isEmpty ? "General" : category,
            application: application,
            tags: tags
        )
        
        context.insert(shortcut)
        saveContext()
        fetchData()
    }
    
    func updateShortcut(_ shortcut: Shortcut) {
        shortcut.dateModified = Date()
        saveContext()
        fetchData()
    }
    
    func deleteShortcut(_ shortcut: Shortcut) {
        // Soft delete - move to bin
        shortcut.isDeleted = true
        shortcut.dateDeleted = Date()
        saveContext()
        fetchData()
    }
    
    func restoreShortcut(_ shortcut: Shortcut) {
        shortcut.isDeleted = false
        shortcut.dateDeleted = nil
        saveContext()
        fetchData()
    }
    
    func permanentlyDeleteShortcut(_ shortcut: Shortcut) {
        guard let context = modelContext else { return }
        context.delete(shortcut)
        saveContext()
        fetchData()
    }
    
    func duplicateShortcut(_ shortcut: Shortcut) {
        guard let context = modelContext else { return }
        
        let duplicated = Shortcut(
            title: "\(shortcut.title) Copy",
            keyCombination: shortcut.keyCombination,
            shortcutDescription: shortcut.shortcutDescription,
            category: shortcut.category,
            application: shortcut.application,
            tags: shortcut.tags
        )
        
        context.insert(duplicated)
        saveContext()
        fetchData()
    }
    
    func toggleFavorite(_ shortcut: Shortcut) {
        shortcut.isFavorite.toggle()
        saveContext()
        fetchData()
    }
    
    // MARK: - Computed Properties
    
    var filteredApplications: [Application] {
        let showSystemApps = UserDefaults.standard.bool(forKey: "showSystemApps")
        return applications
            .filter { app in
                (showSystemApps || !app.isSystemApp) && !hiddenApplications.contains(app.bundleIdentifier)
            }
            .sorted { $0.name < $1.name }
    }
    
    var filteredShortcuts: [Shortcut] {
        guard let app = selectedApplication else { return [] }
        
        var results = shortcuts.filter { $0.application == app }
        
        if !searchText.isEmpty {
            results = results.filter { shortcut in
                shortcut.searchableText.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return results.sorted { $0.title < $1.title }
    }
    
    var categories: [String] {
        var cats = Set<String>()
        cats.insert("All")
        shortcuts.forEach { cats.insert($0.category) }
        return Array(cats).sorted()
    }
    
    var allTags: [String] {
        var tags = Set<String>()
        shortcuts.forEach { shortcut in
            shortcut.tags.forEach { tags.insert($0) }
        }
        return Array(tags).sorted()
    }
    
    // MARK: - Utility Functions
    
    func copyShortcutToClipboard(_ shortcut: Shortcut) {
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        
        let shortcutText = "\(shortcut.title): \(shortcut.keyCombination)"
        pasteboard.setString(shortcutText, forType: .string)
    }
    
    func getApplicationInfo(_ app: Application) -> ApplicationInfo {
        return appScanner.getApplicationInfo(for: app)
    }
    
    func openApplicationInFinder(_ app: Application) {
        let info = getApplicationInfo(app)
        if !info.path.isEmpty {
            appScanner.openInFinder(path: info.path)
        }
    }
    
    func launchApplication(_ app: Application) {
        appScanner.launchApplication(app)
    }
    
    // MARK: - Notification Handling
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCreateNewShortcut),
            name: .createNewShortcut,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleEditShortcut),
            name: .editShortcut,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeleteShortcut),
            name: .deleteShortcut,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDuplicateShortcut),
            name: .duplicateShortcut,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleCaptureShortcut),
            name: .captureShortcut,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleToggleFavorite),
            name: .toggleFavorite,
            object: nil
        )
    }
    
    @objc private func handleCreateNewShortcut() {
        showNewShortcutSheet = true
    }
    
    @objc private func handleEditShortcut() {
        // Implementation depends on selected shortcut
    }
    
    @objc private func handleDeleteShortcut() {
        if let shortcut = selectedShortcut {
            deleteShortcut(shortcut)
        }
    }
    
    @objc private func handleDuplicateShortcut() {
        if let shortcut = selectedShortcut {
            duplicateShortcut(shortcut)
        }
    }
    
    @objc private func handleCaptureShortcut() {
        showCaptureWindow = true
    }
    
    @objc private func handleToggleFavorite() {
        if let shortcut = selectedShortcut {
            toggleFavorite(shortcut)
        }
    }
    
    // MARK: - Application Visibility Management
    
    func hideApplication(_ app: Application) {
        hiddenApplications.insert(app.bundleIdentifier)
        saveHiddenApplications()
        
        // If the hidden app is currently selected, clear selection
        if selectedApplication == app {
            selectedApplication = nil
        }
    }
    
    func showApplication(_ app: Application) {
        hiddenApplications.remove(app.bundleIdentifier)
        saveHiddenApplications()
    }
    
    func isApplicationHidden(_ app: Application) -> Bool {
        return hiddenApplications.contains(app.bundleIdentifier)
    }
    
    func restoreAllHiddenApplications() {
        hiddenApplications.removeAll()
        saveHiddenApplications()
    }
    
    private func saveHiddenApplications() {
        UserDefaults.standard.set(Array(hiddenApplications), forKey: "hiddenApplications")
    }
    
    private func loadHiddenApplications() {
        if let hidden = UserDefaults.standard.array(forKey: "hiddenApplications") as? [String] {
            hiddenApplications = Set(hidden)
        }
    }
    
    // MARK: - Keyboard Shortcut Search
    
    func searchByKeyboardShortcut(_ shortcutPattern: String) {
        searchText = shortcutPattern
    }
    
    private func matchesKeyboardShortcut(_ shortcut: String, _ pattern: String) -> Bool {
        // Normalize both shortcuts for comparison
        let normalizedShortcut = normalizeShortcutForSearch(shortcut)
        let normalizedPattern = normalizeShortcutForSearch(pattern)
        
        // Exact match
        if normalizedShortcut == normalizedPattern {
            return true
        }
        
        // Partial match - pattern contains some of the same keys
        let shortcutComponents = extractShortcutComponents(normalizedShortcut)
        let patternComponents = extractShortcutComponents(normalizedPattern)
        
        // Check if pattern modifiers are subset of shortcut modifiers
        let patternModifiers = Set(patternComponents.modifiers)
        let shortcutModifiers = Set(shortcutComponents.modifiers)
        
        if patternModifiers.isSubset(of: shortcutModifiers) {
            // If key matches or is similar
            if patternComponents.key.isEmpty || 
               shortcutComponents.key.lowercased().contains(patternComponents.key.lowercased()) {
                return true
            }
        }
        
        return false
    }
    
    private func normalizeShortcutForSearch(_ shortcut: String) -> String {
        return shortcut
            .replacingOccurrences(of: "cmd", with: "⌘")
            .replacingOccurrences(of: "command", with: "⌘")
            .replacingOccurrences(of: "shift", with: "⇧")
            .replacingOccurrences(of: "opt", with: "⌥")
            .replacingOccurrences(of: "option", with: "⌥")
            .replacingOccurrences(of: "alt", with: "⌥")
            .replacingOccurrences(of: "ctrl", with: "⌃")
            .replacingOccurrences(of: "control", with: "⌃")
            .replacingOccurrences(of: "+", with: "")
            .replacingOccurrences(of: " ", with: "")
            .uppercased()
    }
    
    private func extractShortcutComponents(_ shortcut: String) -> (modifiers: [String], key: String) {
        let modifierSymbols = ["⌘", "⇧", "⌥", "⌃"]
        var modifiers: [String] = []
        var remainingShortcut = shortcut
        
        for modifier in modifierSymbols {
            if remainingShortcut.contains(modifier) {
                modifiers.append(modifier)
                remainingShortcut = remainingShortcut.replacingOccurrences(of: modifier, with: "")
            }
        }
        
        let key = remainingShortcut.trimmingCharacters(in: .whitespacesAndNewlines)
        return (modifiers, key)
    }
    
    func getAllShortcuts() -> [Shortcut] {
        return shortcuts.sorted { $0.title < $1.title }
    }
    
    func searchAllShortcuts(query: String) -> [Shortcut] {
        if query.isEmpty {
            return getAllShortcuts()
        }
        
        return shortcuts.filter { shortcut in
            // Search by text content
            if shortcut.searchableText.localizedCaseInsensitiveContains(query) {
                return true
            }
            
            // Search by keyboard shortcut matching
            if matchesKeyboardShortcut(shortcut.keyCombination, query) {
                return true
            }
            
            return false
        }.sorted { $0.title < $1.title }
    }
    
    // MARK: - Shortcut Conflict Detection
    
    func detectConflicts(for shortcut: Shortcut) -> [Shortcut] {
        return shortcuts.filter { existingShortcut in
            existingShortcut.id != shortcut.id &&
            existingShortcut.keyCombination == shortcut.keyCombination &&
            existingShortcut.application == shortcut.application
        }
    }
    
    func detectAllConflicts() -> [String: [Shortcut]] {
        var conflicts: [String: [Shortcut]] = [:]
        
        for shortcut in shortcuts {
            let conflicting = detectConflicts(for: shortcut)
            if !conflicting.isEmpty {
                let key = "\(shortcut.keyCombination)-\(shortcut.application?.bundleIdentifier ?? "global")"
                if conflicts[key] == nil {
                    conflicts[key] = [shortcut] + conflicting
                }
            }
        }
        
        return conflicts
    }
    
    func hasConflicts(keyCombination: String, application: Application?, excludingShortcut: Shortcut? = nil) -> Bool {
        return shortcuts.contains { shortcut in
            shortcut.id != excludingShortcut?.id &&
            shortcut.keyCombination == keyCombination &&
            shortcut.application == application
        }
    }
    
    // MARK: - Enhanced Statistics
    
    func getShortcutStatistics() -> ShortcutStatistics {
        let totalShortcuts = shortcuts.count
        let applicationsWithShortcuts = Set(shortcuts.compactMap { $0.application?.bundleIdentifier }).count
        let favoriteShortcuts = shortcuts.filter { $0.isFavorite }.count
        let categoryCounts = Dictionary(grouping: shortcuts, by: { $0.category })
            .mapValues { $0.count }
        let conflicts = detectAllConflicts()
        
        return ShortcutStatistics(
            totalShortcuts: totalShortcuts,
            applicationsWithShortcuts: applicationsWithShortcuts,
            favoriteShortcuts: favoriteShortcuts,
            categoryCounts: categoryCounts,
            conflictCount: conflicts.count
        )
    }
}

struct ShortcutStatistics {
    let totalShortcuts: Int
    let applicationsWithShortcuts: Int
    let favoriteShortcuts: Int
    let categoryCounts: [String: Int]
    let conflictCount: Int
}