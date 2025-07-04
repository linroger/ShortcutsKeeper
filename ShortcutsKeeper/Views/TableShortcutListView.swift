//
//  TableShortcutListView.swift
//  ShortcutsKeeper
//
//  Created by Claude on 7/4/25.
//

import SwiftUI

// MARK: - Table-based Shortcut List View

struct TableShortcutListView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var sortOrder = [KeyPathComparator(\Shortcut.title)]
    @State private var selection: Shortcut.ID?
    
    var sortedShortcuts: [Shortcut] {
        let filtered = appModel.shortcuts.filter { !($0.isDeleted ?? false) }
        
        if appModel.searchText.isEmpty {
            return filtered.sorted(using: sortOrder)
        } else {
            return filtered.filter { 
                $0.searchableText.localizedCaseInsensitiveContains(appModel.searchText) 
            }.sorted(using: sortOrder)
        }
    }
    
    var body: some View {
        Table(sortedShortcuts, selection: $selection, sortOrder: $sortOrder) {
            // Keys column
            TableColumn("Shortcut") { shortcut in
                KeyColumnView(shortcut: shortcut)
            }
            .width(min: 120, ideal: 180)
            
            // Title and Description column
            TableColumn("Command") { shortcut in
                CommandColumnView(shortcut: shortcut)
            }
            .width(min: 200, ideal: 300)
            
            // Tags column
            TableColumn("Tags") { shortcut in
                TagsColumnView(shortcut: shortcut)
            }
            .width(min: 150, ideal: 200)
            
            // Application column
            TableColumn("Application") { shortcut in
                ApplicationColumnView(shortcut: shortcut)
            }
            .width(min: 120, ideal: 180)
        }
        .tableStyle(.inset(alternatesRowBackgrounds: false))
        .onChange(of: selection) { _, newSelection in
            if let selectedId = newSelection,
               let shortcut = sortedShortcuts.first(where: { $0.id == selectedId }) {
                selectedShortcut = shortcut
                NotificationCenter.default.post(
                    name: .selectedShortcutChanged,
                    object: shortcut
                )
            }
        }
        .contextMenu(forSelectionType: Shortcut.ID.self) { selectedIds in
            if let selectedId = selectedIds.first,
               let shortcut = sortedShortcuts.first(where: { $0.id == selectedId }) {
                TableContextMenu(shortcut: shortcut, appModel: appModel)
            }
        }
    }
}

// MARK: - Column Views

struct KeyColumnView: View {
    let shortcut: Shortcut
    
    var body: some View {
        EnhancedKeyDisplayView(
            keyCombination: shortcut.keyCombination,
            style: .compact,
            ordered: true
        )
        .padding(.vertical, 4)
    }
}

struct CommandColumnView: View {
    let shortcut: Shortcut
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 6) {
                Text(shortcut.title)
                    .font(.system(.body, design: .default, weight: .medium))
                    .lineLimit(1)
                
                if shortcut.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundColor(.yellow)
                }
            }
            
            if !shortcut.description.isEmpty && shortcut.description != shortcut.title {
                Text(shortcut.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 6)
    }
}

struct TagsColumnView: View {
    let shortcut: Shortcut
    
    var body: some View {
        HStack(spacing: 4) {
            if shortcut.category != "General" {
                MiniCategoryTag(category: shortcut.category)
            }
            
            ForEach(shortcut.tags.prefix(2), id: \.self) { tag in
                MiniTagLabel(tag: tag)
            }
            
            if shortcut.tags.count > 2 {
                Text("+\(shortcut.tags.count - 2)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct ApplicationColumnView: View {
    let shortcut: Shortcut
    
    var body: some View {
        if let app = shortcut.application {
            HStack(spacing: 6) {
                AppIconView(application: app, size: 16)
                
                Text(app.name)
                    .font(.system(.body))
                    .lineLimit(1)
            }
            .padding(.vertical, 4)
        }
    }
}

// MARK: - Supporting Views

struct MiniCategoryTag: View {
    let category: String
    
    var body: some View {
        Text(category)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.purple.opacity(0.15))
            .foregroundColor(.purple)
            .clipShape(Capsule())
    }
}

struct MiniTagLabel: View {
    let tag: String
    
    var body: some View {
        Text(tag)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(.orange.opacity(0.15))
            .foregroundColor(.orange)
            .clipShape(Capsule())
    }
}

struct TableContextMenu: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    
    var body: some View {
        Button {
            appModel.showNewShortcutSheet = true
        } label: {
            Label("Add New Shortcut", systemImage: "plus")
        }
        
        Divider()
        
        Button {
            // Edit shortcut action
        } label: {
            Label("Edit Shortcut", systemImage: "pencil")
        }
        
        Button {
            appModel.duplicateShortcut(shortcut)
        } label: {
            Label("Duplicate Shortcut", systemImage: "doc.on.doc")
        }
        
        Button {
            appModel.toggleFavorite(shortcut)
        } label: {
            Label(
                shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: shortcut.isFavorite ? "star.slash" : "star"
            )
        }
        
        Divider()
        
        Button(role: .destructive) {
            appModel.deleteShortcut(shortcut)
        } label: {
            Label("Delete Shortcut", systemImage: "trash")
        }
    }
}

// MARK: - Preview

#Preview {
    TableShortcutListView(
        appModel: AppModel.shared,
        selectedShortcut: Binding.constant(nil)
    )
    .frame(width: 800, height: 600)
}