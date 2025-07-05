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
    private var searchIndex: [String: Set<UUID>] = [:]
    private var categoryIndex: [String: [UUID]] = [:]
    private var applicationIndex: [String: [UUID]] = [:]
    private var shortcutLookup: [UUID: Shortcut] = [:]
    
    // DISABLED: Search index building was causing CPU overload
    func buildSearchIndex(from shortcuts: [Shortcut]) {
        print("🚫 Search index building disabled to prevent CPU overload")
        
        // Clear existing indices to prevent stale data
        searchIndex.removeAll()
        categoryIndex.removeAll()
        applicationIndex.removeAll()
        shortcutLookup.removeAll()
        
        // Set optimization progress to completed
        isOptimizing = false
        optimizationProgress = 1.0
        
        return
        
        // Original expensive code commented out:
        /*
        searchIndexQueue.async { [weak self] in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isOptimizing = true
                self.optimizationProgress = 0.0
            }
            
            var newSearchIndex: [String: Set<UUID>] = [:]
            var newCategoryIndex: [String: [UUID]] = [:]
            var newApplicationIndex: [String: [UUID]] = [:]
            var newShortcutLookup: [UUID: Shortcut] = [:]
            
            let totalShortcuts = shortcuts.count
            
            // Build lookup table first
            for shortcut in shortcuts {
                newShortcutLookup[shortcut.id] = shortcut
            }
            
            for (index, shortcut) in shortcuts.enumerated() {
                // Build search index with REDUCED n-grams for memory efficiency
                let searchText = "\(shortcut.title) \(shortcut.shortcutDescription) \(shortcut.keyCombination)".lowercased()
                let words = searchText.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
                
                for word in words {
                    // Add full word
                    if newSearchIndex[word] == nil {
                        newSearchIndex[word] = Set<UUID>()
                    }
                    newSearchIndex[word]?.insert(shortcut.id) // MEMORY FIX: Store ID only
                    
                    // MEMORY OPTIMIZATION: Reduce prefix length from 5 to 3
                    for i in 1...min(word.count, 3) {
                        let prefix = String(word.prefix(i))
                        if newSearchIndex[prefix] == nil {
                            newSearchIndex[prefix] = Set<UUID>()
                        }
                        newSearchIndex[prefix]?.insert(shortcut.id)
                    }
                }
                
                // Build category index
                if newCategoryIndex[shortcut.category] == nil {
                    newCategoryIndex[shortcut.category] = []
                }
                newCategoryIndex[shortcut.category]?.append(shortcut.id)
                
                // Build application index
                if let appName = shortcut.application?.name {
                    if newApplicationIndex[appName] == nil {
                        newApplicationIndex[appName] = []
                    }
                    newApplicationIndex[appName]?.append(shortcut.id)
                }
                
                // Update progress
                let progress = Double(index + 1) / Double(totalShortcuts)
                DispatchQueue.main.async {
                    self.optimizationProgress = progress
                }
            }
            
            // Update indices atomically
            self.searchIndex = newSearchIndex
            self.categoryIndex = newCategoryIndex
            self.applicationIndex = newApplicationIndex
            self.shortcutLookup = newShortcutLookup
            
            DispatchQueue.main.async {
                self.isOptimizing = false
                self.optimizationProgress = 1.0
            }
        }
        */
    }
    
    // DISABLED: Return empty results since search indexing is disabled for performance
    func fastSearch(_ query: String, limit: Int = 100) -> [Shortcut] {
        print("🚫 Fast search disabled - use AppModel.searchAllShortcuts() instead")
        return []
    }
    
    func getShortcutsInCategory(_ category: String) -> [Shortcut] {
        print("🚫 Category search disabled - search indexing turned off for performance")
        return []
    }
    
    func getShortcutsForApplication(_ applicationName: String) -> [Shortcut] {
        print("🚫 Application search disabled - search indexing turned off for performance")
        return []
    }
    
    func getTopCategories(limit: Int = 10) -> [(category: String, count: Int)] {
        print("🚫 Category statistics disabled - search indexing turned off for performance")
        return []
    }
    
    func getTopApplications(limit: Int = 10) -> [(application: String, count: Int)] {
        print("🚫 Application statistics disabled - search indexing turned off for performance")
        return []
    }
    
    func invalidateIndex() {
        searchIndex.removeAll()
        categoryIndex.removeAll()
        applicationIndex.removeAll()
        shortcutLookup.removeAll()
    }
    
    // MEMORY MONITORING - DISABLED
    func getMemoryUsage() -> (searchIndex: Int, categoryIndex: Int, applicationIndex: Int, lookup: Int) {
        // Return zero values since indexing is disabled
        return (searchIndex: 0, categoryIndex: 0, applicationIndex: 0, lookup: 0)
    }
    
    func optimizeMemoryUsage() {
        // Clear all indices since they're disabled
        searchIndex.removeAll()
        categoryIndex.removeAll()
        applicationIndex.removeAll()
        shortcutLookup.removeAll()
        print("🧹 Search indices cleared - indexing disabled for performance")
    }
}

// MARK: - Virtual Scrolling Support (Unchanged for compatibility)
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