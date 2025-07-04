//
//  ApplicationScannerService.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import AppKit

class ApplicationScannerService {
    static let shared = ApplicationScannerService()
    
    private let commonAppPaths = [
        "/Applications",
        "/System/Applications",
        "/System/Applications/Utilities",
        "~/Applications"
    ]
    
    func scanForApplications(completion: @escaping ([Application]) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            var applications: [Application] = []
            let fileManager = FileManager.default
            
            for path in self.commonAppPaths {
                let expandedPath = NSString(string: path).expandingTildeInPath
                
                guard let contents = try? fileManager.contentsOfDirectory(atPath: expandedPath) else {
                    continue
                }
                
                for item in contents {
                    if item.hasSuffix(".app") {
                        let appPath = (expandedPath as NSString).appendingPathComponent(item)
                        
                        if let app = self.createApplication(from: appPath) {
                            applications.append(app)
                        }
                    }
                }
            }
            
            // Remove duplicates based on bundle identifier
            let uniqueApps = Dictionary(grouping: applications, by: { $0.bundleIdentifier })
                .compactMap { $0.value.first }
                .sorted { $0.name < $1.name }
            
            DispatchQueue.main.async {
                completion(uniqueApps)
            }
        }
    }
    
    func getApplicationInfo(for app: Application) -> ApplicationInfo {
        var info = ApplicationInfo()
        
        if !app.bundleIdentifier.isEmpty,
           let path = NSWorkspace.shared.absolutePathForApplication(withBundleIdentifier: app.bundleIdentifier) {
            info.path = path
            
            if let bundle = Bundle(path: path) {
                info.version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
                info.buildNumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
                info.copyright = bundle.object(forInfoDictionaryKey: "NSHumanReadableCopyright") as? String ?? ""
                info.minimumSystemVersion = bundle.object(forInfoDictionaryKey: "LSMinimumSystemVersion") as? String ?? ""
                
                // Get file size
                if let attributes = try? FileManager.default.attributesOfItem(atPath: path),
                   let fileSize = attributes[.size] as? NSNumber {
                    info.size = ByteCountFormatter.string(fromByteCount: fileSize.int64Value, countStyle: .file)
                }
                
                // Get creation and modification dates
                if let attributes = try? FileManager.default.attributesOfItem(atPath: path) {
                    info.creationDate = attributes[.creationDate] as? Date
                    info.modificationDate = attributes[.modificationDate] as? Date
                }
            }
        }
        
        return info
    }
    
    private func createApplication(from path: String) -> Application? {
        guard let bundle = Bundle(path: path),
              let bundleIdentifier = bundle.bundleIdentifier,
              let appName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String ?? 
                           bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else {
            return nil
        }
        
        let app = Application(
            name: appName,
            bundleIdentifier: bundleIdentifier,
            isSystemApp: path.hasPrefix("/System/")
        )
        
        // MEMORY OPTIMIZATION: Get compressed app icon
        let icon = NSWorkspace.shared.icon(forFile: path)
        app.setCompressedIcon(icon)
        
        return app
    }
    
    func openInFinder(path: String) {
        NSWorkspace.shared.selectFile(path, inFileViewerRootedAtPath: "")
    }
    
    func launchApplication(_ app: Application) {
        if !app.bundleIdentifier.isEmpty {
            NSWorkspace.shared.launchApplication(withBundleIdentifier: app.bundleIdentifier, 
                                               options: [], 
                                               additionalEventParamDescriptor: nil, 
                                               launchIdentifier: nil)
        }
    }
}

struct ApplicationInfo {
    var path: String = ""
    var version: String = ""
    var buildNumber: String = ""
    var copyright: String = ""
    var size: String = ""
    var minimumSystemVersion: String = ""
    var creationDate: Date?
    var modificationDate: Date?
}