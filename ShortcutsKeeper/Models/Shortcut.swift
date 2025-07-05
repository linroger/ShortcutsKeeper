//
//  Shortcut.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftData

@Model
final class Shortcut {
    var id: UUID
    var title: String
    var keyCombination: String
    var keyCombinations: [String] // New property for multiple shortcuts
    var shortcutDescription: String
    var category: String
    var subcategory: String?
    var isFavorite: Bool
    var dateCreated: Date
    var dateModified: Date
    var dateAdded: Date?
    var tags: [String]
    
    // Soft delete properties
    var isDeleted: Bool?
    var dateDeleted: Date?
    
    // Usage tracking
    var usageCount: Int?
    
    @Relationship(deleteRule: .nullify, inverse: \Application.shortcuts)
    var application: Application?
    
    init(
        title: String,
        keyCombination: String,
        keyCombinations: [String] = [],
        shortcutDescription: String = "",
        category: String = "General",
        subcategory: String? = nil,
        application: Application? = nil,
        isFavorite: Bool = false,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.keyCombination = keyCombination
        self.keyCombinations = keyCombinations.isEmpty ? [keyCombination] : keyCombinations
        self.shortcutDescription = shortcutDescription
        self.category = category
        self.subcategory = subcategory
        self.application = application
        self.isFavorite = isFavorite
        self.dateCreated = Date()
        self.dateModified = Date()
        self.dateAdded = Date()
        self.tags = tags
        self.isDeleted = false
        self.dateDeleted = nil
        self.usageCount = 0
    }
}

extension Shortcut {
    var searchableText: String {
        let subcategoryText = subcategory ?? ""
        let allKeys = keyCombinations.joined(separator: " ")
        return "\(title) \(keyCombination) \(allKeys) \(shortcutDescription) \(category) \(subcategoryText) \(tags.joined(separator: " "))"
    }
    
    var description: String {
        return shortcutDescription
    }
    
    var allKeyDisplayText: String {
        return keyCombinations.joined(separator: " | ")
    }
}