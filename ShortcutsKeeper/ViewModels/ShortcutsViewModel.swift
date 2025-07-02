//
//  ShortcutsViewModel.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftUI
import SwiftData

@Observable
class ShortcutsViewModel {
    var shortcuts: [Shortcut] = []
    var applications: [Application] = []
    var searchText = ""
    var selectedApplication: Application?
    var selectedCategory = "All"
    var showOnlyFavorites = false
    var isCapturingShortcut = false
    var capturedShortcut = ""
    var conflictingShortcuts: [Shortcut] = []
    var showNewShortcutSheet = false
    var editingShortcut: Shortcut?
    var isScanning = false
    var showSettingsWindow = false
    
    private let shortcutCapture = ShortcutCaptureService()
    private let appScanner = ApplicationScannerService.shared
    private var modelContext: ModelContext?
    
    var categories: [String] {
        var cats = Set<String>()
        cats.insert("All")
        shortcuts.forEach { cats.insert($0.category) }
        return Array(cats).sorted()
    }
    
    var filteredShortcuts: [Shortcut] {
        var results = shortcuts
        
        if let app = selectedApplication {
            results = results.filter { $0.application == app }
        }
        
        if selectedCategory != "All" {
            results = results.filter { $0.category == selectedCategory }
        }
        
        if showOnlyFavorites {
            results = results.filter { $0.isFavorite }
        }
        
        if !searchText.isEmpty {
            results = results.filter { shortcut in
                shortcut.searchableText.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return results.sorted { $0.title < $1.title }
    }
    
    var shortcutsByApplication: [Application: [Shortcut]] {
        Dictionary(grouping: filteredShortcuts) { $0.application ?? Application(name: "No Application") }
    }
    
    init() {
        setupNotifications()
    }
    
    func setup(with context: ModelContext) {
        self.modelContext = context
        fetchData()
    }
    
    private func setupNotifications() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleNewShortcut),
            name: .createNewShortcut,
            object: nil
        )
    }
    
    @objc private func handleNewShortcut() {
        showNewShortcutSheet = true
    }
    
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
        guard let context = modelContext else { return }
        context.delete(shortcut)
        saveContext()
        fetchData()
    }
    
    func toggleFavorite(_ shortcut: Shortcut) {
        shortcut.isFavorite.toggle()
        saveContext()
        fetchData()
    }
    
    func addApplication(name: String, bundleIdentifier: String = "") {
        guard let context = modelContext else { return }
        
        let app = Application(name: name, bundleIdentifier: bundleIdentifier)
        context.insert(app)
        saveContext()
        fetchData()
    }
    
    func deleteApplication(_ app: Application) {
        guard let context = modelContext else { return }
        context.delete(app)
        saveContext()
        fetchData()
    }
    
    func startCapturingShortcut() {
        isCapturingShortcut = true
        capturedShortcut = ""
        conflictingShortcuts = []
        
        shortcutCapture.startCapturing { [weak self] shortcut in
            DispatchQueue.main.async {
                self?.capturedShortcut = shortcut
                self?.checkForConflicts(shortcut)
                self?.isCapturingShortcut = false
            }
        }
    }
    
    func stopCapturingShortcut() {
        shortcutCapture.stopCapturing()
        isCapturingShortcut = false
    }
    
    func checkForConflicts(_ keyCombination: String) {
        let normalized = ShortcutCaptureService.normalizeShortcut(keyCombination)
        conflictingShortcuts = shortcuts.filter {
            ShortcutCaptureService.normalizeShortcut($0.keyCombination) == normalized
        }
    }
    
    func findShortcutsByKeyCombination(_ keyCombination: String) -> [Shortcut] {
        let normalized = ShortcutCaptureService.normalizeShortcut(keyCombination)
        return shortcuts.filter {
            ShortcutCaptureService.normalizeShortcut($0.keyCombination) == normalized
        }
    }
    
    func scanForAllApplications() {
        guard let context = modelContext else { return }
        isScanning = true
        
        appScanner.scanForApplications { [weak self] scannedApps in
            guard let self = self else { return }
            
            for scannedApp in scannedApps {
                // Check if app already exists
                if !self.applications.contains(where: { $0.bundleIdentifier == scannedApp.bundleIdentifier }) {
                    context.insert(scannedApp)
                }
            }
            
            self.saveContext()
            self.fetchData()
            self.isScanning = false
        }
    }
    
    func refreshApplications() {
        scanForAllApplications()
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
    
    func exportShortcuts() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        struct ExportableShortcut: Codable {
            let title: String
            let keyCombination: String
            let description: String
            let category: String
            let application: String
            let tags: [String]
        }
        
        let exportData = shortcuts.map { shortcut in
            ExportableShortcut(
                title: shortcut.title,
                keyCombination: shortcut.keyCombination,
                description: shortcut.shortcutDescription,
                category: shortcut.category,
                application: shortcut.application?.name ?? "",
                tags: shortcut.tags
            )
        }
        
        return try? encoder.encode(exportData)
    }
    
    func importShortcuts(from data: Data) {
        guard let context = modelContext else { return }
        
        struct ImportableShortcut: Codable {
            let title: String
            let keyCombination: String
            let description: String?
            let category: String?
            let application: String?
            let tags: [String]?
        }
        
        guard let importData = try? JSONDecoder().decode([ImportableShortcut].self, from: data) else {
            return
        }
        
        for item in importData {
            let app = applications.first { $0.name == item.application }
            
            let shortcut = Shortcut(
                title: item.title,
                keyCombination: item.keyCombination,
                shortcutDescription: item.description ?? "",
                category: item.category ?? "General",
                application: app,
                tags: item.tags ?? []
            )
            
            context.insert(shortcut)
        }
        
        saveContext()
        fetchData()
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
        } catch {
            print("Error saving context: \(error)")
        }
    }
}