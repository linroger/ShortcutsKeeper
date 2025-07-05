//
//  EnhancedSettingsView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct EnhancedSettingsView: View {
    @Bindable var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    
    // Settings from screenshots
    @AppStorage("globalShortcut") private var globalShortcut = "⌘⌥K"
    @AppStorage("globalShortcutBehavior") private var globalShortcutBehavior = GlobalBehavior.bringToFront
    @AppStorage("appTheme") private var appTheme = AppTheme.system
    @AppStorage("displayInMenuBar") private var displayInMenuBar = false
    @AppStorage("openAtLogin") private var openAtLogin = false
    @AppStorage("displayInDock") private var displayInDock = true
    @AppStorage("useTableView") private var useTableView = false
    
    // Key Display Customization Settings
    @AppStorage("keyDisplaySize") private var keyDisplaySize: Double = 1.0
    @AppStorage("keyVerticalPadding") private var keyVerticalPadding: Double = 6.0
    @AppStorage("keyHorizontalPadding") private var keyHorizontalPadding: Double = 10.0
    
    @State private var showingChangeShortcutAlert = false
    @State private var showingClearAllAlert = false
    
    enum GlobalBehavior: String, CaseIterable {
        case bringToFront = "Bring to Front"
        case openMenuBar = "Open Menu Bar Menu"
    }
    
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
            // Global Shortcut Section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Text("Global Shortcut:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text(globalShortcut)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(NSColor.controlBackgroundColor))
                        .cornerRadius(6)
                    
                    Button("Change...") {
                        showingChangeShortcutAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("Set default") {
                        globalShortcut = "⌘⌥K"
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("Use this to quickly call Shortcut Keeper and check your shortcuts, even while using another app.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Global Shortcut Behavior Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Global Shortcut Behavior:")
                    .font(.body)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(GlobalBehavior.allCases, id: \.self) { behavior in
                        HStack {
                            Button(action: {
                                globalShortcutBehavior = behavior
                            }) {
                                Image(systemName: globalShortcutBehavior == behavior ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(globalShortcutBehavior == behavior ? .accentColor : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            Text(behavior.rawValue)
                                .font(.body)
                            
                            Spacer()
                        }
                    }
                }
                
                Text("Select what hitting the global shortcut will do.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Theme Section
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme:")
                    .font(.body)
                    .fontWeight(.medium)
                
                HStack(spacing: 16) {
                    ForEach(AppTheme.allCases, id: \.self) { theme in
                        HStack {
                            Button(action: {
                                appTheme = theme
                            }) {
                                Image(systemName: appTheme == theme ? "largecircle.fill.circle" : "circle")
                                    .foregroundColor(appTheme == theme ? .accentColor : .secondary)
                            }
                            .buttonStyle(.plain)
                            
                            Text(theme.rawValue)
                                .font(.body)
                        }
                    }
                }
                
                Text("Select your preferred app theme.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // View Style Section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Shortcut Display Style:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Picker("", selection: $useTableView) {
                        Text("Card View").tag(false)
                        Text("Table View").tag(true)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 200)
                }
                
                Text("Choose between a modern card-based layout or a compact table view for displaying shortcuts.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Key Display Customization Section
            VStack(alignment: .leading, spacing: 16) {
                Text("Key Display Customization")
                    .font(.body)
                    .fontWeight(.medium)
                
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Key Size:")
                                .font(.body)
                            Spacer()
                            Text("\(Int(keyDisplaySize * 100))%")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $keyDisplaySize, in: 0.5...2.0, step: 0.1) {
                            Text("Key Size")
                        }
                        .accentColor(.blue)
                        
                        Text("Adjust the overall size of keyboard shortcut keys.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Vertical Padding:")
                                .font(.body)
                            Spacer()
                            Text("\(Int(keyVerticalPadding))pt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $keyVerticalPadding, in: 2...20, step: 1) {
                            Text("Vertical Padding")
                        }
                        .accentColor(.green)
                        
                        Text("Control the spacing above and below the key text.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Horizontal Padding:")
                                .font(.body)
                            Spacer()
                            Text("\(Int(keyHorizontalPadding))pt")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Slider(value: $keyHorizontalPadding, in: 4...30, step: 1) {
                            Text("Horizontal Padding")
                        }
                        .accentColor(.orange)
                        
                        Text("Control the spacing to the left and right of the key text.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Preview Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Preview:")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        HStack {
                            CustomizableKeyDisplayView(
                                keyCombination: "⌘⇧K",
                                size: keyDisplaySize,
                                verticalPadding: keyVerticalPadding,
                                horizontalPadding: keyHorizontalPadding
                            )
                            
                            CustomizableKeyDisplayView(
                                keyCombination: "⌃⌥F12",
                                size: keyDisplaySize,
                                verticalPadding: keyVerticalPadding,
                                horizontalPadding: keyHorizontalPadding
                            )
                            
                            Spacer()
                        }
                    }
                }
            }
            
            // System Integration Section
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Display in the Menu Bar:")
                            .font(.body)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Toggle("", isOn: $displayInMenuBar)
                            .toggleStyle(.switch)
                    }
                    
                    Text("Enable/disable the menu bar icon. Clicking on the icon in the menu bar will display the shortcuts you have saved for the current app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("Open at login:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Toggle("", isOn: $openAtLogin)
                        .toggleStyle(.switch)
                }
                
                Text("Enable/disable Shortcut Keeper to start automatically when you log in to your Mac.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 8)
                
                HStack {
                    Text("Display in the Dock:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Toggle("", isOn: $displayInDock)
                        .toggleStyle(.switch)
                }
                
                Text("Show/hide the Shortcut Keeper icon in your Mac's Dock.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Data Management Section
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Export all Shortcuts to:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    HStack {
                        Button("JSON") {
                            exportShortcuts(format: .json)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("CSV") {
                            exportShortcuts(format: .csv)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Text("Export all your Shortcuts to a file on your Mac. Use the import option below, to add them again to the app.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Import Shortcuts from:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    HStack {
                        Button("JSON") {
                            importShortcuts(format: .json)
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("CSV") {
                            importShortcuts(format: .csv)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Text("Import Shortcuts from a previously saved JSON or CSV file. The imported Shortcuts will be merged with your current ones.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Clear All Shortcuts Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Clear All Shortcuts:")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Button("Clear All Shortcuts") {
                        showingClearAllAlert = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.regular)
                    .tint(.red)
                    
                    Text("⚠️ This will permanently delete ALL shortcuts. This action cannot be undone.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            }
        }
        .padding(24)
        .frame(width: 600, height: 500)
        .alert("Change Global Shortcut", isPresented: $showingChangeShortcutAlert) {
            TextField("Shortcut", text: $globalShortcut)
            Button("Cancel", role: .cancel) { }
            Button("Save") { }
        } message: {
            Text("Enter a new global shortcut (e.g., ⌘⌥K)")
        }
        .alert("Clear All Shortcuts", isPresented: $showingClearAllAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Clear All", role: .destructive) {
                appModel.clearAllShortcuts()
            }
        } message: {
            Text("This will permanently delete all \(appModel.shortcuts.count) shortcuts. This action cannot be undone.")
        }
    }
    
    // MARK: - Helper Functions
    
    private func exportShortcuts(format: ExportFormat) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = format == .json ? [.json] : [.commaSeparatedText]
        panel.nameFieldStringValue = "Shortcuts.\(format == .json ? "json" : "csv")"
        
        if panel.runModal() == .OK, let url = panel.url {
            if format == .csv {
                let csvContent = appModel.exportShortcutsToCSV()
                do {
                    try csvContent.write(to: url, atomically: true, encoding: .utf8)
                    print("Successfully exported \(appModel.shortcuts.count) shortcuts to CSV")
                } catch {
                    print("Export failed: \(error)")
                }
            } else {
                // JSON export not implemented yet
                print("JSON export not yet implemented")
            }
        }
    }
    
    private func importShortcuts(format: ExportFormat) {
        let panel = NSOpenPanel()
        panel.allowedContentTypes = format == .json ? [.json] : [.commaSeparatedText]
        panel.allowsMultipleSelection = false
        
        if panel.runModal() == .OK, let url = panel.urls.first {
            if format == .csv {
                do {
                    let csvContent = try String(contentsOf: url, encoding: .utf8)
                    print("Importing from file: \(url)")
                    
                    Task {
                        do {
                            let result = try await appModel.importShortcutsFromCSV(csvContent)
                            await MainActor.run {
                                print("Import complete: \(result.imported) imported, \(result.skipped) skipped")
                                // Optionally show an alert with the results
                            }
                        } catch {
                            print("Import failed: \(error)")
                        }
                    }
                } catch {
                    print("Failed to read file: \(error)")
                }
            } else {
                // JSON import not implemented yet
                print("JSON import not yet implemented")
            }
        }
    }
}

#Preview {
    EnhancedSettingsView(appModel: AppModel.shared)
}