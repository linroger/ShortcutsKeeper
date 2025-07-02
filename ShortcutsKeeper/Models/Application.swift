//
//  Application.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import SwiftData
import AppKit

@Model
final class Application {
    var id: UUID
    var name: String
    var bundleIdentifier: String
    var path: String?
    var iconData: Data?
    var dateAdded: Date
    var isSystemApp: Bool
    
    @Relationship(deleteRule: .cascade)
    var shortcuts: [Shortcut] = []
    
    init(
        name: String,
        bundleIdentifier: String = "",
        path: String? = nil,
        iconData: Data? = nil,
        isSystemApp: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.bundleIdentifier = bundleIdentifier
        self.path = path
        self.iconData = iconData
        self.dateAdded = Date()
        self.isSystemApp = isSystemApp
    }
}

extension Application {
    var icon: NSImage? {
        guard let iconData = iconData else { return nil }
        return NSImage(data: iconData)
    }
    
    var shortcutCount: Int {
        shortcuts.count
    }
    
    static func createFromBundle(bundleIdentifier: String) -> Application? {
        guard let appPath = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: bundleIdentifier),
              let bundle = Bundle(path: appPath),
              let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            return nil
        }
        
        let app = Application(name: name, bundleIdentifier: bundleIdentifier, path: appPath)
        
        let icon = NSWorkspace.shared.icon(forFile: appPath)
        app.iconData = icon.tiffRepresentation
        
        return app
    }
}