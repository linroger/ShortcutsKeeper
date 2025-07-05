//
//  GlobalSearchView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct GlobalSearchView: View {
    let appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var searchResults: [Shortcut] = []
    @State private var selectedShortcut: Shortcut?
    @State private var searchMode: SearchMode = .text
    
    enum SearchMode: String, CaseIterable {
        case text = "Text"
        case shortcut = "Shortcut"
        case conflicts = "Conflicts"
        
        var icon: String {
            switch self {
            case .text: return "magnifyingglass"
            case .shortcut: return "keyboard"
            case .conflicts: return "exclamationmark.triangle"
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            searchInterface
            
            Divider()
            
            if searchMode == .conflicts {
                conflictsView
            } else {
                resultsView
            }
        }
        .frame(width: 700, height: 600)
        .onAppear {
            performSearch()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Global Search")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding()
    }
    
    private var searchInterface: some View {
        VStack(spacing: 16) {
            Picker("Search Mode", selection: $searchMode) {
                ForEach(SearchMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.icon)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            
            if searchMode != .conflicts {
                HStack {
                    Image(systemName: searchMode.icon)
                        .foregroundColor(.secondary)
                    
                    TextField(
                        searchMode == .shortcut ? "Enter shortcut (e.g., ⌘C or cmd+c)" : "Search shortcuts...",
                        text: $searchQuery
                    )
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        performSearch()
                    }
                    
                    if !searchQuery.isEmpty {
                        Button(action: {
                            searchQuery = ""
                            performSearch()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding()
        .onChange(of: searchQuery) { _, _ in
            performSearch()
        }
        .onChange(of: searchMode) { _, _ in
            searchQuery = ""
            performSearch()
        }
    }
    
    private var resultsView: some View {
        List(searchResults, selection: $selectedShortcut) { shortcut in
            GlobalSearchResultRow(shortcut: shortcut, searchQuery: searchQuery, searchMode: searchMode)
                .tag(shortcut)
        }
        .listStyle(.plain)
        .overlay {
            if searchResults.isEmpty {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text(searchMode == .shortcut ? 
                         "No shortcuts match the entered key combination" :
                         "No shortcuts match your search terms")
                }
            }
        }
    }
    
    private var conflictsView: some View {
        let conflicts = appModel.detectAllConflicts()
        
        return List {
            if conflicts.isEmpty {
                ContentUnavailableView {
                    Label("No Conflicts", systemImage: "checkmark.circle")
                        .foregroundColor(.green)
                } description: {
                    Text("All shortcuts are unique within their applications")
                }
                .listRowSeparator(.hidden)
            } else {
                ForEach(Array(conflicts.keys), id: \.self) { key in
                    let conflictingShortcuts = conflicts[key] ?? []
                    ConflictGroupView(shortcuts: conflictingShortcuts)
                }
            }
        }
        .listStyle(.plain)
    }
    
    private func performSearch() {
        switch searchMode {
        case .text, .shortcut:
            searchResults = appModel.searchAllShortcuts(query: searchQuery)
        case .conflicts:
            // Conflicts are handled in the conflictsView
            break
        }
    }
}

struct GlobalSearchResultRow: View {
    let shortcut: Shortcut
    let searchQuery: String
    let searchMode: GlobalSearchView.SearchMode
    
    var body: some View {
        HStack(spacing: 12) {
            // App icon
            if let app = shortcut.application, let icon = app.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.accentColor.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Image(systemName: "app.fill")
                            .foregroundColor(.accentColor)
                    )
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    highlightedText(shortcut.title, searchQuery: searchQuery)
                        .font(.headline)
                    
                    if shortcut.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                if !shortcut.shortcutDescription.isEmpty {
                    highlightedText(shortcut.shortcutDescription, searchQuery: searchQuery)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                HStack {
                    Text(shortcut.category)
                        .font(.caption2)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(4)
                    
                    if let app = shortcut.application {
                        Text(app.name)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            ShortcutKeyView(keyCombination: shortcut.keyCombination)
        }
        .padding(.vertical, 4)
    }
    
    private func highlightedText(_ text: String, searchQuery: String) -> Text {
        if searchQuery.isEmpty || searchMode == .shortcut {
            return Text(text)
        }
        
        let ranges = text.ranges(of: searchQuery, options: .caseInsensitive)
        if ranges.isEmpty {
            return Text(text)
        }
        
        // Build an array of text components
        var components: [Text] = []
        var currentIndex = text.startIndex
        
        for range in ranges {
            // Add text before the match
            if currentIndex < range.lowerBound {
                components.append(Text(String(text[currentIndex..<range.lowerBound])))
            }
            
            // Add highlighted match
            components.append(
                Text(String(text[range]))
                    .foregroundColor(.accentColor)
                    .fontWeight(.semibold)
            )
            
            currentIndex = range.upperBound
        }
        
        // Add remaining text
        if currentIndex < text.endIndex {
            components.append(Text(String(text[currentIndex...])))
        }
        
        // Combine all components
        return components.reduce(Text("")) { $0 + $1 }
    }
}

struct ConflictGroupView: View {
    let shortcuts: [Shortcut]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Duplicate Shortcut")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                if let first = shortcuts.first {
                    ShortcutKeyView(keyCombination: first.keyCombination)
                }
                
                Spacer()
            }
            
            ForEach(shortcuts) { shortcut in
                HStack {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 6, height: 6)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(shortcut.title)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if let app = shortcut.application {
                            Text(app.name)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.leading, 8)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

extension String {
    func ranges(of searchString: String, options: CompareOptions = []) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var searchStartIndex = self.startIndex
        
        while searchStartIndex < self.endIndex,
              let range = self.range(of: searchString, options: options, range: searchStartIndex..<self.endIndex) {
            ranges.append(range)
            searchStartIndex = range.upperBound
        }
        
        return ranges
    }
}