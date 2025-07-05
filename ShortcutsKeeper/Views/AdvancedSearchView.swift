//
//  AdvancedSearchView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct AdvancedSearchView: View {
    let appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var searchQuery = ""
    @State private var selectedCategories: Set<String> = []
    @State private var selectedApplications: Set<String> = []
    @State private var includeDescription = true
    @State private var caseSensitive = false
    @State private var favoriteOnly = false
    @State private var sortBy: SortOption = .title
    @State private var sortOrder: SortOrder = .ascending
    @State private var searchResults: [Shortcut] = []
    
    enum SortOption: String, CaseIterable {
        case title = "Title"
        case application = "Application"
        case category = "Category"
        case shortcut = "Shortcut"
        case dateAdded = "Date Added"
        
        var icon: String {
            switch self {
            case .title: return "textformat"
            case .application: return "app"
            case .category: return "folder"
            case .shortcut: return "keyboard"
            case .dateAdded: return "calendar"
            }
        }
    }
    
    enum SortOrder: String, CaseIterable {
        case ascending = "Ascending"
        case descending = "Descending"
        
        var icon: String {
            switch self {
            case .ascending: return "arrow.up"
            case .descending: return "arrow.down"
            }
        }
    }
    
    var availableCategories: [String] {
        Array(Set(appModel.applications.flatMap { $0.shortcuts.map { $0.category } })).sorted()
    }
    
    var availableApplications: [String] {
        appModel.applications.map { $0.name }.sorted()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            HStack(spacing: 0) {
                filtersView
                
                Divider()
                
                resultsView
            }
        }
        .frame(width: 900, height: 650)
        .onAppear {
            performAdvancedSearch()
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("Advanced Search")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button("Reset Filters") {
                resetFilters()
            }
            .disabled(isFilterEmpty)
            
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding()
    }
    
    private var filtersView: some View {
        VStack(alignment: .leading, spacing: 20) {
            Group {
                searchSection
                categoriesSection
                applicationsSection
                optionsSection
                sortingSection
            }
            
            Spacer()
            
            searchButtonSection
        }
        .padding()
        .frame(width: 300)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var searchSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Search Query", systemImage: "magnifyingglass")
                .font(.headline)
            
            TextField("Enter search terms...", text: $searchQuery)
                .textFieldStyle(.roundedBorder)
                .onSubmit {
                    performAdvancedSearch()
                }
        }
    }
    
    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Categories", systemImage: "folder")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(availableCategories, id: \.self) { category in
                        Toggle(category, isOn: .init(
                            get: { selectedCategories.contains(category) },
                            set: { isSelected in
                                if isSelected {
                                    selectedCategories.insert(category)
                                } else {
                                    selectedCategories.remove(category)
                                }
                                performAdvancedSearch()
                            }
                        ))
                        .toggleStyle(.checkbox)
                        .font(.caption)
                    }
                }
            }
            .frame(maxHeight: 120)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var applicationsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Applications", systemImage: "app")
                .font(.headline)
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 4) {
                    ForEach(availableApplications, id: \.self) { app in
                        Toggle(app, isOn: .init(
                            get: { selectedApplications.contains(app) },
                            set: { isSelected in
                                if isSelected {
                                    selectedApplications.insert(app)
                                } else {
                                    selectedApplications.remove(app)
                                }
                                performAdvancedSearch()
                            }
                        ))
                        .toggleStyle(.checkbox)
                        .font(.caption)
                    }
                }
            }
            .frame(maxHeight: 120)
            .background(Color(NSColor.textBackgroundColor))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    private var optionsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Options", systemImage: "gear")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 6) {
                Toggle("Include description", isOn: $includeDescription)
                    .onChange(of: includeDescription) { _, _ in performAdvancedSearch() }
                
                Toggle("Case sensitive", isOn: $caseSensitive)
                    .onChange(of: caseSensitive) { _, _ in performAdvancedSearch() }
                
                Toggle("Favorites only", isOn: $favoriteOnly)
                    .onChange(of: favoriteOnly) { _, _ in performAdvancedSearch() }
            }
            .toggleStyle(.checkbox)
            .font(.caption)
        }
    }
    
    private var sortingSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Sorting", systemImage: "arrow.up.arrow.down")
                .font(.headline)
            
            VStack(spacing: 6) {
                Picker("Sort by", selection: $sortBy) {
                    ForEach(SortOption.allCases, id: \.self) { option in
                        Label(option.rawValue, systemImage: option.icon)
                            .tag(option)
                    }
                }
                .pickerStyle(.menu)
                .onChange(of: sortBy) { _, _ in performAdvancedSearch() }
                
                Picker("Order", selection: $sortOrder) {
                    ForEach(SortOrder.allCases, id: \.self) { order in
                        Label(order.rawValue, systemImage: order.icon)
                            .tag(order)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: sortOrder) { _, _ in performAdvancedSearch() }
            }
        }
    }
    
    private var searchButtonSection: some View {
        VStack(spacing: 8) {
            Button(action: performAdvancedSearch) {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Text("\(searchResults.count) results")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var resultsView: some View {
        VStack(spacing: 0) {
            if searchResults.isEmpty {
                ContentUnavailableView {
                    Label("No Results", systemImage: "magnifyingglass")
                } description: {
                    Text("Adjust your search filters to find more shortcuts")
                }
            } else {
                List {
                    ForEach(searchResults) { shortcut in
                        AdvancedSearchResultRow(shortcut: shortcut, searchQuery: searchQuery, includeDescription: includeDescription)
                    }
                }
                .listStyle(.plain)
            }
        }
    }
    
    private var isFilterEmpty: Bool {
        searchQuery.isEmpty && 
        selectedCategories.isEmpty && 
        selectedApplications.isEmpty && 
        !favoriteOnly
    }
    
    private func resetFilters() {
        searchQuery = ""
        selectedCategories.removeAll()
        selectedApplications.removeAll()
        includeDescription = true
        caseSensitive = false
        favoriteOnly = false
        sortBy = .title
        sortOrder = .ascending
        performAdvancedSearch()
    }
    
    private func performAdvancedSearch() {
        let allShortcuts = appModel.applications.flatMap { $0.shortcuts }
        
        var filteredShortcuts = allShortcuts.filter { shortcut in
            // Text search
            if !searchQuery.isEmpty {
                let titleMatch = shortcut.title.contains(searchQuery, caseSensitive: caseSensitive)
                let descriptionMatch = includeDescription && shortcut.shortcutDescription.contains(searchQuery, caseSensitive: caseSensitive)
                let keysMatch = shortcut.keyCombination.contains(searchQuery, caseSensitive: caseSensitive)
                
                if !(titleMatch || descriptionMatch || keysMatch) {
                    return false
                }
            }
            
            // Category filter
            if !selectedCategories.isEmpty && !selectedCategories.contains(shortcut.category) {
                return false
            }
            
            // Application filter
            if !selectedApplications.isEmpty {
                guard let appName = shortcut.application?.name,
                      selectedApplications.contains(appName) else {
                    return false
                }
            }
            
            // Favorites filter
            if favoriteOnly && !shortcut.isFavorite {
                return false
            }
            
            return true
        }
        
        // Sort results
        filteredShortcuts.sort { (lhs: Shortcut, rhs: Shortcut) -> Bool in
            let comparison: ComparisonResult
            
            switch sortBy {
            case .title:
                comparison = lhs.title.localizedCompare(rhs.title)
            case .application:
                let lhsApp = lhs.application?.name ?? ""
                let rhsApp = rhs.application?.name ?? ""
                comparison = lhsApp.localizedCompare(rhsApp)
            case .category:
                comparison = lhs.category.localizedCompare(rhs.category)
            case .shortcut:
                comparison = lhs.keyCombination.localizedCompare(rhs.keyCombination)
            case .dateAdded:
                // Since dateAdded doesn't exist, just use title comparison
                comparison = lhs.title.localizedCompare(rhs.title)
            }
            
            return sortOrder == .ascending ? comparison == .orderedAscending : comparison == .orderedDescending
        }
        
        searchResults = filteredShortcuts
    }
}

struct AdvancedSearchResultRow: View {
    let shortcut: Shortcut
    let searchQuery: String
    let includeDescription: Bool
    
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
                    highlightedText(shortcut.title)
                        .font(.headline)
                        .lineLimit(1)
                    
                    if shortcut.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                    
                    Spacer()
                    
                    ShortcutKeyView(keyCombination: shortcut.keyCombination)
                }
                
                if includeDescription && !shortcut.shortcutDescription.isEmpty {
                    highlightedText(shortcut.shortcutDescription)
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
                    
                    Spacer()
                    
                    Text("Recent")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }
    
    private func highlightedText(_ text: String) -> Text {
        if searchQuery.isEmpty {
            return Text(text)
        }
        
        // PERFORMANCE FIX: Use AttributedString like GlobalSearchView
        let ranges = text.ranges(of: searchQuery, options: .caseInsensitive)
        if ranges.isEmpty {
            return Text(text)
        }
        
        // Create AttributedString for highlighting
        var attributedString = AttributedString(text)
        
        // Apply highlighting to matched ranges (iterate in reverse to avoid index shifting)
        for range in ranges.reversed() {
            let startIndex = AttributedString.Index(range.lowerBound, within: attributedString)
            let endIndex = AttributedString.Index(range.upperBound, within: attributedString)
            
            if let start = startIndex, let end = endIndex {
                let attributedRange = start..<end
                attributedString[attributedRange].foregroundColor = .accentColor
                attributedString[attributedRange].font = .body.weight(.semibold)
            }
        }
        
        return Text(attributedString)
    }
}

extension String {
    func contains(_ string: String, caseSensitive: Bool) -> Bool {
        if caseSensitive {
            return self.contains(string)
        } else {
            return self.localizedCaseInsensitiveContains(string)
        }
    }
}