//
//  AccessibilityShortcutExtractor.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import AppKit
import ApplicationServices

struct ShortcutInfo {
    let title: String
    let keyCombination: String
    let description: String
    let category: String
}

class AccessibilityShortcutExtractor {
    
    func checkAccessibilityPermissions() -> Bool {
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true]
        return AXIsProcessTrustedWithOptions(options as CFDictionary)
    }
    
    func extractShortcuts(from bundleIdentifier: String) async -> [ShortcutInfo] {
        guard checkAccessibilityPermissions() else {
            print("Accessibility permissions not granted")
            return []
        }
        
        // First, check if the app is running
        let runningApps = NSWorkspace.shared.runningApplications
        let targetApp = runningApps.first { $0.bundleIdentifier == bundleIdentifier }
        
        var shouldTerminateAfter = false
        var app: NSRunningApplication?
        
        if let runningApp = targetApp {
            app = runningApp
        } else {
            // Launch the app temporarily
            if let launchedApp = await launchAppTemporarily(bundleIdentifier: bundleIdentifier) {
                app = launchedApp
                shouldTerminateAfter = true
            }
        }
        
        guard let runningApp = app else {
            print("Could not launch or find app with bundle identifier: \(bundleIdentifier)")
            return []
        }
        
        // Wait a moment for the app to fully load
        try? await Task.sleep(nanoseconds: 2_000_000_000) // 2 seconds
        
        let shortcuts = await extractMenuShortcuts(from: runningApp)
        
        // Terminate the app if we launched it
        if shouldTerminateAfter {
            runningApp.terminate()
        }
        
        return shortcuts
    }
    
    private func launchAppTemporarily(bundleIdentifier: String) async -> NSRunningApplication? {
        return await withCheckedContinuation { continuation in
            // Find the app URL first
            if let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier) {
                let configuration = NSWorkspace.OpenConfiguration()
                configuration.activates = false
                configuration.hides = true
                
                NSWorkspace.shared.openApplication(at: appURL, configuration: configuration) { app, error in
                    if let error = error {
                        print("Failed to launch app: \(error)")
                        continuation.resume(returning: nil)
                    } else {
                        // Wait a moment and then check for the launched app
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            let runningApps = NSWorkspace.shared.runningApplications
                            let launchedApp = runningApps.first { $0.bundleIdentifier == bundleIdentifier }
                            continuation.resume(returning: launchedApp)
                        }
                    }
                }
            } else {
                continuation.resume(returning: nil)
            }
        }
    }
    
    private func extractMenuShortcuts(from app: NSRunningApplication) async -> [ShortcutInfo] {
        let appElement = AXUIElementCreateApplication(app.processIdentifier)
        
        var shortcuts: [ShortcutInfo] = []
        
        // Get the menu bar
        var menuBarValue: AnyObject?
        let menuBarResult = AXUIElementCopyAttributeValue(appElement, kAXMenuBarAttribute as CFString, &menuBarValue)
        
        guard menuBarResult == .success, let menuBar = menuBarValue else {
            return []
        }
        
        // Get menu bar children (top-level menus)
        var childrenValue: AnyObject?
        let childrenResult = AXUIElementCopyAttributeValue(menuBar as! AXUIElement, kAXChildrenAttribute as CFString, &childrenValue)
        
        guard childrenResult == .success,
              let children = childrenValue as? [AXUIElement] else {
            return []
        }
        
        // Process each top-level menu
        for menu in children {
            let menuShortcuts = await extractShortcutsFromMenu(menu, category: "Menu")
            shortcuts.append(contentsOf: menuShortcuts)
        }
        
        return shortcuts
    }
    
    private func extractShortcutsFromMenu(_ menu: AXUIElement, category: String) async -> [ShortcutInfo] {
        var shortcuts: [ShortcutInfo] = []
        
        // Get menu title
        var titleValue: AnyObject?
        AXUIElementCopyAttributeValue(menu, kAXTitleAttribute as CFString, &titleValue)
        let menuTitle = titleValue as? String ?? category
        
        // Get menu items
        var childrenValue: AnyObject?
        let childrenResult = AXUIElementCopyAttributeValue(menu, kAXChildrenAttribute as CFString, &childrenValue)
        
        guard childrenResult == .success,
              let children = childrenValue as? [AXUIElement] else {
            return []
        }
        
        for child in children {
            // Check if this is a menu item
            var roleValue: AnyObject?
            AXUIElementCopyAttributeValue(child, kAXRoleAttribute as CFString, &roleValue)
            
            if let role = roleValue as? String, role == kAXMenuItemRole {
                if let shortcut = extractShortcutFromMenuItem(child, category: menuTitle) {
                    shortcuts.append(shortcut)
                }
            }
            
            // Check for submenus
            var submenuValue: AnyObject?
            let submenuResult = AXUIElementCopyAttributeValue(child, kAXChildrenAttribute as CFString, &submenuValue)
            
            if submenuResult == .success, let submenu = submenuValue as? [AXUIElement], !submenu.isEmpty {
                let submenuShortcuts = await extractShortcutsFromMenu(submenu[0], category: menuTitle)
                shortcuts.append(contentsOf: submenuShortcuts)
            }
        }
        
        return shortcuts
    }
    
    private func extractShortcutFromMenuItem(_ menuItem: AXUIElement, category: String) -> ShortcutInfo? {
        // Get menu item title
        var titleValue: AnyObject?
        AXUIElementCopyAttributeValue(menuItem, kAXTitleAttribute as CFString, &titleValue)
        guard let title = titleValue as? String, !title.isEmpty else { return nil }
        
        // Get keyboard shortcut
        var shortcutValue: AnyObject?
        let shortcutResult = AXUIElementCopyAttributeValue(menuItem, kAXMenuItemCmdCharAttribute as CFString, &shortcutValue)
        
        var modifiersValue: AnyObject?
        let modifiersResult = AXUIElementCopyAttributeValue(menuItem, kAXMenuItemCmdModifiersAttribute as CFString, &modifiersValue)
        
        guard shortcutResult == .success, 
              let shortcutChar = shortcutValue as? String,
              !shortcutChar.isEmpty,
              modifiersResult == .success,
              let modifiers = modifiersValue as? Int else {
            return nil
        }
        
        let keyCombination = formatKeyCombination(character: shortcutChar, modifiers: modifiers)
        
        return ShortcutInfo(
            title: title,
            keyCombination: keyCombination,
            description: "Menu item from \(category)",
            category: category
        )
    }
    
    private func formatKeyCombination(character: String, modifiers: Int) -> String {
        var result = ""
        
        // Check modifier flags
        if modifiers & (1 << 17) != 0 { // kAXMenuItemModifierControl
            result += "⌃"
        }
        if modifiers & (1 << 19) != 0 { // kAXMenuItemModifierOption
            result += "⌥"
        }
        if modifiers & (1 << 18) != 0 { // kAXMenuItemModifierShift
            result += "⇧"
        }
        if modifiers & (1 << 20) != 0 { // kAXMenuItemModifierCommand
            result += "⌘"
        }
        
        result += character.uppercased()
        
        return result
    }
    
    // MARK: - Common Shortcuts Database
    
    func getCommonShortcuts(for bundleIdentifier: String) -> [ShortcutInfo] {
        return commonShortcutsDatabase[bundleIdentifier] ?? []
    }
    
    private let commonShortcutsDatabase: [String: [ShortcutInfo]] = [
        "com.apple.finder": [
            ShortcutInfo(title: "New Folder", keyCombination: "⌘⇧N", description: "Create a new folder", category: "File"),
            ShortcutInfo(title: "Get Info", keyCombination: "⌘I", description: "Show file information", category: "File"),
            ShortcutInfo(title: "Quick Look", keyCombination: "Space", description: "Preview selected item", category: "View"),
            ShortcutInfo(title: "Show/Hide Hidden Files", keyCombination: "⌘⇧.", description: "Toggle hidden file visibility", category: "View")
        ],
        "com.apple.Safari": [
            ShortcutInfo(title: "New Tab", keyCombination: "⌘T", description: "Open a new tab", category: "Tab"),
            ShortcutInfo(title: "Close Tab", keyCombination: "⌘W", description: "Close current tab", category: "Tab"),
            ShortcutInfo(title: "Reopen Last Closed Tab", keyCombination: "⌘⇧T", description: "Restore recently closed tab", category: "Tab"),
            ShortcutInfo(title: "Private Browsing", keyCombination: "⌘⇧N", description: "Open private browsing window", category: "Window")
        ],
        "com.microsoft.VSCode": [
            ShortcutInfo(title: "Command Palette", keyCombination: "⌘⇧P", description: "Open command palette", category: "General"),
            ShortcutInfo(title: "Quick Open", keyCombination: "⌘P", description: "Quick file search", category: "Navigation"),
            ShortcutInfo(title: "Toggle Terminal", keyCombination: "⌃`", description: "Show/hide integrated terminal", category: "View"),
            ShortcutInfo(title: "Format Document", keyCombination: "⌥⇧F", description: "Format entire document", category: "Edit")
        ],
        "com.apple.dt.Xcode": [
            ShortcutInfo(title: "Build", keyCombination: "⌘B", description: "Build the project", category: "Product"),
            ShortcutInfo(title: "Run", keyCombination: "⌘R", description: "Build and run", category: "Product"),
            ShortcutInfo(title: "Test", keyCombination: "⌘U", description: "Run tests", category: "Product"),
            ShortcutInfo(title: "Quick Open", keyCombination: "⌘⇧O", description: "Open quickly", category: "Navigation")
        ]
    ]
}