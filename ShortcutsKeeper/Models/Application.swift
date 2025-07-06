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
        guard let iconData = iconData else { 
            // PERFORMANCE: Lazy load icon from file system if needed
            if let path = self.path {
                return NSWorkspace.shared.icon(forFile: path)
            }
            return nil
        }
        return NSImage(data: iconData)
    }
    
    // MEMORY OPTIMIZATION: Compress icon data
    func setCompressedIcon(_ image: NSImage) {
        if let tiffData = image.tiffRepresentation,
           let bitmapRep = NSBitmapImageRep(data: tiffData),
           let jpegData = bitmapRep.representation(using: .jpeg, properties: [.compressionFactor: 0.7]) {
            self.iconData = jpegData
        }
    }
    
    var shortcutCount: Int {
        shortcuts.count
    }
    
    static func createFromBundle(bundleIdentifier: String) -> Application? {
        guard let appURL = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleIdentifier),
              let bundle = Bundle(url: appURL),
              let name = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            return nil
        }
        
        let appPath = appURL.path
        let app = Application(name: name, bundleIdentifier: bundleIdentifier, path: appPath)
        
        // MEMORY OPTIMIZATION: Use compressed icon instead of full TIFF
        let icon = NSWorkspace.shared.icon(forFile: appPath)
        app.setCompressedIcon(icon)
        
        return app
    }
}