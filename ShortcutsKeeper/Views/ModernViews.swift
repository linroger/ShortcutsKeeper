//
//  ModernViews.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import AppKit

// MARK: - Modern Sidebar View

struct ModernApplicationSidebarView: View {
    @Bindable var appModel: AppModel
    @AppStorage("showSystemApps") private var showSystemApps = true
    @AppStorage("enableMenuBar") private var enableMenuBar = false
    
    var body: some View {
        VStack(spacing: 0) {
            // App List
            List(selection: $appModel.selectedApplication) {
                if appModel.isScanning {
                    HStack(spacing: 12) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Scanning for applications...")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 12)
                    .listRowSeparator(.hidden)
                }
                
                ForEach(appModel.filteredApplications) { app in
                    ModernApplicationSidebarRow(
                        application: app, 
                        shortcutCount: appModel.shortcuts.filter { $0.application == app }.count
                    )
                    .tag(app)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 4, leading: 16, bottom: 4, trailing: 16))
                    .contextMenu {
                        Button("Hide \(app.name)") {
                            appModel.hideApplication(app)
                        }
                        
                        Divider()
                        
                        Button("Open in Finder") {
                            appModel.openApplicationInFinder(app)
                        }
                        
                        Button("Launch Application") {
                            appModel.launchApplication(app)
                        }
                        
                        Divider()
                        
                        Button("Extract Shortcuts") {
                            Task {
                                await appModel.extractShortcutsFromRunningApp(app)
                            }
                        }
                    }
                }
                
                if appModel.filteredApplications.isEmpty && !appModel.isScanning {
                    VStack(spacing: 16) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        VStack(spacing: 8) {
                            Text("No applications found")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Scan your system to discover installed applications")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        
                        Button("Scan for Applications") {
                            Task {
                                await appModel.scanForAllApplications()
                            }
                        }
                        .controlSize(.large)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
        }
        .background(
            VisualEffectView(material: .sidebar, blendingMode: .behindWindow)
                .ignoresSafeArea(.all)
        )
        .clipShape(RoundedRectangle(cornerRadius: 0))
    }
}

struct ModernApplicationSidebarRow: View {
    let application: Application
    let shortcutCount: Int
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // App Icon
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0.5)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 36, height: 36)
                    .overlay(
                        Image(systemName: "app.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.accentColor)
                    )
            }
            
            // App Info
            VStack(alignment: .leading, spacing: 3) {
                Text(application.name)
                    .font(.system(.body, design: .default))
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .truncationMode(.tail)
                
                HStack(spacing: 4) {
                    Text("\(shortcutCount)")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(shortcutCount > 0 ? .accentColor : .secondary)
                    
                    Text(shortcutCount == 1 ? "shortcut" : "shortcuts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer(minLength: 8)
            
            // System App Indicator
            if application.isSystemApp {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .opacity(0.7)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isHovered ? Color.accentColor.opacity(0.08) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Modern Detail Views

struct ModernApplicationDetailView: View {
    let application: Application
    let appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var appInfo: ApplicationInfo = ApplicationInfo()
    
    var body: some View {
        VStack(spacing: 0) {
            // App Header
            ModernApplicationHeaderView(application: application, appInfo: appInfo, appModel: appModel)
                .padding(.horizontal, 24)
                .padding(.vertical, 20)
                .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            
            Divider()
            
            // Content Area
            Group {
                if appModel.filteredShortcuts.isEmpty {
                    ModernEmptyShortcutsView(application: application, appModel: appModel)
                } else {
                    VStack(spacing: 0) {
                        // Shortcuts Header
                        HStack {
                            Text("Keyboard Shortcuts")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(appModel.filteredShortcuts.count) shortcuts")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        
                        Divider()
                        
                        // Shortcuts List
                        DragDropShortcutListView(
                            shortcuts: appModel.filteredShortcuts, 
                            selection: $selectedShortcut,
                            appModel: appModel
                        )
                        .padding(.horizontal, 8)
                    }
                }
            }
        }
        .navigationTitle("")
        .onAppear {
            appInfo = appModel.getApplicationInfo(application)
        }
        .onChange(of: selectedShortcut) { oldValue, newValue in
            if let shortcut = newValue {
                NotificationCenter.default.post(
                    name: .selectedShortcutChanged, 
                    object: shortcut
                )
            }
        }
    }
    
    private func exportAsText() {
        let text = appModel.exportShortcutsAsText(for: application)
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.plainText]
        savePanel.nameFieldStringValue = "\(application.name) Shortcuts.txt"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? text.write(to: url, atomically: true, encoding: .utf8)
        }
    }
    
    private func exportAsCSV() {
        let csv = appModel.exportShortcutsAsCSV(for: application)
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.commaSeparatedText]
        savePanel.nameFieldStringValue = "\(application.name) Shortcuts.csv"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? csv.write(to: url, atomically: true, encoding: .utf8)
        }
    }
}

struct ModernApplicationHeaderView: View {
    let application: Application
    let appInfo: ApplicationInfo
    let appModel: AppModel
    
    var body: some View {
        HStack(spacing: 20) {
            // App Icon
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .cornerRadius(16)
                    .shadow(color: .black.opacity(0.15), radius: 4, x: 0, y: 2)
            } else {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.accentColor.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .overlay(
                        Image(systemName: "app.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.accentColor)
                    )
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            }
            
            // App Info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Text(application.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .lineLimit(2)
                    
                    if application.isSystemApp {
                        Image(systemName: "checkmark.seal.fill")
                            .foregroundColor(.blue)
                            .font(.title3)
                    }
                }
                
                HStack(spacing: 16) {
                    if !appInfo.version.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "info.circle")
                                .foregroundColor(.secondary)
                            Text("Version \(appInfo.version)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !appInfo.path.isEmpty {
                        Button(action: { appModel.openApplicationInFinder(application) }) {
                            HStack(spacing: 4) {
                                Image(systemName: "folder")
                                Text("Show in Finder")
                            }
                            .font(.subheadline)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
                
                if !appInfo.path.isEmpty {
                    Text(appInfo.path)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                        .frame(maxWidth: 300, alignment: .leading)
                }
            }
            
            Spacer()
            
            // Shortcut Count
            VStack(alignment: .trailing, spacing: 6) {
                Text("\(appModel.filteredShortcuts.count)")
                    .font(.system(.largeTitle, design: .rounded))
                    .fontWeight(.bold)
                    .foregroundColor(.accentColor)
                
                Text("Shortcuts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)
            }
        }
    }
}

struct ModernEmptyShortcutsView: View {
    let application: Application
    let appModel: AppModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("No shortcuts for \(application.name)")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Text("Add keyboard shortcuts to keep track of them")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            HStack(spacing: 12) {
                Button("Add Shortcut") {
                    appModel.selectedApplication = application
                    appModel.showNewShortcutSheet = true
                }
                .controlSize(.large)
                
                Button("Extract Shortcuts") {
                    Task {
                        await appModel.extractShortcutsFromRunningApp(application)
                    }
                }
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ModernEmptyApplicationView: View {
    let appModel: AppModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Welcome to ShortcutsKeeper")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Select an application from the sidebar or scan for applications to get started")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: 400)
            }
            
            if appModel.filteredApplications.isEmpty {
                Button("Scan for Applications") {
                    Task {
                        await appModel.scanForAllApplications()
                    }
                }
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Modern Sheet Views

struct ModernNewShortcutView: View {
    @Bindable var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var title = ""
    @State private var keyCombination = ""
    @State private var description = ""
    @State private var category = "General"
    @State private var selectedApplication: Application?
    @State private var tags = ""
    @State private var isCapturing = false
    
    // Dropdown selection states
    @State private var useDropdowns = false
    @State private var hasCommand = false
    @State private var hasShift = false
    @State private var hasOption = false
    @State private var hasControl = false
    @State private var selectedKey = "A"
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("New Shortcut")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            .padding()
            
            Divider()
            
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Toggle between capture and dropdown modes
                        Picker("Input Method", selection: $useDropdowns) {
                            Text("Capture Shortcut").tag(false)
                            Text("Select Keys").tag(true)
                        }
                        .pickerStyle(.segmented)
                        
                        if useDropdowns {
                            ModernShortcutDropdownPicker(
                                hasCommand: $hasCommand,
                                hasShift: $hasShift,
                                hasOption: $hasOption,
                                hasControl: $hasControl,
                                selectedKey: $selectedKey,
                                keyCombination: $keyCombination
                            )
                        } else {
                            HStack {
                                TextField("Keyboard Shortcut", text: $keyCombination)
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(isCapturing)
                                
                                Button(action: captureShortcut) {
                                    Label(isCapturing ? "Capturing..." : "Capture", 
                                          systemImage: "keyboard")
                                }
                                .disabled(isCapturing)
                            }
                        }
                    }
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Section("Organization") {
                    Picker("Application", selection: $selectedApplication) {
                        Text("None").tag(nil as Application?)
                        ForEach(appModel.applications.sorted(by: { $0.name < $1.name })) { app in
                            HStack {
                                if let icon = app.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                }
                                Text(app.name)
                            }
                            .tag(app as Application?)
                        }
                    }
                    
                    TextField("Category", text: $category)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Tags (comma separated)", text: $tags)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            Divider()
            
            // Footer
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
                
                Spacer()
                
                Button("Add Shortcut") {
                    saveShortcut()
                }
                .keyboardShortcut(.return)
                .disabled(title.isEmpty || keyCombination.isEmpty)
                .buttonStyle(.borderedProminent)
            }
            .padding()
        }
        .frame(width: 500, height: 500)
        .onAppear {
            // Auto-select the currently selected application from sidebar if available
            if let currentApp = appModel.selectedApplication {
                selectedApplication = currentApp
            }
        }
    }
    
    private func captureShortcut() {
        isCapturing = true
        // TODO: Implement shortcut capture functionality
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isCapturing = false
        }
    }
    
    private func saveShortcut() {
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        // Create new shortcut
        let shortcut = Shortcut(
            title: title,
            keyCombination: keyCombination,
            shortcutDescription: description,
            category: category,
            application: selectedApplication,
            tags: tagArray
        )
        
        // Insert into SwiftData context
        modelContext.insert(shortcut)
        
        // Save context
        do {
            try modelContext.save()
            appModel.fetchData() // Refresh the app model
        } catch {
            print("Error saving shortcut: \(error)")
        }
        
        dismiss()
    }
}

struct ModernShortcutCaptureView: View {
    let appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ShortcutCaptureView(viewModel: ShortcutsViewModel()) // Temporary wrapper
            .onDisappear {
                appModel.fetchData()
            }
    }
}

struct ModernSettingsView: View {
    let appModel: AppModel
    
    var body: some View {
        SettingsView(viewModel: ShortcutsViewModel()) // Temporary wrapper
    }
}

struct ModernShortcutDetailView: View {
    let shortcut: Shortcut
    let appModel: AppModel
    
    var body: some View {
        ShortcutDetailView(shortcut: shortcut, viewModel: ShortcutsViewModel()) // Temporary wrapper
    }
}

struct ModernShortcutDropdownPicker: View {
    @Binding var hasCommand: Bool
    @Binding var hasShift: Bool
    @Binding var hasOption: Bool
    @Binding var hasControl: Bool
    @Binding var selectedKey: String
    @Binding var keyCombination: String
    
    private let availableKeys = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        "Space", "↩", "⇥", "⌫", "⎋", "←", "→", "↑", "↓", "↖", "↘", "⇞", "⇟"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Modifier Keys:")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                Toggle("⌘ Command", isOn: $hasCommand)
                    .toggleStyle(.checkbox)
                
                Toggle("⇧ Shift", isOn: $hasShift)
                    .toggleStyle(.checkbox)
                
                Toggle("⌥ Option", isOn: $hasOption)
                    .toggleStyle(.checkbox)
                
                Toggle("⌃ Control", isOn: $hasControl)
                    .toggleStyle(.checkbox)
            }
            
            Text("Select Key:")
                .font(.headline)
            
            Picker("Key", selection: $selectedKey) {
                ForEach(availableKeys, id: \.self) { key in
                    Text(key).tag(key)
                }
            }
            .pickerStyle(.menu)
            
            if !keyCombination.isEmpty {
                HStack {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(keyCombination)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .onChange(of: hasCommand) { _, _ in updateKeyCombination() }
        .onChange(of: hasShift) { _, _ in updateKeyCombination() }
        .onChange(of: hasOption) { _, _ in updateKeyCombination() }
        .onChange(of: hasControl) { _, _ in updateKeyCombination() }
        .onChange(of: selectedKey) { _, _ in updateKeyCombination() }
        .onAppear { updateKeyCombination() }
    }
    
    private func updateKeyCombination() {
        var modifiers: [String] = []
        
        if hasCommand { modifiers.append("⌘") }
        if hasControl { modifiers.append("⌃") }
        if hasOption { modifiers.append("⌥") }
        if hasShift { modifiers.append("⇧") }
        
        keyCombination = modifiers.joined() + selectedKey
    }
}

// MARK: - Visual Effect View for Translucent Background

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode
    
    func makeNSView(context: Context) -> NSVisualEffectView {
        let visualEffectView = NSVisualEffectView()
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
        visualEffectView.state = .active
        visualEffectView.wantsLayer = true
        visualEffectView.layer?.cornerRadius = 0
        return visualEffectView
    }
    
    func updateNSView(_ visualEffectView: NSVisualEffectView, context: Context) {
        visualEffectView.material = material
        visualEffectView.blendingMode = blendingMode
    }
}