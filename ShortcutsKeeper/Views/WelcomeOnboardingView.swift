//
//  WelcomeOnboardingView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/30/25.
//

import SwiftUI

struct WelcomeOnboardingView: View {
    @Bindable var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var deleteExampleShortcuts = false
    @State private var currentStep = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)
                    
                    Text("Welcome to Shortcut Keeper!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                }
                
                // Main content
                VStack(spacing: 24) {
                    // Instructions
                    VStack(spacing: 12) {
                        HStack {
                            Text("Use the")
                            Image(systemName: "plus.square")
                                .foregroundColor(.accentColor)
                            Text("button at the top right to add your first shortcut.")
                        }
                        .font(.body)
                        
                        HStack {
                            Text("Use")
                            Text("Command-Option-K")
                                .font(.system(.body, design: .monospaced))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(NSColor.controlBackgroundColor))
                                .cornerRadius(4)
                            Text("(⌘⌥K) to call forward at any time and check your shortcuts.")
                        }
                        .font(.body)
                        
                        Text("We have added a few shortcuts below to get you started. You can delete them if you want.")
                            .font(.body)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Example shortcuts section
                    VStack(spacing: 16) {
                        HStack {
                            Toggle("Delete example shortcuts", isOn: $deleteExampleShortcuts)
                            Spacer()
                            Button("OK, got it!") {
                                if deleteExampleShortcuts {
                                    removeExampleShortcuts()
                                }
                                dismiss()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                        
                        // Example shortcuts preview
                        VStack(spacing: 8) {
                            ExampleShortcutRow(
                                app: "Shortcut Keeper",
                                icon: "keyboard",
                                keyCombo: "Command-N",
                                description: "Add a new Shortcut",
                                tags: "add, shortcuts"
                            )
                            
                            ExampleShortcutRow(
                                app: "macOS",
                                icon: "apple.logo",
                                keyCombo: "Control-Command-Space",
                                description: "Insert emojis 😀",
                                tags: "text, work"
                            )
                            
                            ExampleShortcutRow(
                                app: "macOS",
                                icon: "apple.logo",
                                keyCombo: "Shift-Command-5",
                                description: "Open the Screenshot utility",
                                tags: "screengrab, work"
                            )
                            
                            ExampleShortcutRow(
                                app: "macOS",
                                icon: "apple.logo",
                                keyCombo: "Command-Space",
                                description: "Open Spotlight Search",
                                tags: "search, work, productivity"
                            )
                            
                            ExampleShortcutRow(
                                app: "Safari",
                                icon: "safari",
                                keyCombo: "Command-T",
                                description: "Open new tab",
                                tags: "browser, productivity"
                            )
                        }
                        .padding()
                        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(32)
            .frame(width: 600, height: 500)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            addExampleShortcuts()
        }
    }
    
    private func addExampleShortcuts() {
        // Only add if there are no shortcuts yet
        guard appModel.shortcuts.isEmpty else { return }
        
        // Create or find applications
        let shortcutKeeperApp = findOrCreateApp(name: "Shortcut Keeper", bundleId: "com.example.shortcutkeeper")
        let macOSApp = findOrCreateApp(name: "macOS", bundleId: "com.apple.system")
        let safariApp = findOrCreateApp(name: "Safari", bundleId: "com.apple.Safari")
        
        // Add example shortcuts
        let exampleShortcuts = [
            ("Add a new Shortcut", "Command-N", "add, shortcuts", shortcutKeeperApp),
            ("Insert emojis 😀", "Control-Command-Space", "text, work", macOSApp),
            ("Open the Screenshot utility", "Shift-Command-5", "screengrab, work", macOSApp),
            ("Open Spotlight Search", "Command-Space", "search, work, productivity", macOSApp),
            ("Open new tab", "Command-T", "browser, productivity", safariApp)
        ]
        
        for (title, keyCombo, tags, app) in exampleShortcuts {
            appModel.addShortcut(
                title: title,
                keyCombination: keyCombo,
                description: title,
                category: "Example",
                application: app,
                tags: tags.components(separatedBy: ", ")
            )
        }
    }
    
    private func removeExampleShortcuts() {
        let exampleShortcuts = appModel.shortcuts.filter { $0.category == "Example" }
        for shortcut in exampleShortcuts {
            appModel.deleteShortcut(shortcut)
        }
    }
    
    private func findOrCreateApp(name: String, bundleId: String) -> Application {
        if let existingApp = appModel.applications.first(where: { $0.name == name }) {
            return existingApp
        }
        
        let newApp = Application(name: name, bundleIdentifier: bundleId)
        appModel.applications.append(newApp)
        return newApp
    }
}

struct ExampleShortcutRow: View {
    let app: String
    let icon: String
    let keyCombo: String
    let description: String
    let tags: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .frame(width: 20, height: 20)
                .foregroundColor(.accentColor)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(description)
                    .font(.system(.body, weight: .medium))
                
                HStack(spacing: 4) {
                    ForEach(tags.components(separatedBy: ", ").prefix(3), id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 1)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(3)
                    }
                }
            }
            
            Spacer()
            
            Text(keyCombo)
                .font(.system(.callout, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    WelcomeOnboardingView(appModel: AppModel.shared)
}