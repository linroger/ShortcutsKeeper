//
//  FilteredTableShortcutListView.swift
//  ShortcutsKeeper
//
//  Created by Claude on 7/4/25.
//

import SwiftUI

// MARK: - Filtered Table View for App-specific shortcuts

struct FilteredTableShortcutListView: View {
    let shortcuts: [Shortcut]
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var sortOrder = [KeyPathComparator(\Shortcut.title)]
    @State private var selection: Shortcut.ID?
    
    var sortedShortcuts: [Shortcut] {
        shortcuts.sorted(using: sortOrder)
    }
    
    var body: some View {
        Table(sortedShortcuts, selection: $selection, sortOrder: $sortOrder) {
            // Keys column with custom ordering
            TableColumn("Shortcut") { shortcut in
                EnhancedKeyDisplayView(
                    keyCombination: shortcut.keyCombination,
                    style: .compact,
                    ordered: true
                )
                .padding(.vertical, 4)
            }
            .width(min: 120, ideal: 180)
            
            // Title and Description column
            TableColumn("Command") { shortcut in
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
            .width(min: 200, ideal: 300)
            
            // Tags column
            TableColumn("Tags") { shortcut in
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
            .width(min: 150, ideal: 200)
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