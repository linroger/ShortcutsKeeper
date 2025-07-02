//
//  ContentPaneViews.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/30/25.
//

import SwiftUI
import SwiftData

// MARK: - All Shortcuts View

struct AllShortcutsView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var searchText = ""
    @State private var selectedCategory = "All"
    
    var filteredShortcuts: [Shortcut] {
        var shortcuts = appModel.shortcuts
        
        if !searchText.isEmpty {
            shortcuts = shortcuts.filter { $0.searchableText.localizedCaseInsensitiveContains(searchText) }
        }
        
        if selectedCategory != "All" {
            shortcuts = shortcuts.filter { $0.category == selectedCategory }
        }
        
        return shortcuts.sorted { $0.title < $1.title }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search and filter bar
            HStack {
                TextField("Search shortcuts...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                
                Picker("Category", selection: $selectedCategory) {
                    ForEach(appModel.categories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .frame(maxWidth: 150)
            }
            .padding()
            
            Divider()
            
            // Shortcuts list
            if filteredShortcuts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No shortcuts found")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Try adjusting your search or add some shortcuts")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(filteredShortcuts, selection: $selectedShortcut) { shortcut in
                    ShortcutListRow(shortcut: shortcut, appModel: appModel)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("All Shortcuts (\(filteredShortcuts.count))")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Shortcut") {
                    appModel.showNewShortcutSheet = true
                }
            }
        }
    }
}

// MARK: - App Shortcuts View

struct AppShortcutsView: View {
    let application: Application
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var appShortcuts: [Shortcut] {
        appModel.shortcuts.filter { $0.application == application }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // App header
            HStack {
                if let icon = application.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .cornerRadius(6)
                }
                
                VStack(alignment: .leading) {
                    Text(application.name)
                        .font(.headline)
                    Text("\(appShortcuts.count) shortcuts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Extract Shortcuts") {
                    Task {
                        await appModel.extractShortcutsFromRunningApp(application)
                    }
                }
                .buttonStyle(.bordered)
            }
            .padding()
            
            Divider()
            
            // Shortcuts list
            if appShortcuts.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "keyboard")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    
                    Text("No shortcuts for \(application.name)")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Button("Add Shortcut") {
                        appModel.selectedApplication = application
                        appModel.showNewShortcutSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List(appShortcuts, selection: $selectedShortcut) { shortcut in
                    ShortcutListRow(shortcut: shortcut, appModel: appModel)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle(application.name)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Add Shortcut") {
                    appModel.selectedApplication = application
                    appModel.showNewShortcutSheet = true
                }
            }
        }
    }
}

// MARK: - Tagged Shortcuts View

struct TaggedShortcutsView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var selectedTag: String?
    
    var body: some View {
        NavigationSplitView {
            List(appModel.allTags, id: \.self, selection: $selectedTag) { tag in
                HStack {
                    Image(systemName: "tag.fill")
                        .foregroundColor(.blue)
                    Text(tag)
                    Spacer()
                    let count = appModel.shortcuts.filter { $0.tags.contains(tag) }.count
                    Text("\(count)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Tags")
        } detail: {
            if let tag = selectedTag {
                TagShortcutsDetail(tag: tag, appModel: appModel, selectedShortcut: $selectedShortcut)
            } else {
                VStack {
                    Image(systemName: "tag")
                        .font(.system(size: 48))
                        .foregroundColor(.secondary)
                    Text("Select a tag to view shortcuts")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }
}

struct TagShortcutsDetail: View {
    let tag: String
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var taggedShortcuts: [Shortcut] {
        appModel.shortcuts.filter { $0.tags.contains(tag) }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "tag.fill")
                    .foregroundColor(.blue)
                Text(tag)
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(taggedShortcuts.count) shortcuts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            
            Divider()
            
            List(taggedShortcuts, selection: $selectedShortcut) { shortcut in
                ShortcutListRow(shortcut: shortcut, appModel: appModel)
            }
            .listStyle(.plain)
        }
        .navigationTitle("Tag: \(tag)")
    }
}

// MARK: - App Selection View

struct AppSelectionView: View {
    @Bindable var appModel: AppModel
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.grid.2x2")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("Select an Application")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Choose an app from the sidebar to view its shortcuts")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            if appModel.filteredApplications.isEmpty {
                Button("Scan for Applications") {
                    Task {
                        await appModel.scanForAllApplications()
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Bin View

struct BinView: View {
    @Bindable var appModel: AppModel
    @State private var showingRestoreAlert = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "person.circle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("User Profile")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Manage your shortcuts and preferences")
                    .foregroundColor(.secondary)
            }
            
            VStack(spacing: 12) {
                HStack {
                    Text("Total Shortcuts:")
                    Spacer()
                    Text("\(appModel.shortcuts.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Applications:")
                    Spacer()
                    Text("\(appModel.applications.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Favorite Shortcuts:")
                    Spacer()
                    Text("\(appModel.shortcuts.filter { $0.isFavorite }.count)")
                        .fontWeight(.semibold)
                }
                
                HStack {
                    Text("Hidden Apps:")
                    Spacer()
                    Text("\(appModel.hiddenApplications.count)")
                        .fontWeight(.semibold)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            .cornerRadius(8)
            
            if !appModel.hiddenApplications.isEmpty {
                Button("Restore All Hidden Apps") {
                    showingRestoreAlert = true
                }
                .buttonStyle(.bordered)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .alert("Restore Hidden Apps", isPresented: $showingRestoreAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Restore All") {
                appModel.restoreAllHiddenApplications()
            }
        } message: {
            Text("This will make all hidden applications visible in the sidebar again.")
        }
    }
}

// MARK: - Shortcut List Row

struct ShortcutListRow: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    @State private var isHovered = false
    
    var body: some View {
        HStack(spacing: 12) {
            // App icon
            if let app = shortcut.application,
               let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .cornerRadius(4)
            } else {
                Image(systemName: "app")
                    .frame(width: 20, height: 20)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(shortcut.title)
                        .font(.system(.body, weight: .medium))
                        .lineLimit(1)
                    
                    if shortcut.isFavorite {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.yellow)
                    }
                }
                
                Text(shortcut.shortcutDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                if !shortcut.tags.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(shortcut.tags.prefix(3), id: \.self) { tag in
                            Text(tag)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(4)
                        }
                        if shortcut.tags.count > 3 {
                            Text("+\(shortcut.tags.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Spacer()
            
            // Key combination
            Text(shortcut.keyCombination)
                .font(.system(.callout, design: .monospaced))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(6)
        }
        .padding(.vertical, 6)
        .background(isHovered ? Color.accentColor.opacity(0.05) : Color.clear)
        .cornerRadius(8)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            Button("Edit") {
                // Edit shortcut action
            }
            
            Button("Duplicate") {
                appModel.duplicateShortcut(shortcut)
            }
            
            Button(shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites") {
                appModel.toggleFavorite(shortcut)
            }
            
            Divider()
            
            Button("Delete", role: .destructive) {
                appModel.deleteShortcut(shortcut)
            }
        }
    }
}