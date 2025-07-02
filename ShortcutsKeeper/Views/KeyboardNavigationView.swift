//
//  KeyboardNavigationView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct KeyboardNavigationOverlay: ViewModifier {
    @State private var navigationMode = false
    
    func body(content: Content) -> some View {
        content
            .overlay(alignment: .topTrailing) {
                if navigationMode {
                    KeyboardNavigationHelpView()
                        .transition(.opacity.combined(with: .scale))
                }
            }
    }
}

struct KeyboardNavigationHelpView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "keyboard")
                    .font(.title2)
                    .foregroundColor(.accentColor)
                
                Text("Keyboard Navigation")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 8) {
                KeyboardShortcutRow(key: "?", description: "Show/hide this help")
                KeyboardShortcutRow(key: "⌘N", description: "New shortcut")
                KeyboardShortcutRow(key: "⌘K", description: "Quick search")
                KeyboardShortcutRow(key: "⌘⇧F", description: "Advanced search")
                KeyboardShortcutRow(key: "⌘G", description: "Global search")
                KeyboardShortcutRow(key: "⌘,", description: "Settings")
                
                Divider()
                    .padding(.vertical, 4)
                
                KeyboardShortcutRow(key: "1", description: "Focus sidebar")
                KeyboardShortcutRow(key: "2", description: "Focus search")
                KeyboardShortcutRow(key: "3", description: "Focus shortcuts list")
                KeyboardShortcutRow(key: "4", description: "Focus detail view")
                
                Divider()
                    .padding(.vertical, 4)
                
                KeyboardShortcutRow(key: "↑↓", description: "Navigate items")
                KeyboardShortcutRow(key: "⏎", description: "Select item")
                KeyboardShortcutRow(key: "⌘⌫", description: "Delete shortcut")
                KeyboardShortcutRow(key: "⌘D", description: "Duplicate shortcut")
                KeyboardShortcutRow(key: "⌘E", description: "Edit shortcut")
                KeyboardShortcutRow(key: "⌘F", description: "Toggle favorite")
            }
            .font(.caption)
        }
        .padding()
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding()
    }
}

struct KeyboardShortcutRow: View {
    let key: String
    let description: String
    
    var body: some View {
        HStack {
            HStack(spacing: 2) {
                ForEach(parseKeyComponents(key), id: \.self) { component in
                    Text(component)
                        .font(.system(.caption2, design: .monospaced, weight: .medium))
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.2))
                        .cornerRadius(4)
                }
            }
            .frame(width: 60, alignment: .leading)
            
            Text(description)
                .foregroundColor(.secondary)
            
            Spacer()
        }
    }
    
    private func parseKeyComponents(_ keyString: String) -> [String] {
        let components = keyString.map { String($0) }
        var result: [String] = []
        
        for component in components {
            switch component {
            case "⌘":
                result.append("⌘")
            case "⌃":
                result.append("⌃")
            case "⌥":
                result.append("⌥")
            case "⇧":
                result.append("⇧")
            case "⏎":
                result.append("⏎")
            case "⌫":
                result.append("⌫")
            case "↑":
                result.append("↑")
            case "↓":
                result.append("↓")
            default:
                result.append(component)
            }
        }
        
        return result
    }
}

struct QuickSearchBar: View {
    @Binding var searchText: String
    @Binding var isPresented: Bool
    @FocusState private var isSearchFocused: Bool
    
    var onSearch: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Quick search shortcuts...", text: $searchText)
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .onSubmit {
                        onSearch(searchText)
                        isPresented = false
                    }
                
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Button("Cancel") {
                    isPresented = false
                }
                .keyboardShortcut(.escape)
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(8)
            .shadow(radius: 5)
        }
        .frame(maxWidth: 400)
        .onAppear {
            isSearchFocused = true
        }
    }
}

struct GlobalKeyboardHandler: ViewModifier {
    let appModel: AppModel
    @State private var showQuickSearch = false
    @State private var quickSearchText = ""
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if showQuickSearch {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showQuickSearch = false
                        }
                    
                    QuickSearchBar(
                        searchText: $quickSearchText,
                        isPresented: $showQuickSearch,
                        onSearch: { query in
                            appModel.searchText = query
                        }
                    )
                }
            }
    }
}

extension View {
    func keyboardNavigation(appModel: AppModel) -> some View {
        self
            .modifier(KeyboardNavigationOverlay())
            .modifier(GlobalKeyboardHandler(appModel: appModel))
    }
}