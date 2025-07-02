//
//  DragDropShortcutView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let shortcut = UTType(exportedAs: "com.shortcutskeeper.shortcut")
}

struct DragDropShortcutListView: View {
    let shortcuts: [Shortcut]
    @Binding var selection: Shortcut?
    let appModel: AppModel
    @State private var draggedShortcut: Shortcut?
    
    var body: some View {
        List(selection: $selection) {
            ForEach(shortcuts) { shortcut in
                DragDropShortcutRow(
                    shortcut: shortcut, 
                    appModel: appModel,
                    isSelected: selection?.id == shortcut.id
                )
                .tag(shortcut)
                .onDrag {
                    draggedShortcut = shortcut
                    return NSItemProvider(object: shortcut.title as NSString)
                }
            }
            .onMove(perform: moveShortcuts)
        }
        .listStyle(.inset(alternatesRowBackgrounds: true))
        .onDrop(of: [.text], delegate: ShortcutDropDelegate(
            shortcuts: shortcuts,
            appModel: appModel,
            draggedShortcut: $draggedShortcut
        ))
    }
    
    private func moveShortcuts(from source: IndexSet, to destination: Int) {
        // Implement reordering logic
        // This would require adding an order field to the Shortcut model
        print("Moving shortcuts from \(source) to \(destination)")
    }
}

struct DragDropShortcutRow: View {
    let shortcut: Shortcut
    let appModel: AppModel
    let isSelected: Bool
    @State private var isHovered = false
    
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
            
            HStack(spacing: 8) {
                Text(shortcut.category)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(4)
                
                if isHovered {
                    Menu {
                        contextMenuItems
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                }
            }
        }
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
        )
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            contextMenuItems
        }
    }
    
    @ViewBuilder
    private var contextMenuItems: some View {
        Button(action: { appModel.copyShortcutToClipboard(shortcut) }) {
            Label("Copy Shortcut", systemImage: "doc.on.doc")
        }
        
        Button(action: { appModel.toggleFavorite(shortcut) }) {
            Label(shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                  systemImage: shortcut.isFavorite ? "star.slash" : "star")
        }
        
        Divider()
        
        Button(action: { appModel.duplicateShortcut(shortcut) }) {
            Label("Duplicate", systemImage: "plus.square.on.square")
        }
        
        Button(action: { /* Edit shortcut */ }) {
            Label("Edit", systemImage: "pencil")
        }
        
        Divider()
        
        Button(role: .destructive, action: { appModel.deleteShortcut(shortcut) }) {
            Label("Delete", systemImage: "trash")
        }
    }
}

struct ShortcutDropDelegate: DropDelegate {
    let shortcuts: [Shortcut]
    let appModel: AppModel
    @Binding var draggedShortcut: Shortcut?
    
    func performDrop(info: DropInfo) -> Bool {
        draggedShortcut = nil
        return true
    }
    
    func dropEntered(info: DropInfo) {
        // Visual feedback when entering drop zone
    }
    
    func dropExited(info: DropInfo) {
        // Clean up visual feedback
    }
    
    func validateDrop(info: DropInfo) -> Bool {
        return info.hasItemsConforming(to: [.text])
    }
}

// MARK: - Clipboard Support

extension AppModel {
    func pasteShortcutFromClipboard(to application: Application) {
        let pasteboard = NSPasteboard.general
        
        guard let string = pasteboard.string(forType: .string) else { return }
        
        // Try to parse the clipboard content as a shortcut
        if let parsedShortcut = parseShortcutFromString(string) {
            addShortcut(
                title: parsedShortcut.title,
                keyCombination: parsedShortcut.keyCombination,
                description: parsedShortcut.description,
                category: parsedShortcut.category,
                application: application,
                tags: []
            )
        }
    }
    
    private func parseShortcutFromString(_ string: String) -> (title: String, keyCombination: String, description: String, category: String)? {
        // Simple parsing - expects format like "Title: ⌘A"
        let components = string.components(separatedBy: ": ")
        guard components.count >= 2 else { return nil }
        
        let title = components[0].trimmingCharacters(in: .whitespaces)
        let keyCombination = components[1].trimmingCharacters(in: .whitespaces)
        
        return (
            title: title,
            keyCombination: keyCombination,
            description: "Imported from clipboard",
            category: "Imported"
        )
    }
}

// MARK: - Export Support

extension AppModel {
    func exportShortcutsAsText(for application: Application) -> String {
        let appShortcuts = shortcuts.filter { $0.application == application }
        
        var result = "# \(application.name) Shortcuts\n\n"
        
        let groupedShortcuts = Dictionary(grouping: appShortcuts) { $0.category }
        
        for (category, shortcuts) in groupedShortcuts.sorted(by: { $0.key < $1.key }) {
            result += "## \(category)\n\n"
            
            for shortcut in shortcuts.sorted(by: { $0.title < $1.title }) {
                result += "- **\(shortcut.title)**: `\(shortcut.keyCombination)`"
                if !shortcut.shortcutDescription.isEmpty {
                    result += " - \(shortcut.shortcutDescription)"
                }
                result += "\n"
            }
            result += "\n"
        }
        
        return result
    }
    
    func exportShortcutsAsCSV(for application: Application) -> String {
        let appShortcuts = shortcuts.filter { $0.application == application }
        
        var csv = "Title,Shortcut,Description,Category,Favorite\n"
        
        for shortcut in appShortcuts.sorted(by: { $0.title < $1.title }) {
            let title = shortcut.title.replacingOccurrences(of: "\"", with: "\"\"")
            let description = shortcut.shortcutDescription.replacingOccurrences(of: "\"", with: "\"\"")
            let category = shortcut.category.replacingOccurrences(of: "\"", with: "\"\"")
            
            csv += "\"\(title)\",\"\(shortcut.keyCombination)\",\"\(description)\",\"\(category)\",\(shortcut.isFavorite)\n"
        }
        
        return csv
    }
}