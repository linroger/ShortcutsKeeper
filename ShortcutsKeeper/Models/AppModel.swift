//
//  AppModel.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftUI
import SwiftData
import Combine

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
    var isLoading = true  // Add loading state
    var showSettingsWindow = false
    var showNewShortcutSheet = false
    var showEditShortcutSheet = false
    var showCaptureWindow = false
    var hiddenApplications = Set<String>()
    
    var modelContext: ModelContext?
    private let appScanner = ApplicationScannerService.shared
    private let shortcutCapture = ShortcutCaptureService()
    private let accessibilityExtractor = AccessibilityShortcutExtractor()
    private var memoryTimer: Timer?
    
    // MEMORY OPTIMIZATION: Cached computed properties
    private var _filteredApplicationsCache: [Application] = []
    private var _lastFilterSettings = (showSystemApps: false, hiddenApps: Set<String>())
    private var _filteredApplicationsCount: Int = 0
    
    private init() {
        setupNotifications()
        loadHiddenApplications()
        startMemoryMonitoring()
    }
    
    func setup(with context: ModelContext) {
        self.modelContext = context
        
        // Defer data loading to avoid blocking UI
        Task { @MainActor in
            fetchData()
            
            // Only scan if enabled and no apps exist
            if UserDefaults.standard.bool(forKey: "autoScanOnLaunch") && applications.isEmpty {
                // Add slight delay to ensure UI is responsive
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
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
            // Fetch in batches to avoid memory spikes
            shortcuts = try context.fetch(shortcutDescriptor)
            applications = try context.fetch(appDescriptor)
            
            // Invalidate cache after loading data
            invalidateApplicationCache()
            
            // Mark loading as complete
            isLoading = false
        } catch {
            print("Error fetching data: \(error)")
            isLoading = false
        }
    }
    
    private func saveContext() {
        guard let context = modelContext else { return }
        
        do {
            try context.save()
            // Only fetch if we need to refresh UI state
            // Remove automatic fetchData() calls
        } catch {
            print("Error saving context: \(error)")
        }
    }
    
    // MARK: - Application Management
    
    func scanForAllApplications() async {
        isScanning = true
        
        appScanner.scanForApplications { [weak self] scannedApps in
            guard let self = self, let context = self.modelContext else { return }
            
            for scannedApp in scannedApps {
                // DUPLICATE PREVENTION: Check both bundle identifier and name
                let isDuplicate = self.applications.contains { existingApp in
                    existingApp.bundleIdentifier == scannedApp.bundleIdentifier ||
                    existingApp.name == scannedApp.name
                }
                
                if !isDuplicate {
                    context.insert(scannedApp)
                    print("📱 Added new application: \(scannedApp.name)")
                } else {
                    print("⚠️ Skipped duplicate application: \(scannedApp.name)")
                }
            }
            
            self.saveContext()
            // PERFORMANCE: Only refresh applications data
            if let context = self.modelContext {
                do {
                    self.applications = try context.fetch(FetchDescriptor<Application>())
                    self.invalidateApplicationCache()
                } catch {
                    print("Error refreshing applications: \(error)")
                }
            }
            self.isScanning = false
        }
    }
    
    func extractShortcutsFromRunningApp(_ app: Application) async {
        guard !app.bundleIdentifier.isEmpty else { return }
        
        let extractedShortcuts = await accessibilityExtractor.extractShortcuts(from: app.bundleIdentifier)
        
        for shortcutInfo in extractedShortcuts {
            // DUPLICATE PREVENTION: Enhanced checking for existing shortcuts
            let isDuplicate = shortcuts.contains { existingShortcut in
                existingShortcut.application == app && 
                (existingShortcut.keyCombination == shortcutInfo.keyCombination ||
                 existingShortcut.title == shortcutInfo.title)
            }
            
            if !isDuplicate {
                let shortcut = Shortcut(
                    title: shortcutInfo.title,
                    keyCombination: shortcutInfo.keyCombination,
                    shortcutDescription: shortcutInfo.description,
                    category: shortcutInfo.category,
                    application: app
                )
                
                modelContext?.insert(shortcut)
                print("⌨️ Added shortcut: \(shortcutInfo.title) (\(shortcutInfo.keyCombination))")
            } else {
                print("⚠️ Skipped duplicate shortcut: \(shortcutInfo.title)")
            }
        }
        
        saveContext()
        // PERFORMANCE: Only refresh affected data, not full fetch
        if let context = modelContext {
            do {
                shortcuts = try context.fetch(FetchDescriptor<Shortcut>())
                invalidateApplicationCache() // Update filtered applications cache
            } catch {
                print("Error refreshing shortcuts: \(error)")
            }
        }
    }
    
    // MARK: - Shortcut Management
    
    func addShortcut(
        title: String,
        keyCombination: String,
        keyCombinations: [String] = [],
        description: String,
        category: String,
        subcategory: String? = nil,
        application: Application?,
        tags: [String]
    ) {
        guard let context = modelContext else { return }
        
        let shortcut = Shortcut(
            title: title,
            keyCombination: keyCombination,
            keyCombinations: keyCombinations,
            shortcutDescription: description,
            category: category.isEmpty ? "General" : category,
            subcategory: subcategory,
            application: application,
            tags: tags
        )
        
        context.insert(shortcut)
        shortcuts.append(shortcut)
        saveContext()
    }
    
    func updateShortcut(_ shortcut: Shortcut) {
        shortcut.dateModified = Date()
        saveContext()
    }
    
    func deleteShortcut(_ shortcut: Shortcut) {
        print("Debug: AppModel deleteShortcut called for: \(shortcut.title)")
        
        // Soft delete - move to bin
        shortcut.isDeleted = true
        shortcut.dateDeleted = Date()
        
        print("Debug: Marked as deleted, saving context...")
        saveContext()
        
        print("Debug: Fetching data to refresh UI...")
        fetchData()
        
        print("Debug: Delete operation completed. Shortcuts count: \(shortcuts.count)")
    }
    
    func restoreShortcut(_ shortcut: Shortcut) {
        shortcut.isDeleted = false
        shortcut.dateDeleted = nil
        saveContext()
    }
    
    func permanentlyDeleteShortcut(_ shortcut: Shortcut) {
        guard let context = modelContext else { return }
        context.delete(shortcut)
        saveContext()
        // PERFORMANCE: Only refresh affected data, not full fetch
        if let context = modelContext {
            do {
                shortcuts = try context.fetch(FetchDescriptor<Shortcut>())
                invalidateApplicationCache() // Update filtered applications cache
            } catch {
                print("Error refreshing shortcuts: \(error)")
            }
        }
    }
    
    func clearAllShortcuts() {
        guard let context = modelContext else { return }
        
        // Delete all shortcuts from the data store
        for shortcut in shortcuts {
            context.delete(shortcut)
        }
        
        // Clear the in-memory array
        shortcuts.removeAll()
        
        saveContext()
        // PERFORMANCE: Only refresh affected data, not full fetch
        if let context = modelContext {
            do {
                shortcuts = try context.fetch(FetchDescriptor<Shortcut>())
                invalidateApplicationCache() // Update filtered applications cache
            } catch {
                print("Error refreshing shortcuts: \(error)")
            }
        }
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
        // PERFORMANCE: Only refresh affected data, not full fetch
        if let context = modelContext {
            do {
                shortcuts = try context.fetch(FetchDescriptor<Shortcut>())
                invalidateApplicationCache() // Update filtered applications cache
            } catch {
                print("Error refreshing shortcuts: \(error)")
            }
        }
    }
    
    func toggleFavorite(_ shortcut: Shortcut) {
        shortcut.isFavorite.toggle()
        saveContext()
    }
    
    // MARK: - Computed Properties
    
    // PERFORMANCE OPTIMIZATION: Cached filtered applications
    var filteredApplications: [Application] {
        let showSystemApps = UserDefaults.standard.bool(forKey: "showSystemApps")
        let currentSettings = (showSystemApps: showSystemApps, hiddenApps: hiddenApplications)
        
        // Return cached result if settings haven't changed
        if _lastFilterSettings.showSystemApps == currentSettings.showSystemApps &&
           _lastFilterSettings.hiddenApps == currentSettings.hiddenApps &&
           !_filteredApplicationsCache.isEmpty {
            return _filteredApplicationsCache
        }
        
        // Recalculate and cache
        _filteredApplicationsCache = applications
            .filter { app in
                (showSystemApps || !app.isSystemApp) && !hiddenApplications.contains(app.bundleIdentifier)
            }
            .sorted { $0.name < $1.name }
        
        _filteredApplicationsCount = _filteredApplicationsCache.count
        _lastFilterSettings = currentSettings
        return _filteredApplicationsCache
    }
    
    // PERFORMANCE OPTIMIZATION: Fast access to count without recalculating array
    var filteredApplicationsCount: Int {
        let showSystemApps = UserDefaults.standard.bool(forKey: "showSystemApps")
        let currentSettings = (showSystemApps: showSystemApps, hiddenApps: hiddenApplications)
        
        // Return cached count if settings haven't changed
        if _lastFilterSettings.showSystemApps == currentSettings.showSystemApps &&
           _lastFilterSettings.hiddenApps == currentSettings.hiddenApps &&
           _filteredApplicationsCount > 0 {
            return _filteredApplicationsCount
        }
        
        // Trigger cache update by accessing filteredApplications
        _ = filteredApplications
        return _filteredApplicationsCount
    }
    
    func invalidateApplicationCache() {
        _filteredApplicationsCache.removeAll()
        _filteredApplicationsCount = 0
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
    
    // MARK: - Context Menu Actions
    
    func removeApplication(_ application: Application) {
        guard let context = modelContext else { return }
        
        // First, remove all shortcuts associated with this application
        let associatedShortcuts = shortcuts.filter { $0.application == application }
        for shortcut in associatedShortcuts {
            context.delete(shortcut)
        }
        
        // Then remove the application
        context.delete(application)
        
        // Clear selection if this was the selected app
        if selectedApplication == application {
            selectedApplication = nil
        }
        
        saveContext()
        // PERFORMANCE: Only refresh affected data, not full fetch
        if let context = modelContext {
            do {
                shortcuts = try context.fetch(FetchDescriptor<Shortcut>())
                invalidateApplicationCache() // Update filtered applications cache
            } catch {
                print("Error refreshing shortcuts: \(error)")
            }
        } // Refresh data to update UI
    }
    
    func moveShortcut(_ shortcut: Shortcut, to application: Application) {
        shortcut.application = application
        saveContext()
    }
    
    // MARK: - Memory Management & Performance Monitoring
    
    private func startMemoryMonitoring() {
        // DISABLED: Memory monitoring was causing 99% CPU usage
        // The expensive mach_task_basic_info calls are not needed for normal operation
        // Users can manually check memory in Activity Monitor if needed
        print("📱 Memory monitoring disabled to prevent CPU overload")
        // memoryTimer = Timer.scheduledTimer(withTimeInterval: 600.0, repeats: true) { _ in
        //     Task { @MainActor in
        //         self.performLightweightMemoryCheck()
        //     }
        // }
    }
    
    @MainActor
    private func checkMemoryUsage() {
        // DISABLED: This function was causing excessive CPU usage with expensive kernel calls
        // The mach_task_basic_info system calls were consuming 99% CPU
        print("💾 Memory monitoring disabled - use Activity Monitor for memory stats")
        return
        
        // Original expensive code commented out:
        // var memoryInfo = mach_task_basic_info()
        // var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        // 
        // let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
        //     $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        //         task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        //     }
        // }
        // 
        // if kerr == KERN_SUCCESS {
        //     let memoryUsageMB = memoryInfo.resident_size / 1_024 / 1_024
        //     if memoryUsageMB > 1000 { // Alert if over 1GB
        //         print("⚠️ High memory usage: \(memoryUsageMB)MB")
        //         performMemoryCleanup()
        //     }
        // }
    }
    
    private func performMemoryCleanup() {
        print("🧹 Performing memory cleanup...")
        
        // Clear application cache
        invalidateApplicationCache()
        
        // Save any pending changes
        saveContext()
        
        // Clear search text to release any filtered results
        if !searchText.isEmpty {
            searchText = ""
        }
        
        // Trigger garbage collection
        autoreleasepool {
            // Force release of temporary objects
            _ = applications.count
            _ = shortcuts.count
        }
        
        print("✅ Memory cleanup completed")
    }
    
    func getMemoryStats() -> (applications: Int, shortcuts: Int, totalMB: Int) {
        let appCount = applications.count
        let shortcutCount = shortcuts.count
        
        // PERFORMANCE FIX: Avoid expensive kernel calls
        // Return -1 for memory to indicate monitoring is disabled
        let totalMB = -1 // Use Activity Monitor for memory stats
        
        return (applications: appCount, shortcuts: shortcutCount, totalMB: totalMB)
        
        // Original expensive code commented out:
        // var memoryInfo = mach_task_basic_info()
        // var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        // 
        // let kerr: kern_return_t = withUnsafeMutablePointer(to: &memoryInfo) {
        //     $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
        //         task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
        //     }
        // }
        // 
        // let totalMB = kerr == KERN_SUCCESS ? Int(memoryInfo.resident_size / 1_024 / 1_024) : -1
    }
    
    // MARK: - Import/Export
    
    func exportShortcutsToCSV() -> String {
        var csvString = "App,Shortcut,Description,Tags,Pinned\n"
        
        for shortcut in shortcuts.filter({ !($0.isDeleted ?? false) }) {
            let appName = shortcut.application?.name ?? "Unknown"
            let keyCombination = shortcut.keyCombination
            let description = shortcut.description
            let tags = shortcut.tags.joined(separator: " ")
            let pinned = shortcut.isFavorite ? "1" : "0"
            
            // Escape fields that contain commas
            let escapedDescription = description.contains(",") ? "\"\(description)\"" : description
            
            csvString += "\(appName),\(keyCombination),\(escapedDescription),\(tags),\(pinned)\n"
        }
        
        return csvString
    }
    
    func importShortcutsFromCSV(_ csvContent: String) async throws -> (imported: Int, skipped: Int) {
        let lines = csvContent.components(separatedBy: .newlines)
        guard lines.count > 1 else { throw ImportError.invalidFormat }
        
        var imported = 0
        var skipped = 0
        
        // Check header format to determine CSV structure
        let header = lines[0].lowercased()
        let isNewFormat = header.contains("app_name") && header.contains("key_combination")
        let isGeminiFormat = header.contains("subcategory") && header.contains("name")
        
        for (index, line) in lines.enumerated() {
            if index == 0 || line.isEmpty { continue } // Skip header and empty lines
            
            let fields = parseCSVLine(line)
            
            var appName: String
            var keyCombination: String
            var title: String
            var description: String
            var tags: [String]
            var subcategory: String? = nil
            var isFavorite = false
            
            if isGeminiFormat {
                // Gemini format: App,Shortcut,Name,Tags,Pinned,description,subcategory
                guard fields.count >= 6 else { 
                    skipped += 1
                    continue 
                }
                
                appName = fields[0]                // App column
                keyCombination = fields[1]         // Shortcut column (the actual keys)
                let shortcutName = fields[2]       // Name column (the command name)
                tags = fields[3].split(separator: " ").map { String($0.trimmingCharacters(in: .whitespaces)) }
                isFavorite = fields[4] == "1"      // Pinned column
                let descriptionField = fields[5]  // description column
                if fields.count > 6 && !fields[6].isEmpty {
                    subcategory = fields[6]        // subcategory column
                }
                
                // Use Name column as title, description column as description
                title = shortcutName.isEmpty ? "Imported Shortcut" : shortcutName
                description = descriptionField
            } else if isNewFormat {
                // New format: app_name,shortcut_name,key_combination,description,tags
                guard fields.count >= 5 else { 
                    skipped += 1
                    continue 
                }
                
                appName = fields[0]
                let shortcutName = fields[1]
                keyCombination = fields[2]
                title = shortcutName.isEmpty ? "Imported Shortcut" : shortcutName
                description = fields[3]
                tags = fields[4].split(separator: ",").map { String($0.trimmingCharacters(in: .whitespaces)) }
            } else {
                // Old format: App,Shortcut,Description,Tags,Pinned
                guard fields.count >= 5 else { 
                    skipped += 1
                    continue 
                }
                
                appName = fields[0]
                keyCombination = fields[1]
                title = fields[2].isEmpty ? "Imported Shortcut" : fields[2]
                description = fields[2]
                tags = fields[3].split(separator: " ").map { String($0) }
                isFavorite = fields[4] == "1"
            }
            
            // Find or create application
            var application: Application?
            if appName != "macOS" && appName != "Unknown" && !appName.isEmpty {
                application = applications.first { $0.name == appName }
                
                if application == nil {
                    // Create a placeholder application
                    application = Application(
                        name: appName,
                        bundleIdentifier: "com.placeholder.\(appName.lowercased().replacingOccurrences(of: " ", with: ""))",
                        path: "/Applications/\(appName).app"
                    )
                    if let context = modelContext {
                        context.insert(application!)
                        applications.append(application!)
                    }
                }
            }
            
            // Check if shortcut already exists
            let exists = shortcuts.contains { 
                $0.keyCombination == keyCombination && 
                $0.application?.name == application?.name 
            }
            
            if !exists {
                // Parse multiple key combinations separated by | or ;
                let multipleKeys = keyCombination.components(separatedBy: CharacterSet(charactersIn: "|;"))
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                
                let primaryKey = multipleKeys.first ?? keyCombination
                let allKeys = multipleKeys.count > 1 ? multipleKeys : []
                
                addShortcut(
                    title: title,
                    keyCombination: primaryKey,
                    keyCombinations: allKeys,
                    description: description,
                    category: "Imported",
                    subcategory: subcategory,
                    application: application,
                    tags: tags
                )
                
                // Set favorite status if needed
                if isFavorite, let newShortcut = shortcuts.last {
                    newShortcut.isFavorite = true
                }
                
                imported += 1
            } else {
                skipped += 1
            }
        }
        
        return (imported, skipped)
    }
    
    private func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var inQuotes = false
        
        for char in line {
            if char == "\"" {
                inQuotes.toggle()
            } else if char == "," && !inQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        
        fields.append(currentField)
        return fields
    }
    
    @MainActor
    enum ImportError: LocalizedError {
        case invalidFormat
        case readError
        
        nonisolated var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "Invalid CSV format"
            case .readError:
                return "Failed to read file"
            }
        }
    }
    
    @MainActor
    deinit {
        memoryTimer?.invalidate()
    }
}

struct ShortcutStatistics {
    let totalShortcuts: Int
    let applicationsWithShortcuts: Int
    let favoriteShortcuts: Int
    let categoryCounts: [String: Int]
    let conflictCount: Int
}