//
//  PerformanceOptimizationService.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftUI
import Combine

class PerformanceOptimizationService: ObservableObject {
    @Published var isOptimizing = false
    @Published var optimizationProgress: Double = 0.0
    
    private let searchIndexQueue = DispatchQueue(label: "searchIndex", qos: .userInitiated)
    private var searchIndex: [String: Set<Shortcut>] = [:]
    private var categoryIndex: [String: [Shortcut]] = [:]
    private var applicationIndex: [String: [Shortcut]] = [:]
    
    func buildSearchIndex(from shortcuts: [Shortcut]) {
        searchIndexQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isOptimizing = true
                self.optimizationProgress = 0.0
            }
            
            var newSearchIndex: [String: Set<Shortcut>] = [:]
            var newCategoryIndex: [String: [Shortcut]] = [:]
            var newApplicationIndex: [String: [Shortcut]] = [:]
            
            let totalShortcuts = shortcuts.count
            
            for (index, shortcut) in shortcuts.enumerated() {
                // Build search index with n-grams for faster text search
                let searchText = "\(shortcut.title) \(shortcut.shortcutDescription) \(shortcut.keyCombination)".lowercased()
                let words = searchText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                
                for word in words {
                    // Add full word
                    if newSearchIndex[word] == nil {
                        newSearchIndex[word] = Set<Shortcut>()
                    }
                    newSearchIndex[word]?.insert(shortcut)
                    
                    // Add prefixes for partial matching
                    for i in 1...min(word.count, 5) {
                        let prefix = String(word.prefix(i))
                        if newSearchIndex[prefix] == nil {
                            newSearchIndex[prefix] = Set<Shortcut>()
                        }
                        newSearchIndex[prefix]?.insert(shortcut)
                    }
                }
                
                // Build category index
                if newCategoryIndex[shortcut.category] == nil {
                    newCategoryIndex[shortcut.category] = []
                }
                newCategoryIndex[shortcut.category]?.append(shortcut)
                
                // Build application index
                if let appName = shortcut.application?.name {
                    if newApplicationIndex[appName] == nil {
                        newApplicationIndex[appName] = []
                    }
                    newApplicationIndex[appName]?.append(shortcut)
                }
                
                // Update progress
                let progress = Double(index + 1) / Double(totalShortcuts)
                DispatchQueue.main.async {
                    self.optimizationProgress = progress
                }
            }
            
            // Sort category and application indices
            for key in newCategoryIndex.keys {
                newCategoryIndex[key]?.sort { $0.title < $1.title }
            }
            
            for key in newApplicationIndex.keys {
                newApplicationIndex[key]?.sort { $0.title < $1.title }
            }
            
            // Update indices atomically
            self.searchIndex = newSearchIndex
            self.categoryIndex = newCategoryIndex
            self.applicationIndex = newApplicationIndex
            
            DispatchQueue.main.async {
                self.isOptimizing = false
                self.optimizationProgress = 1.0
            }
        }
    }
    
    func fastSearch(_ query: String, limit: Int = 100) -> [Shortcut] {
        guard !query.isEmpty else { return [] }
        
        let searchTerms = query.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        guard !searchTerms.isEmpty else { return [] }
        
        var resultSet: Set<Shortcut>?
        
        for term in searchTerms {
            let matchingShortcuts = searchIndex[term] ?? Set<Shortcut>()
            
            if resultSet == nil {
                resultSet = matchingShortcuts
            } else {
                resultSet = resultSet?.intersection(matchingShortcuts)
            }
            
            // If no matches for any term, return empty result
            if resultSet?.isEmpty == true {
                return []
            }
        }
        
        let results = Array(resultSet ?? Set<Shortcut>())
        return Array(results.prefix(limit))
    }
    
    func getShortcutsInCategory(_ category: String) -> [Shortcut] {
        return categoryIndex[category] ?? []
    }
    
    func getShortcutsForApplication(_ applicationName: String) -> [Shortcut] {
        return applicationIndex[applicationName] ?? []
    }
    
    func getTopCategories(limit: Int = 10) -> [(category: String, count: Int)] {
        let sorted = categoryIndex.map { (category: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
        return Array(sorted.prefix(limit))
    }
    
    func getTopApplications(limit: Int = 10) -> [(application: String, count: Int)] {
        let sorted = applicationIndex.map { (application: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
        return Array(sorted.prefix(limit))
    }
    
    func invalidateIndex() {
        searchIndex.removeAll()
        categoryIndex.removeAll()
        applicationIndex.removeAll()
    }
}

// MARK: - Memory Management
extension PerformanceOptimizationService {
    func getMemoryUsage() -> (searchIndex: Int, categoryIndex: Int, applicationIndex: Int) {
        let searchIndexSize = MemoryLayout.size(ofValue: searchIndex) + 
                             searchIndex.reduce(0) { total, item in
                                 total + MemoryLayout.size(ofValue: item.key) + MemoryLayout.size(ofValue: item.value)
                             }
        
        let categoryIndexSize = MemoryLayout.size(ofValue: categoryIndex) +
                               categoryIndex.reduce(0) { total, item in
                                   total + MemoryLayout.size(ofValue: item.key) + MemoryLayout.size(ofValue: item.value)
                               }
        
        let applicationIndexSize = MemoryLayout.size(ofValue: applicationIndex) +
                                  applicationIndex.reduce(0) { total, item in
                                      total + MemoryLayout.size(ofValue: item.key) + MemoryLayout.size(ofValue: item.value)
                                  }
        
        return (searchIndex: searchIndexSize, categoryIndex: categoryIndexSize, applicationIndex: applicationIndexSize)
    }
    
    func optimizeMemoryUsage() {
        // Remove empty entries
        searchIndex = searchIndex.filter { !$0.value.isEmpty }
        categoryIndex = categoryIndex.filter { !$0.value.isEmpty }
        applicationIndex = applicationIndex.filter { !$0.value.isEmpty }
    }
}

// MARK: - Virtual Scrolling Support
class VirtualScrollingManager: ObservableObject {
    @Published var visibleItems: [Shortcut] = []
    @Published var totalItemsCount: Int = 0
    
    private var allItems: [Shortcut] = []
    private let itemHeight: CGFloat = 60
    private let bufferSize: Int = 10
    
    func updateItems(_ items: [Shortcut]) {
        allItems = items
        totalItemsCount = items.count
        updateVisibleItems(scrollOffset: 0, viewHeight: 400)
    }
    
    func updateVisibleItems(scrollOffset: CGFloat, viewHeight: CGFloat) {
        let startIndex = max(0, Int(scrollOffset / itemHeight) - bufferSize)
        let visibleCount = Int(viewHeight / itemHeight) + 2 * bufferSize
        let endIndex = min(allItems.count, startIndex + visibleCount)
        
        if startIndex < endIndex {
            visibleItems = Array(allItems[startIndex..<endIndex])
        } else {
            visibleItems = []
        }
    }
    
    func getItemOffset(for index: Int) -> CGFloat {
        return CGFloat(index) * itemHeight
    }
    
    func getTotalHeight() -> CGFloat {
        return CGFloat(totalItemsCount) * itemHeight
    }
}

// Custom view for virtual scrolling
struct VirtualScrollView<Content: View>: View {
    let items: [Shortcut]
    let content: (Shortcut) -> Content
    
    @StateObject private var manager = VirtualScrollingManager()
    @State private var scrollOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(manager.visibleItems) { item in
                        content(item)
                            .frame(height: 60)
                    }
                }
                .frame(height: manager.getTotalHeight())
                .background(
                    GeometryReader { scrollGeometry in
                        Color.clear.onAppear {
                            updateScrollOffset(scrollGeometry, viewGeometry: geometry)
                        }
                        .onChange(of: scrollGeometry.frame(in: .named("scroll"))) { _, newFrame in
                            updateScrollOffset(scrollGeometry, viewGeometry: geometry)
                        }
                    }
                )
            }
            .coordinateSpace(name: "scroll")
            .onAppear {
                manager.updateItems(items)
            }
            .onChange(of: items) { _, newItems in
                manager.updateItems(newItems)
            }
        }
    }
    
    private func updateScrollOffset(_ scrollGeometry: GeometryProxy, viewGeometry: GeometryProxy) {
        let newOffset = -scrollGeometry.frame(in: .named("scroll")).minY
        if abs(newOffset - scrollOffset) > 10 { // Debounce updates
            scrollOffset = newOffset
            manager.updateVisibleItems(scrollOffset: newOffset, viewHeight: viewGeometry.size.height)
        }
    }
}