//
//  ShortcutsKeeperApp.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import SwiftData
import Combine

@main
struct ShortcutsKeeperApp: App {
    @StateObject private var menuBarManager = MenuBarManager()
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Shortcut.self,
            Application.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Handle migration issues more gracefully
            print("⚠️ Database migration error: \(error)")
            
            // Create a backup before attempting any recovery
            let storeURL = modelConfiguration.url
            let backupURL = storeURL.appendingPathExtension("backup-\(Date().timeIntervalSince1970)")
            
            do {
                // Backup existing database files
                try? FileManager.default.copyItem(at: storeURL, to: backupURL)
                print("✅ Created database backup at: \(backupURL.lastPathComponent)")
                
                // Try to create a new container with migration options
                let migrationConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: false,
                    cloudKitDatabase: .none
                )
                
                if let container = try? ModelContainer(for: schema, configurations: [migrationConfiguration]) {
                    return container
                }
                
                // If migration still fails, create a fresh database but keep the backup
                print("⚠️ Migration failed, creating fresh database. Your old data is backed up.")
                
                // Move old database to backup location instead of deleting
                let timestampedBackup = storeURL.appendingPathExtension("failed-\(Date().timeIntervalSince1970)")
                try? FileManager.default.moveItem(at: storeURL, to: timestampedBackup)
                try? FileManager.default.moveItem(
                    at: storeURL.appendingPathExtension("wal"),
                    to: timestampedBackup.appendingPathExtension("wal")
                )
                try? FileManager.default.moveItem(
                    at: storeURL.appendingPathExtension("shm"),
                    to: timestampedBackup.appendingPathExtension("shm")
                )
                
                // Create fresh container
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
                
            } catch {
                // As a last resort, create an in-memory container to prevent crashes
                print("❌ Critical error: Could not create ModelContainer. Using in-memory storage.")
                let memoryConfiguration = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                return try! ModelContainer(for: schema, configurations: [memoryConfiguration])
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    setupMenuBarIfNeeded()
                }
        }
        .modelContainer(sharedModelContainer)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Shortcut") {
                    NotificationCenter.default.post(name: .createNewShortcut, object: nil)
                }
                .keyboardShortcut("n", modifiers: [.command])
            }
            
            CommandGroup(after: .pasteboard) {
                Divider()
                
                Button("Edit Shortcut") {
                    NotificationCenter.default.post(name: .editShortcut, object: nil)
                }
                .keyboardShortcut("e", modifiers: [.command])
                
                Button("Delete Shortcut") {
                    NotificationCenter.default.post(name: .deleteShortcut, object: nil)
                }
                .keyboardShortcut(.delete, modifiers: [.command])
                
                Divider()
                
                Button("Duplicate Shortcut") {
                    NotificationCenter.default.post(name: .duplicateShortcut, object: nil)
                }
                .keyboardShortcut("d", modifiers: [.command])
            }
            
            CommandMenu("Shortcuts") {
                Button("Capture Shortcut...") {
                    NotificationCenter.default.post(name: .captureShortcut, object: nil)
                }
                .keyboardShortcut("k", modifiers: [.command, .shift])
                
                Button("Add to Favorites") {
                    NotificationCenter.default.post(name: .toggleFavorite, object: nil)
                }
                .keyboardShortcut("f", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Import Shortcuts...") {
                    NotificationCenter.default.post(name: .importShortcuts, object: nil)
                }
                
                Button("Export Shortcuts...") {
                    NotificationCenter.default.post(name: .exportShortcuts, object: nil)
                }
            }
        }
    }
    
    private func setupMenuBarIfNeeded() {
        if UserDefaults.standard.bool(forKey: "enableMenuBar") {
            menuBarManager.setup(with: AppModel.shared)
        }
    }
}

// MARK: - Thread-safe Menu Bar Manager

@MainActor
class MenuBarManager: ObservableObject {
    @Published var isSetup: Bool = false
    private var globalHotkeyManager: GlobalHotkeyManager?
    private let lock = NSLock()
    
    func setup(with appModel: AppModel) {
        lock.lock()
        defer { lock.unlock() }
        
        // Ensure only one instance exists
        if globalHotkeyManager == nil {
            globalHotkeyManager = GlobalHotkeyManager(appModel: appModel)
            isSetup = true
        }
    }
    
    func tearDown() {
        lock.lock()
        defer { lock.unlock() }
        
        globalHotkeyManager?.enableMenuBar(false)
        globalHotkeyManager = nil
        isSetup = false
    }
    
    nonisolated private func performTearDown() {
        Task { @MainActor in
            self.tearDown()
        }
    }
    
    deinit {
        performTearDown()
    }
}

extension Notification.Name {
    static let createNewShortcut = Notification.Name("createNewShortcut")
    static let editShortcut = Notification.Name("editShortcut")
    static let deleteShortcut = Notification.Name("deleteShortcut")
    static let duplicateShortcut = Notification.Name("duplicateShortcut")
    static let captureShortcut = Notification.Name("captureShortcut")
    static let toggleFavorite = Notification.Name("toggleFavorite")
    static let importShortcuts = Notification.Name("importShortcuts")
    static let exportShortcuts = Notification.Name("exportShortcuts")
}
