//
//  BackupRestoreService.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Thread-safe Backup Service using Actor

actor BackupRestoreActor {
    private var isBackingUp = false
    private var isRestoring = false
    private var backupProgress: Double = 0.0
    private var restoreProgress: Double = 0.0
    
    func startBackup() -> Bool {
        guard !isBackingUp else { return false }
        isBackingUp = true
        backupProgress = 0.0
        return true
    }
    
    func endBackup() {
        isBackingUp = false
        backupProgress = 0.0
    }
    
    func startRestore() -> Bool {
        guard !isRestoring else { return false }
        isRestoring = true
        restoreProgress = 0.0
        return true
    }
    
    func endRestore() {
        isRestoring = false
        restoreProgress = 0.0
    }
    
    func updateBackupProgress(_ progress: Double) {
        backupProgress = progress
    }
    
    func updateRestoreProgress(_ progress: Double) {
        restoreProgress = progress
    }
    
    func getBackupProgress() -> Double {
        return backupProgress
    }
    
    func getRestoreProgress() -> Double {
        return restoreProgress
    }
}

@MainActor
class BackupRestoreService: ObservableObject {
    @Published var isBackingUp = false
    @Published var isRestoring = false
    @Published var backupProgress: Double = 0.0
    @Published var restoreProgress: Double = 0.0
    
    private let backupActor = BackupRestoreActor()
    @Published var lastBackupDate: Date?
    @Published var autoBackupEnabled = UserDefaults.standard.bool(forKey: "autoBackupEnabled")
    
    private let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    private let backupQueue = DispatchQueue(label: "backup", qos: .userInitiated)
    
    init() {
        loadLastBackupDate()
        setupAutoBackup()
    }
    
    // MARK: - Backup Operations
    
    func createBackup(appModel: AppModel, includeSettings: Bool = true) async -> URL? {
        // Use actor for thread-safe state management
        guard await backupActor.startBackup() else {
            print("Backup already in progress")
            return nil
        }
        
        isBackingUp = true
        backupProgress = 0.0
        
        defer {
            Task {
                await backupActor.endBackup()
                await MainActor.run {
                    self.isBackingUp = false
                    self.backupProgress = 0.0
                }
            }
        }
        
        let timestamp = Date().formatted(.iso8601.year().month().day().time(includingFractionalSeconds: false))
        let backupFileName = "ShortcutsKeeper_Backup_\(timestamp).skbackup"
        let backupURL = documentsURL.appendingPathComponent("Backups").appendingPathComponent(backupFileName)
        
        do {
            // Create backup directory if needed
            try FileManager.default.createDirectory(at: backupURL.deletingLastPathComponent(), 
                                                   withIntermediateDirectories: true)
            
            await backupActor.updateBackupProgress(0.1)
            backupProgress = 0.1
            
            // Create backup structure
            let backup = BackupData(
                version: "1.0",
                createdAt: Date(),
                applications: appModel.applications.map { ApplicationBackup(from: $0) },
                settings: includeSettings ? createSettingsBackup() : nil
            )
            
            await backupActor.updateBackupProgress(0.5)
            backupProgress = 0.5
            
            // Encode and save
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            
            let backupData = try encoder.encode(backup)
            try backupData.write(to: backupURL)
            
            await backupActor.updateBackupProgress(1.0)
            backupProgress = 1.0
            
            // Update last backup date
            await MainActor.run {
                lastBackupDate = Date()
                saveLastBackupDate()
            }
            
            return backupURL
        } catch {
            print("Backup failed: \(error)")
            return nil
        }
    }
    
    func createQuickBackup(appModel: AppModel) async -> URL? {
        let quickBackupURL = documentsURL.appendingPathComponent("quick_backup.skbackup")
        
        do {
            let backup = BackupData(
                version: "1.0",
                createdAt: Date(),
                applications: appModel.applications.map { ApplicationBackup(from: $0) },
                settings: nil
            )
            
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let backupData = try encoder.encode(backup)
            try backupData.write(to: quickBackupURL)
            
            return quickBackupURL
        } catch {
            print("Quick backup failed: \(error)")
            return nil
        }
    }
    
    // MARK: - Restore Operations
    
    func restoreFromBackup(from url: URL, appModel: AppModel, restoreSettings: Bool = true) async -> Bool {
        // Use actor for thread-safe state management
        guard await backupActor.startRestore() else {
            print("Restore already in progress")
            return false
        }
        
        isRestoring = true
        restoreProgress = 0.0
        
        defer {
            Task {
                await backupActor.endRestore()
                await MainActor.run {
                    self.isRestoring = false
                    self.restoreProgress = 0.0
                }
            }
        }
        
        do {
            await backupActor.updateRestoreProgress(0.1)
            restoreProgress = 0.1
            
            let backupData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(BackupData.self, from: backupData)
            
            await backupActor.updateRestoreProgress(0.3)
            restoreProgress = 0.3
            
            // Validate backup version compatibility
            guard isBackupCompatible(backup.version) else {
                print("Incompatible backup version: \(backup.version)")
                return false
            }
            
            // Clear existing data if requested
            await MainActor.run {
                appModel.applications.removeAll()
            }
            
            await backupActor.updateRestoreProgress(0.5)
            restoreProgress = 0.5
            
            // Restore applications and shortcuts
            for (index, appBackup) in backup.applications.enumerated() {
                let application = Application(from: appBackup)
                await MainActor.run {
                    appModel.applications.append(application)
                }
                
                let progress = 0.5 + (0.4 * Double(index + 1) / Double(backup.applications.count))
                await backupActor.updateRestoreProgress(progress)
                restoreProgress = progress
            }
            
            // Restore settings if requested
            if restoreSettings, let settings = backup.settings {
                restoreAppSettings(settings)
            }
            
            await backupActor.updateRestoreProgress(1.0)
            restoreProgress = 1.0
            
            return true
        } catch {
            print("Restore failed: \(error)")
            return false
        }
    }
    
    // MARK: - Auto Backup
    
    func setupAutoBackup() {
        guard autoBackupEnabled else { return }
        
        Timer.scheduledTimer(withTimeInterval: 3600, repeats: true) { [weak self] _ in
            self?.performAutoBackupIfNeeded()
        }
    }
    
    private func performAutoBackupIfNeeded() {
        guard autoBackupEnabled else { return }
        
        let shouldBackup: Bool
        if let lastBackup = lastBackupDate {
            shouldBackup = Date().timeIntervalSince(lastBackup) > 24 * 60 * 60 // 24 hours
        } else {
            shouldBackup = true
        }
        
        if shouldBackup {
            Task {
                // Create auto backup (this would need access to AppModel)
                // For now, we'll just update the date
                await MainActor.run {
                    lastBackupDate = Date()
                    saveLastBackupDate()
                }
            }
        }
    }
    
    // MARK: - Backup Management
    
    func getAvailableBackups() -> [BackupInfo] {
        let backupsURL = documentsURL.appendingPathComponent("Backups")
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: backupsURL, 
                                                                      includingPropertiesForKeys: [.creationDateKey, .fileSizeKey])
            
            return fileURLs.compactMap { url in
                guard url.pathExtension == "skbackup" else { return nil }
                
                do {
                    let resourceValues = try url.resourceValues(forKeys: [.creationDateKey, .fileSizeKey])
                    return BackupInfo(
                        url: url,
                        name: url.deletingPathExtension().lastPathComponent,
                        createdAt: resourceValues.creationDate ?? Date(),
                        size: resourceValues.fileSize ?? 0
                    )
                } catch {
                    return nil
                }
            }.sorted { $0.createdAt > $1.createdAt }
        } catch {
            return []
        }
    }
    
    func deleteBackup(at url: URL) throws {
        try FileManager.default.removeItem(at: url)
    }
    
    func getBackupDetails(from url: URL) -> BackupDetails? {
        do {
            let backupData = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backup = try decoder.decode(BackupData.self, from: backupData)
            
            let totalShortcuts = backup.applications.reduce(0) { $0 + $1.shortcuts.count }
            let categories = Set(backup.applications.flatMap { $0.shortcuts.map { $0.category } })
            
            return BackupDetails(
                version: backup.version,
                createdAt: backup.createdAt,
                applicationCount: backup.applications.count,
                shortcutCount: totalShortcuts,
                categoryCount: categories.count,
                hasSettings: backup.settings != nil
            )
        } catch {
            return nil
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateProgress(_ progress: Double) async {
        await backupActor.updateBackupProgress(progress)
        backupProgress = progress
    }
    
    private func updateRestoreProgress(_ progress: Double) async {
        await backupActor.updateRestoreProgress(progress)
        restoreProgress = progress
    }
    
    private func createSettingsBackup() -> SettingsBackup {
        return SettingsBackup(
            showSystemApps: UserDefaults.standard.bool(forKey: "showSystemApps"),
            enableMenuBar: UserDefaults.standard.bool(forKey: "enableMenuBar"),
            autoScanOnLaunch: UserDefaults.standard.bool(forKey: "autoScanOnLaunch"),
            enableGlobalHotkey: UserDefaults.standard.bool(forKey: "enableGlobalHotkey"),
            globalHotkeyCombo: UserDefaults.standard.string(forKey: "globalHotkeyCombo") ?? "⌘⌥K",
            defaultCategory: UserDefaults.standard.string(forKey: "defaultCategory") ?? "General"
        )
    }
    
    private func restoreAppSettings(_ settings: SettingsBackup) {
        UserDefaults.standard.set(settings.showSystemApps, forKey: "showSystemApps")
        UserDefaults.standard.set(settings.enableMenuBar, forKey: "enableMenuBar")
        UserDefaults.standard.set(settings.autoScanOnLaunch, forKey: "autoScanOnLaunch")
        UserDefaults.standard.set(settings.enableGlobalHotkey, forKey: "enableGlobalHotkey")
        UserDefaults.standard.set(settings.globalHotkeyCombo, forKey: "globalHotkeyCombo")
        UserDefaults.standard.set(settings.defaultCategory, forKey: "defaultCategory")
    }
    
    private func isBackupCompatible(_ version: String) -> Bool {
        // Simple version compatibility check
        return version.hasPrefix("1.")
    }
    
    private func loadLastBackupDate() {
        if let date = UserDefaults.standard.object(forKey: "lastBackupDate") as? Date {
            lastBackupDate = date
        }
    }
    
    private func saveLastBackupDate() {
        UserDefaults.standard.set(lastBackupDate, forKey: "lastBackupDate")
    }
}

// MARK: - Data Structures

struct BackupData: Codable {
    let version: String
    let createdAt: Date
    let applications: [ApplicationBackup]
    let settings: SettingsBackup?
}

struct ApplicationBackup: Codable {
    let name: String
    let bundleIdentifier: String
    let shortcuts: [ShortcutBackup]
    
    init(from application: Application) {
        self.name = application.name
        self.bundleIdentifier = application.bundleIdentifier
        self.shortcuts = application.shortcuts.map { ShortcutBackup(from: $0) }
    }
}

struct ShortcutBackup: Codable {
    let title: String
    let keyCombination: String
    let shortcutDescription: String
    let category: String
    let tags: [String]
    let isFavorite: Bool
    let dateAdded: Date
    
    init(from shortcut: Shortcut) {
        self.title = shortcut.title
        self.keyCombination = shortcut.keyCombination
        self.shortcutDescription = shortcut.shortcutDescription
        self.category = shortcut.category
        self.tags = shortcut.tags
        self.isFavorite = shortcut.isFavorite
        self.dateAdded = Date()  // Use current date since dateAdded property doesn't exist
    }
}

struct SettingsBackup: Codable {
    let showSystemApps: Bool
    let enableMenuBar: Bool
    let autoScanOnLaunch: Bool
    let enableGlobalHotkey: Bool
    let globalHotkeyCombo: String
    let defaultCategory: String
}

struct BackupInfo: Identifiable, Hashable {
    let id = UUID()
    let url: URL
    let name: String
    let createdAt: Date
    let size: Int
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: BackupInfo, rhs: BackupInfo) -> Bool {
        lhs.id == rhs.id
    }
}

struct BackupDetails {
    let version: String
    let createdAt: Date
    let applicationCount: Int
    let shortcutCount: Int
    let categoryCount: Int
    let hasSettings: Bool
}

// MARK: - Extensions

extension Application {
    convenience init(from backup: ApplicationBackup) {
        self.init(name: backup.name, bundleIdentifier: backup.bundleIdentifier)
        self.shortcuts = backup.shortcuts.map { Shortcut(from: $0, application: self) }
    }
}

extension Shortcut {
    convenience init(from backup: ShortcutBackup, application: Application) {
        self.init(
            title: backup.title,
            keyCombination: backup.keyCombination,
            shortcutDescription: backup.shortcutDescription,
            category: backup.category,
            application: application
        )
        self.tags = backup.tags
        self.isFavorite = backup.isFavorite
        // Note: dateAdded property doesn't exist on Shortcut model
    }
}