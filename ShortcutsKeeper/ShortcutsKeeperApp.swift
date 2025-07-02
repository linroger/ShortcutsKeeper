//
//  ShortcutsKeeperApp.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import SwiftData

@main
struct ShortcutsKeeperApp: App {
    @State private var menuBarManager: GlobalHotkeyManager?
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Shortcut.self,
            Application.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Handle migration issues by clearing the database
            print("Migration failed, creating fresh database: \(error)")
            
            // Clear the existing database
            let storeURL = modelConfiguration.url
            try? FileManager.default.removeItem(at: storeURL)
            try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("wal"))
            try? FileManager.default.removeItem(at: storeURL.appendingPathExtension("shm"))
            
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after clearing: \(error)")
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
            menuBarManager = GlobalHotkeyManager(appModel: AppModel.shared)
        }
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
