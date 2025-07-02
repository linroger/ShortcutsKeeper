//
//  ShortcutListView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct ShortcutListView: View {
    let viewModel: ShortcutsViewModel
    @Binding var selection: Shortcut?
    
    var body: some View {
        List(selection: $selection) {
            if viewModel.filteredShortcuts.isEmpty {
                ContentUnavailableView {
                    Label("No Shortcuts", systemImage: "keyboard")
                } description: {
                    Text("Add shortcuts to start tracking them")
                } actions: {
                    Button("Add Shortcut") {
                        viewModel.showNewShortcutSheet = true
                    }
                }
            } else {
                ForEach(viewModel.filteredShortcuts) { shortcut in
                    ShortcutRow(shortcut: shortcut, viewModel: viewModel)
                        .tag(shortcut)
                }
            }
        }
        .navigationTitle("Shortcuts")
        .navigationSubtitle("\(viewModel.filteredShortcuts.count) shortcuts")
    }
}

struct ShortcutRow: View {
    let shortcut: Shortcut
    let viewModel: ShortcutsViewModel
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(shortcut.title)
                        .font(.headline)
                    
                    if shortcut.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                Text(shortcut.shortcutDescription)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                ShortcutKeyView(keyCombination: shortcut.keyCombination)
                
                if let app = shortcut.application {
                    HStack(spacing: 4) {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 16, height: 16)
                        }
                        Text(app.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
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

struct ShortcutKeyView: View {
    let keyCombination: String
    
    private var keyComponents: [KeyComponent] {
        parseKeyCombination(keyCombination)
    }
    
    var body: some View {
        HStack(spacing: 3) {
            ForEach(keyComponents.indices, id: \.self) { index in
                KeyCap(component: keyComponents[index])
            }
        }
    }
    
    private func parseKeyCombination(_ combo: String) -> [KeyComponent] {
        var components: [KeyComponent] = []
        var remaining = combo
        
        // Parse modifiers in order
        let modifiers = [
            ("⌘", "Command", Color.blue),
            ("⌃", "Control", Color.orange), 
            ("⌥", "Option", Color.green),
            ("⇧", "Shift", Color.purple)
        ]
        
        for (symbol, name, color) in modifiers {
            if remaining.contains(symbol) {
                components.append(KeyComponent(symbol: symbol, name: name, color: color, isModifier: true))
                remaining = remaining.replacingOccurrences(of: symbol, with: "")
            }
        }
        
        // Add the main key
        if !remaining.isEmpty {
            let mainKey = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
            let keyColor = getKeyColor(for: mainKey)
            components.append(KeyComponent(symbol: mainKey, name: mainKey, color: keyColor, isModifier: false))
        }
        
        return components
    }
    
    private func getKeyColor(for key: String) -> Color {
        switch key {
        case "F1"..."F12":
            return .indigo
        case "↩", "⇥", "⌫", "⎋": // Return, Tab, Delete, Escape
            return .red
        case "←", "→", "↑", "↓": // Arrow keys
            return .teal
        case "Space":
            return .gray
        default:
            return .primary
        }
    }
}

struct KeyComponent {
    let symbol: String
    let name: String
    let color: Color
    let isModifier: Bool
}

struct KeyCap: View {
    let component: KeyComponent
    @State private var isPressed = false
    
    var body: some View {
        Text(component.symbol)
            .font(.system(.caption, design: .rounded, weight: .medium))
            .foregroundColor(component.isModifier ? .white : component.color)
            .padding(.horizontal, component.isModifier ? 6 : 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        component.isModifier ? 
                        AnyShapeStyle(component.color.gradient) :
                        AnyShapeStyle(Color.secondary.opacity(0.15))
                    )
                    .shadow(
                        color: isPressed ? .clear : .black.opacity(0.2),
                        radius: isPressed ? 0 : 2,
                        x: 0,
                        y: isPressed ? 0 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
            }
            .help(component.isModifier ? component.name : "Key: \(component.name)")
    }
}