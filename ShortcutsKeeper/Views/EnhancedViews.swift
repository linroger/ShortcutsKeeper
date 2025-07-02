//
//  EnhancedViews.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 7/1/25.
//

import SwiftUI

// MARK: - Enhanced All Shortcuts View

struct EnhancedAllShortcutsView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var sortOption: ShortcutSortOption = .name
    @State private var groupByApp = false
    
    var sortedShortcuts: [Shortcut] {
        let filtered = appModel.shortcuts.filter { !($0.isDeleted ?? false) }
        
        switch sortOption {
        case .name:
            return filtered.sorted { $0.title < $1.title }
        case .app:
            return filtered.sorted { ($0.application?.name ?? "") < ($1.application?.name ?? "") }
        case .recent:
            return filtered.sorted { ($0.dateAdded ?? Date.distantPast) > ($1.dateAdded ?? Date.distantPast) }
        case .frequency:
            return filtered.sorted { ($0.usageCount ?? 0) > ($1.usageCount ?? 0) }
        }
    }
    
    var groupedShortcuts: [String: [Shortcut]] {
        Dictionary(grouping: sortedShortcuts) { shortcut in
            shortcut.application?.name ?? "No Application"
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with controls
            HStack {
                Text("\(sortedShortcuts.count) shortcuts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Menu {
                    ForEach(ShortcutSortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            sortOption = option
                        }
                    }
                    
                    Divider()
                    
                    Toggle("Group by Application", isOn: $groupByApp)
                } label: {
                    HStack {
                        Text("Sort")
                        Image(systemName: "arrow.up.arrow.down")
                    }
                }
                .menuStyle(.borderedButton)
                
                Button(action: { appModel.showNewShortcutSheet = true }) {
                    Label("Add Shortcut", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            // Shortcuts list
            if sortedShortcuts.isEmpty {
                EmptyStateView(
                    icon: "keyboard",
                    title: "No shortcuts yet",
                    subtitle: "Add your first shortcut to get started",
                    action: { appModel.showNewShortcutSheet = true },
                    actionTitle: "Add Shortcut"
                )
            } else {
                List(selection: $selectedShortcut) {
                    if groupByApp {
                        ForEach(groupedShortcuts.keys.sorted(), id: \.self) { appName in
                            Section(appName) {
                                ForEach(groupedShortcuts[appName] ?? []) { shortcut in
                                    EnhancedShortcutRow(shortcut: shortcut, appModel: appModel)
                                        .listRowSeparator(.hidden)
                                        .listRowBackground(Color.clear)
                                }
                            }
                        }
                    } else {
                        ForEach(sortedShortcuts) { shortcut in
                            EnhancedShortcutRow(shortcut: shortcut, appModel: appModel)
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                        }
                    }
                }
                .listStyle(.plain)
                .background(.regularMaterial)
            }
        }
    }
}

// MARK: - Enhanced App Shortcuts View

struct EnhancedAppShortcutsView: View {
    let application: Application
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var appShortcuts: [Shortcut] {
        appModel.shortcuts.filter { 
            $0.application == application && !($0.isDeleted ?? false)
        }.sorted { $0.title < $1.title }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // App header
            HStack {
                if let icon = application.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "app")
                                .foregroundColor(.white)
                        )
                }
                
                VStack(alignment: .leading) {
                    Text(application.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Text("\(appShortcuts.count) shortcuts")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Extract Shortcuts") {
                    Task {
                        await appModel.extractShortcutsFromRunningApp(application)
                    }
                }
                .buttonStyle(.bordered)
                
                Button(action: { appModel.showNewShortcutSheet = true }) {
                    Label("Add Shortcut", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            // Shortcuts list
            if appShortcuts.isEmpty {
                EmptyStateView(
                    icon: "keyboard",
                    title: "No shortcuts for \(application.name)",
                    subtitle: "Add shortcuts for this application or extract them automatically",
                    action: { appModel.showNewShortcutSheet = true },
                    actionTitle: "Add Shortcut"
                )
            } else {
                List(selection: $selectedShortcut) {
                    ForEach(appShortcuts) { shortcut in
                        EnhancedShortcutRow(shortcut: shortcut, appModel: appModel, showAppName: false)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .background(.regularMaterial)
            }
        }
    }
}

// MARK: - Enhanced Tagged Shortcuts View

struct EnhancedTaggedShortcutsView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var taggedShortcuts: [String: [Shortcut]] {
        let allShortcuts = appModel.shortcuts.filter { !($0.isDeleted ?? false) }
        var grouped: [String: [Shortcut]] = [:]
        
        for shortcut in allShortcuts {
            for tag in shortcut.tags {
                if grouped[tag] == nil {
                    grouped[tag] = []
                }
                grouped[tag]?.append(shortcut)
            }
        }
        
        return grouped
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(taggedShortcuts.keys.count) tags")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            if taggedShortcuts.isEmpty {
                EmptyStateView(
                    icon: "tag",
                    title: "No tagged shortcuts",
                    subtitle: "Add tags to your shortcuts to organize them better"
                )
            } else {
                List(selection: $selectedShortcut) {
                    ForEach(taggedShortcuts.keys.sorted(), id: \.self) { tag in
                        Section {
                            ForEach(taggedShortcuts[tag] ?? []) { shortcut in
                                EnhancedShortcutRow(shortcut: shortcut, appModel: appModel)
                                    .listRowSeparator(.hidden)
                                    .listRowBackground(Color.clear)
                            }
                        } header: {
                            HStack {
                                Image(systemName: "tag.fill")
                                    .foregroundColor(.orange)
                                Text(tag)
                                Text("(\((taggedShortcuts[tag] ?? []).count))")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .listStyle(.plain)
                .background(.regularMaterial)
            }
        }
    }
}

// MARK: - Enhanced Bin View

struct EnhancedBinView: View {
    @Bindable var appModel: AppModel
    @State private var showEmptyConfirmation = false
    
    var deletedShortcuts: [Shortcut] {
        appModel.shortcuts.filter { $0.isDeleted ?? false }.sorted { $0.dateDeleted ?? Date() > $1.dateDeleted ?? Date() }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("\(deletedShortcuts.count) deleted shortcuts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !deletedShortcuts.isEmpty {
                    Button("Empty Bin") {
                        showEmptyConfirmation = true
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
            }
            .padding()
            .background(.regularMaterial)
            
            Divider()
            
            if deletedShortcuts.isEmpty {
                EmptyStateView(
                    icon: "trash",
                    title: "Bin is empty",
                    subtitle: "Deleted shortcuts will appear here and be automatically removed after 30 days"
                )
            } else {
                List {
                    ForEach(deletedShortcuts) { shortcut in
                        DeletedShortcutRow(shortcut: shortcut, appModel: appModel)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .background(.regularMaterial)
            }
        }
        .alert("Empty Bin", isPresented: $showEmptyConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Empty Bin", role: .destructive) {
                for shortcut in deletedShortcuts {
                    appModel.permanentlyDeleteShortcut(shortcut)
                }
            }
        } message: {
            Text("This will permanently delete all shortcuts in the bin. This action cannot be undone.")
        }
    }
}

// MARK: - Helper Extensions

extension String {
    func readableKeyDescription() -> String {
        let readable = self
            .replacingOccurrences(of: "⌘", with: "Command")
            .replacingOccurrences(of: "⌥", with: "Option")
            .replacingOccurrences(of: "⌃", with: "Control")
            .replacingOccurrences(of: "⇧", with: "Shift")
            .replacingOccurrences(of: "⎋", with: "Escape")
            .replacingOccurrences(of: "⇥", with: "Tab")
            .replacingOccurrences(of: "↩", with: "Return")
            .replacingOccurrences(of: "⌫", with: "Delete")
            .replacingOccurrences(of: "⌦", with: "Forward Delete")
            .replacingOccurrences(of: "⇞", with: "Page Up")
            .replacingOccurrences(of: "⇟", with: "Page Down")
            .replacingOccurrences(of: "↖", with: "Home")
            .replacingOccurrences(of: "↘", with: "End")
            .replacingOccurrences(of: "←", with: "Left Arrow")
            .replacingOccurrences(of: "→", with: "Right Arrow")
            .replacingOccurrences(of: "↑", with: "Up Arrow")
            .replacingOccurrences(of: "↓", with: "Down Arrow")
        
        // Split by spaces and join with " + "
        let components = readable.components(separatedBy: " ").filter { !$0.isEmpty }
        return components.joined(separator: " + ")
    }
    
    func keyComponents() -> [String] {
        var components: [String] = []
        var currentKey = ""
        
        for char in self {
            switch char {
            case "⌘":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⌘")
            case "⌥":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⌥")
            case "⌃":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⌃")
            case "⇧":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⇧")
            case "⎋":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⎋")
            case "⇥":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⇥")
            case "↩":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("↩")
            case "⌫":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⌫")
            case "⌦":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⌦")
            case "⇞":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⇞")
            case "⇟":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("⇟")
            case "↖":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("↖")
            case "↘":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("↘")
            case "←":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("←")
            case "→":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("→")
            case "↑":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("↑")
            case "↓":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                }
                components.append("↓")
            case " ":
                if !currentKey.isEmpty {
                    components.append(currentKey)
                    currentKey = ""
                } else {
                    // This is a space character by itself
                    components.append("Space")
                }
            default:
                currentKey.append(char)
            }
        }
        
        // Add any remaining key
        if !currentKey.isEmpty {
            components.append(currentKey)
        }
        
        // Handle special case where space might be written as a word
        components = components.map { component in
            if component.lowercased() == "space" {
                return "Space"
            }
            return component
        }
        
        return components
    }
    
    func keyBackgroundColor(for key: String) -> Color {
        // Modifier keys - cddefd
        if ["⌘", "⌥", "⌃", "⇧"].contains(key) {
            return Color(red: 0.804, green: 0.871, blue: 0.992) // #cddefd
        }
        
        // Space key - dfcfea
        if key == "Space" {
            return Color(red: 0.875, green: 0.812, blue: 0.918) // #dfcfea
        }
        
        // Special keys like arrows, tab, etc. - dfcfea
        if ["⎋", "⇥", "↩", "⌫", "⌦", "⇞", "⇟", "↖", "↘", "←", "→", "↑", "↓"].contains(key) {
            return Color(red: 0.875, green: 0.812, blue: 0.918) // #dfcfea
        }
        
        // Caps Lock - ffe0ed
        if key.lowercased() == "caps lock" || key.lowercased() == "capslock" {
            return Color(red: 1.0, green: 0.878, blue: 0.929) // #ffe0ed
        }
        
        // Numbers - ffe0c7
        if key.rangeOfCharacter(from: CharacterSet.decimalDigits) != nil && key.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil {
            return Color(red: 1.0, green: 0.878, blue: 0.780) // #ffe0c7
        }
        
        // Letters - cef3e3
        if key.count == 1 && key.rangeOfCharacter(from: CharacterSet.letters) != nil {
            return Color(red: 0.808, green: 0.953, blue: 0.890) // #cef3e3
        }
        
        // Default for other keys
        return Color(NSColor.controlBackgroundColor)
    }
}

// MARK: - Enhanced Shortcut Row

struct EnhancedShortcutRow: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    var showAppName: Bool = true
    @State private var isHovered = false
    @State private var isSelected = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                // App icon (if showing app name)
                if showAppName, let app = shortcut.application {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .clipShape(RoundedRectangle(cornerRadius: 5))
                    } else {
                        Image(systemName: "app")
                            .frame(width: 24, height: 24)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    // Shortcut title
                    Text(shortcut.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .lineLimit(1)
                    
                    // Description if different from title
                    if !shortcut.description.isEmpty && shortcut.description != shortcut.title {
                        Text(shortcut.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                    }
                    
                    // Tags and app info
                    HStack(spacing: 8) {
                        if showAppName, let app = shortcut.application {
                            Text(app.name)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.15))
                                .foregroundColor(.blue)
                                .clipShape(Capsule())
                        }
                        
                        ForEach(shortcut.tags.prefix(2), id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.orange.opacity(0.15))
                                .foregroundColor(.orange)
                                .clipShape(Capsule())
                        }
                        
                        if shortcut.tags.count > 2 {
                            Text("+\(shortcut.tags.count - 2)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    // Key combination as individual buttons
                    VStack(alignment: .trailing, spacing: 6) {
                        // Individual key buttons
                        HStack(spacing: 6) {
                            ForEach(Array(shortcut.keyCombination.keyComponents().enumerated()), id: \.offset) { index, key in
                                if index > 0 {
                                    Text("+")
                                        .font(.system(.caption, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 4)
                                }
                                
                                Text(key)
                                    .font(.system(.callout, design: .monospaced))
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(shortcut.keyCombination.keyBackgroundColor(for: key))
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 6)
                                            .stroke(Color.secondary.opacity(0.4), lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 1, x: 0, y: 1)
                            }
                        }
                        
                        // Readable key description
                        Text(shortcut.keyCombination.readableKeyDescription())
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    if let usageCount = shortcut.usageCount, usageCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption2)
                            Text("\(usageCount)")
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            // Action buttons (visible on hover)
            if isHovered {
                Divider()
                    .padding(.horizontal, 8)
                
                HStack(spacing: 8) {
                    Spacer()
                    
                    Button(action: { /* Edit shortcut */ }) {
                        HStack(spacing: 4) {
                            Image(systemName: "pencil")
                            Text("Edit")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    
                    Button(action: { appModel.deleteShortcut(shortcut) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "trash")
                            Text("Delete")
                        }
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .foregroundColor(.red)
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    isSelected ? 
                    Color.accentColor.opacity(0.3) :
                    Color(NSColor.controlBackgroundColor).opacity(isHovered ? 0.8 : 0.3)
                )
                .stroke(
                    isSelected ? 
                    Color.accentColor.opacity(0.6) : 
                    Color.clear, 
                    lineWidth: 2
                )
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isSelected.toggle()
            }
        }
        .contextMenu {
            Button {
                appModel.showNewShortcutSheet = true
            } label: {
                Label("Add New Shortcut", systemImage: "plus")
            }
            
            Divider()
            
            Button {
                // Edit shortcut
                // This would need to be implemented in AppModel
            } label: {
                Label("Edit Shortcut", systemImage: "pencil")
            }
            
            Button {
                appModel.duplicateShortcut(shortcut)
            } label: {
                Label("Duplicate Shortcut", systemImage: "doc.on.doc")
            }
            
            Menu {
                ForEach(appModel.applications, id: \.self) { app in
                    if app != shortcut.application {
                        Button {
                            appModel.moveShortcut(shortcut, to: app)
                        } label: {
                            HStack {
                                if let icon = app.icon {
                                    Image(nsImage: icon)
                                        .resizable()
                                        .frame(width: 16, height: 16)
                                } else {
                                    Image(systemName: "app")
                                        .frame(width: 16, height: 16)
                                }
                                Text(app.name)
                            }
                        }
                    }
                }
            } label: {
                Label("Move to App", systemImage: "arrow.right.circle")
            }
            
            Divider()
            
            Button(role: .destructive) {
                appModel.deleteShortcut(shortcut)
            } label: {
                Label("Delete Shortcut", systemImage: "trash")
            }
        }
    }
}

struct DeletedShortcutRow: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    
    var daysInBin: Int {
        guard let deleteDate = shortcut.dateDeleted else { return 0 }
        return Calendar.current.dateComponents([.day], from: deleteDate, to: Date()).day ?? 0
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.title)
                    .font(.headline)
                    .strikethrough()
                    .foregroundColor(.secondary)
                
                Text(shortcut.keyCombination)
                    .font(.system(.callout, design: .monospaced))
                    .foregroundColor(.secondary)
                
                Text("Deleted \(daysInBin) days ago")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack {
                Button("Restore") {
                    appModel.restoreShortcut(shortcut)
                }
                .buttonStyle(.bordered)
                
                Button("Delete Forever", role: .destructive) {
                    appModel.permanentlyDeleteShortcut(shortcut)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Empty State View

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            if let action = action, let actionTitle = actionTitle {
                Button(actionTitle, action: action)
                    .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Sort Options

enum ShortcutSortOption: String, CaseIterable {
    case name = "Name"
    case app = "Application"
    case recent = "Recently Added"
    case frequency = "Most Used"
}

#Preview {
    EnhancedAllShortcutsView(appModel: AppModel.shared, selectedShortcut: .constant(nil))
}