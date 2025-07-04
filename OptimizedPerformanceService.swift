//
//  OptimizedPerformanceService.swift
//  ShortcutsKeeper - PERFORMANCE OPTIMIZED VERSION
//

import Foundation
import SwiftUI
import Combine

class OptimizedPerformanceService: ObservableObject {
    @Published var isOptimizing = false
    @Published var optimizationProgress: Double = 0.0
    
    private let searchIndexQueue = DispatchQueue(label: "searchIndex", qos: .userInitiated)
    private var searchIndex: [String: Set<UUID>] = [:]
    private var categoryIndex: [String: [UUID]] = [:]
    private var applicationIndex: [String: [UUID]] = [:]
    private var shortcutLookup: [UUID: Shortcut] = [:]
    
    // MEMORY OPTIMIZED: Store IDs instead of full objects
    func buildSearchIndex(from shortcuts: [Shortcut]) {
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
    }
    
    // OPTIMIZED: Convert IDs back to objects only when needed
    func fastSearch(_ query: String, limit: Int = 100) -> [Shortcut] {
        guard !query.isEmpty else { return [] }
        
        let searchTerms = query.lowercased().components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }
        guard !searchTerms.isEmpty else { return [] }
        
        var resultSet: Set<UUID>?
        
        for term in searchTerms {
            let matchingIds = searchIndex[term] ?? Set<UUID>()
            
            if resultSet == nil {
                resultSet = matchingIds
            } else {
                resultSet = resultSet?.intersection(matchingIds)
            }
            
            if resultSet?.isEmpty == true {
                return []
            }
        }
        
        let shortcutIds = Array(resultSet ?? Set<UUID>()).prefix(limit)
        return shortcutIds.compactMap { shortcutLookup[$0] }
    }
    
    func getShortcutsInCategory(_ category: String) -> [Shortcut] {
        let ids = categoryIndex[category] ?? []
        return ids.compactMap { shortcutLookup[$0] }
    }
    
    func getShortcutsForApplication(_ applicationName: String) -> [Shortcut] {
        let ids = applicationIndex[applicationName] ?? []
        return ids.compactMap { shortcutLookup[$0] }
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
        shortcutLookup.removeAll()
    }
    
    // MEMORY MONITORING
    func getMemoryUsage() -> (searchIndex: Int, categoryIndex: Int, applicationIndex: Int, lookup: Int) {
        let searchSize = MemoryLayout.size(ofValue: searchIndex)
        let categorySize = MemoryLayout.size(ofValue: categoryIndex)
        let applicationSize = MemoryLayout.size(ofValue: applicationIndex)
        let lookupSize = MemoryLayout.size(ofValue: shortcutLookup)
        
        return (searchIndex: searchSize, categoryIndex: categorySize, 
                applicationIndex: applicationSize, lookup: lookupSize)
    }
    
    func optimizeMemoryUsage() {
        // Remove empty entries
        searchIndex = searchIndex.filter { !$0.value.isEmpty }
        categoryIndex = categoryIndex.filter { !$0.value.isEmpty }
        applicationIndex = applicationIndex.filter { !$0.value.isEmpty }
        
        // Remove orphaned shortcuts from lookup
        let allUsedIds = Set(searchIndex.values.flatMap { $0 })
        shortcutLookup = shortcutLookup.filter { allUsedIds.contains($0.key) }
    }
}