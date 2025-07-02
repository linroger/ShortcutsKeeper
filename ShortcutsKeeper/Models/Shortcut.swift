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
    var shortcutDescription: String
    var category: String
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
        shortcutDescription: String = "",
        category: String = "General",
        application: Application? = nil,
        isFavorite: Bool = false,
        tags: [String] = []
    ) {
        self.id = UUID()
        self.title = title
        self.keyCombination = keyCombination
        self.shortcutDescription = shortcutDescription
        self.category = category
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
        "\(title) \(keyCombination) \(shortcutDescription) \(category) \(tags.joined(separator: " "))"
    }
    
    var description: String {
        return shortcutDescription
    }
}