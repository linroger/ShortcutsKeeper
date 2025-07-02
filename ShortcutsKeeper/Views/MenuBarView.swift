//
//  MenuBarView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import AppKit

class MenuBarController: NSObject {
    private var statusItem: NSStatusItem?
    private var popover: NSPopover?
    private let appModel: AppModel
    
    init(appModel: AppModel) {
        self.appModel = appModel
        super.init()
        setupMenuBar()
    }
    
    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusItem?.button {
            button.image = NSImage(systemSymbolName: "keyboard", accessibilityDescription: "ShortcutsKeeper")
            button.action = #selector(togglePopover)
            button.target = self
        }
        
        setupPopover()
    }
    
    private func setupPopover() {
        popover = NSPopover()
        popover?.contentSize = NSSize(width: 400, height: 500)
        popover?.behavior = .transient
        popover?.contentViewController = NSHostingController(
            rootView: MenuBarContentView(appModel: appModel)
        )
    }
    
    @objc private func togglePopover() {
        guard let popover = popover, let button = statusItem?.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
        }
    }
    
    func hideMenuBar() {
        statusItem = nil
    }
}

struct MenuBarContentView: View {
    let appModel: AppModel
    @State private var searchText = ""
    @State private var selectedApp: Application?
    @Environment(\.dismiss) private var dismiss
    
    private var filteredApps: [Application] {
        if searchText.isEmpty {
            return Array(appModel.filteredApplications.prefix(10))
        } else {
            return appModel.filteredApplications.filter { app in
                app.name.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            if let app = selectedApp {
                appShortcutsView(app)
            } else {
                appListView
            }
        }
        .frame(width: 400, height: 500)
    }
    
    private var headerView: some View {
        HStack {
            if selectedApp != nil {
                Button(action: { selectedApp = nil }) {
                    Image(systemName: "chevron.left")
                }
                .buttonStyle(.plain)
            }
            
            VStack(alignment: .leading) {
                Text(selectedApp?.name ?? "ShortcutsKeeper")
                    .font(.headline)
                
                if selectedApp == nil {
                    Text("Quick Shortcut Reference")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: { 
                NSApp.activate(ignoringOtherApps: true)
                NSWorkspace.shared.open(URL(string: "shortcuts-keeper://")!)
            }) {
                Image(systemName: "arrow.up.right.square")
            }
            .buttonStyle(.plain)
            .help("Open main app")
        }
        .padding()
    }
    
    private var appListView: some View {
        VStack(spacing: 0) {
            SearchField(text: $searchText)
                .padding(.horizontal)
            
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(filteredApps) { app in
                        MenuBarAppRow(app: app) {
                            selectedApp = app
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private func appShortcutsView(_ app: Application) -> some View {
        let shortcuts = appModel.shortcuts.filter { $0.application == app }
        
        return VStack(spacing: 0) {
            if shortcuts.isEmpty {
                EmptyShortcutsMenuView(app: app)
            } else {
                ScrollView {
                    LazyVStack(spacing: 2) {
                        ForEach(shortcuts.prefix(20)) { shortcut in
                            MenuBarShortcutRow(shortcut: shortcut, appModel: appModel)
                        }
                        
                        if shortcuts.count > 20 {
                            Text("... and \(shortcuts.count - 20) more")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

struct MenuBarAppRow: View {
    let app: Application
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 24, height: 24)
                        .cornerRadius(4)
                } else {
                    Image(systemName: "app.fill")
                        .frame(width: 24, height: 24)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.system(.body))
                        .lineLimit(1)
                    
                    let shortcutCount = 0 // Would need to calculate this
                    Text("\(shortcutCount) shortcuts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(Color.clear)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            if hovering {
                NSCursor.pointingHand.push()
            } else {
                NSCursor.pop()
            }
        }
    }
}

struct MenuBarShortcutRow: View {
    let shortcut: Shortcut
    let appModel: AppModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(shortcut.title)
                    .font(.system(.body, design: .default))
                    .lineLimit(1)
                
                if !shortcut.shortcutDescription.isEmpty {
                    Text(shortcut.shortcutDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            HStack(spacing: 4) {
                if shortcut.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
                
                ShortcutKeyView(keyCombination: shortcut.keyCombination)
                    .scaleEffect(0.8)
            }
        }
        .padding(.vertical, 6)
        .padding(.horizontal, 12)
        .onTapGesture {
            appModel.copyShortcutToClipboard(shortcut)
            // Show brief feedback
        }
        .contextMenu {
            Button("Copy Shortcut") {
                appModel.copyShortcutToClipboard(shortcut)
            }
            
            Button(shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                appModel.toggleFavorite(shortcut)
            }
        }
    }
}

struct EmptyShortcutsMenuView: View {
    let app: Application
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "keyboard")
                .font(.system(size: 32))
                .foregroundColor(.secondary)
            
            Text("No shortcuts for \(app.name)")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Open the main app to add shortcuts")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

struct SearchField: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search apps...", text: $text)
                .textFieldStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
        .padding(.bottom, 8)
    }
}

// MARK: - Global Hotkey Support

class GlobalHotkeyManager {
    private var hotkey: HotKey?
    private let appModel: AppModel
    private var menuBarController: MenuBarController?
    
    init(appModel: AppModel) {
        self.appModel = appModel
        self.menuBarController = MenuBarController(appModel: appModel)
        setupGlobalHotkey()
    }
    
    private func setupGlobalHotkey() {
        // Set up a global hotkey (e.g., ⌥⌘K) to show the menu bar
        // This would require a hotkey library or Carbon APIs
        // For now, we'll just set up the menu bar
    }
    
    func enableMenuBar(_ enable: Bool) {
        if enable {
            if menuBarController == nil {
                menuBarController = MenuBarController(appModel: appModel)
            }
        } else {
            menuBarController?.hideMenuBar()
            menuBarController = nil
        }
    }
}

// Simple HotKey placeholder - would need a proper implementation
struct HotKey {
    let keyCode: UInt16
    let modifiers: NSEvent.ModifierFlags
    let action: () -> Void
}