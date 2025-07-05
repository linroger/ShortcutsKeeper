//
//  ApplicationDetailView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct ApplicationDetailView: View {
    let application: Application
    let viewModel: ShortcutsViewModel
    @State private var selectedShortcut: Shortcut?
    @State private var appInfo: ApplicationInfo = ApplicationInfo()
    
    private var shortcuts: [Shortcut] {
        viewModel.shortcuts
            .filter { $0.application == application }
            .sorted { $0.title < $1.title }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // App header
            ApplicationHeaderView(application: application, appInfo: appInfo, viewModel: viewModel)
                .padding()
                .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Shortcuts list
            if shortcuts.isEmpty {
                EmptyShortcutsView(application: application, viewModel: viewModel)
            } else {
                ShortcutTableView(shortcuts: shortcuts, 
                                selection: $selectedShortcut,
                                viewModel: viewModel)
            }
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup {
                Button(action: { addShortcut() }) {
                    Label("Add Shortcut", systemImage: "plus")
                }
                
                Menu {
                    Button("Export Shortcuts...") {
                        exportAppShortcuts()
                    }
                    
                    Divider()
                    
                    Button("Open in Finder") {
                        viewModel.openApplicationInFinder(application)
                    }
                    
                    Button("Launch Application") {
                        viewModel.launchApplication(application)
                    }
                } label: {
                    Label("Actions", systemImage: "ellipsis.circle")
                }
            }
        }
        .onAppear {
            appInfo = viewModel.getApplicationInfo(application)
        }
    }
    
    private func addShortcut() {
        viewModel.selectedApplication = application
        viewModel.showNewShortcutSheet = true
    }
    
    private func exportAppShortcuts() {
        // Export only this app's shortcuts
        let _ = viewModel.shortcuts.filter { $0.application == application }
        // TODO: Implementation for export
    }
}

struct ApplicationHeaderView: View {
    let application: Application
    let appInfo: ApplicationInfo
    let viewModel: ShortcutsViewModel
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 64, height: 64)
                    .cornerRadius(12)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 48))
                    .frame(width: 64, height: 64)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(application.name)
                    .font(.title)
                    .fontWeight(.semibold)
                
                HStack(spacing: 12) {
                    if !appInfo.version.isEmpty {
                        Label(appInfo.version, systemImage: "info.circle")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if !appInfo.path.isEmpty {
                        Button(action: { viewModel.openApplicationInFinder(application) }) {
                            Label("Show in Finder", systemImage: "folder")
                                .font(.caption)
                        }
                        .buttonStyle(.plain)
                        .foregroundColor(.accentColor)
                    }
                }
                
                if !appInfo.path.isEmpty {
                    Text(appInfo.path)
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .lineLimit(1)
                        .truncationMode(.middle)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("\(viewModel.shortcuts.filter { $0.application == application }.count)")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Shortcuts")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct EmptyShortcutsView: View {
    let application: Application
    let viewModel: ShortcutsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No shortcuts for \(application.name)")
                .font(.title2)
                .foregroundColor(.secondary)
            
            Text("Add keyboard shortcuts to keep track of them")
                .foregroundColor(.secondary)
            
            Button("Add First Shortcut") {
                viewModel.selectedApplication = application
                viewModel.showNewShortcutSheet = true
            }
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct ShortcutTableView: View {
    let shortcuts: [Shortcut]
    @Binding var selection: Shortcut?
    let viewModel: ShortcutsViewModel
    
    var body: some View {
        List(selection: $selection) {
            ForEach(shortcuts) { shortcut in
                ShortcutTableRow(shortcut: shortcut, viewModel: viewModel)
                    .tag(shortcut)
            }
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
    }
}

struct ShortcutTableRow: View {
    let shortcut: Shortcut
    let viewModel: ShortcutsViewModel
    
    var body: some View {
        HStack {
            ShortcutKeyView(keyCombination: shortcut.keyCombination)
                .frame(minWidth: 100, maxWidth: 150)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(shortcut.title)
                        .fontWeight(.medium)
                    if shortcut.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                if !shortcut.shortcutDescription.isEmpty {
                    Text(shortcut.shortcutDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(shortcut.category)
                .font(.caption)
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
        .contextMenu {
            Button(action: { viewModel.toggleFavorite(shortcut) }) {
                Label(shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: shortcut.isFavorite ? "star.slash" : "star")
            }
            
            Button(action: { viewModel.editingShortcut = shortcut }) {
                Label("Edit", systemImage: "pencil")
            }
            
            Divider()
            
            Button(role: .destructive, action: { viewModel.deleteShortcut(shortcut) }) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

struct EmptyApplicationView: View {
    let viewModel: ShortcutsViewModel
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Welcome to ShortcutsKeeper")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Text("Select an application from the sidebar or scan for applications to get started")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
            
            if viewModel.applications.isEmpty {
                Button("Scan for Applications") {
                    viewModel.scanForAllApplications()
                }
                .controlSize(.large)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}