//
//  AppSelectorView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 7/1/25.
//

import SwiftUI
import SwiftData
import AppKit

struct AppSelectorView: View {
    @Bindable var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    @State private var availableApps: [InstalledApp] = []
    @State private var isScanning = false
    @State private var searchText = ""
    @State private var selectedApps: Set<InstalledApp> = []
    @State private var showSystemApps = false
    
    var filteredApps: [InstalledApp] {
        availableApps.filter { app in
            let matchesSearch = searchText.isEmpty || 
                app.name.localizedCaseInsensitiveContains(searchText) ||
                app.bundleID.localizedCaseInsensitiveContains(searchText)
            
            let isSystemApp = app.bundleID.hasPrefix("com.apple.") || 
                app.path.hasPrefix("/System/") ||
                app.path.hasPrefix("/usr/")
            
            return matchesSearch && (showSystemApps || !isSystemApp)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "plus.app")
                        .font(.system(size: 40))
                        .foregroundColor(.accentColor)
                    
                    VStack(alignment: .leading) {
                        Text("Add Applications")
                            .font(.title)
                            .fontWeight(.semibold)
                        Text("Select applications to track shortcuts for")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Header buttons
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .keyboardShortcut(.escape)
                        
                        Button("Add Selected (\(selectedApps.count))") {
                            addSelectedApps()
                            dismiss()
                        }
                        .keyboardShortcut(.return)
                        .disabled(selectedApps.isEmpty)
                        .buttonStyle(.borderedProminent)
                    }
                }
                
                HStack {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search applications...", text: $searchText)
                            .textFieldStyle(.plain)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(NSColor.controlBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    
                    Toggle("Show System Apps", isOn: $showSystemApps)
                        .controlSize(.small)
                    
                    Button(action: scanForApplications) {
                        HStack {
                            if isScanning {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text("Scan")
                        }
                    }
                    .disabled(isScanning)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            Divider()
            
            // Apps list with proper scrollbar
            if isScanning {
                VStack {
                    ProgressView()
                    Text("Scanning for applications...")
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView(.vertical, showsIndicators: true) {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 280, maximum: 320), spacing: 12)
                    ], spacing: 12) {
                        ForEach(filteredApps, id: \.bundleID) { app in
                            AppCard(
                                app: app,
                                isSelected: selectedApps.contains(app),
                                isAlreadyAdded: appModel.applications.contains { $0.bundleIdentifier == app.bundleID },
                                onToggle: { 
                                    if selectedApps.contains(app) {
                                        selectedApps.remove(app)
                                    } else {
                                        selectedApps.insert(app)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
            }
            
            Divider()
            
            // Footer with status
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(availableApps.count) applications found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if !selectedApps.isEmpty {
                        Text("\(selectedApps.count) selected")
                            .font(.caption)
                            .foregroundColor(.accentColor)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                // Quick action buttons
                if !selectedApps.isEmpty {
                    HStack {
                        Button("Clear Selection") {
                            selectedApps.removeAll()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Select All Visible") {
                            filteredApps.forEach { app in
                                if !appModel.applications.contains(where: { $0.bundleIdentifier == app.bundleID }) {
                                    selectedApps.insert(app)
                                }
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }
            .padding()
            .background(.ultraThinMaterial)
        }
        .navigationTitle("Add Applications")
        .frame(width: 900, height: 700)
        .onAppear {
            scanForApplications()
        }
    }
    
    private func scanForApplications() {
        isScanning = true
        
        Task {
            let apps = await AppScanner.scanForApplications()
            
            await MainActor.run {
                availableApps = apps.sorted { $0.name < $1.name }
                isScanning = false
            }
        }
    }
    
    private func addSelectedApps() {
        for app in selectedApps {
            // Check if app already exists to avoid duplicates
            if !appModel.applications.contains(where: { $0.bundleIdentifier == app.bundleID }) {
                let application = Application(name: app.name, bundleIdentifier: app.bundleID, path: app.path)
                if let icon = app.icon {
                    application.iconData = icon.tiffRepresentation
                }
                
                // Add to SwiftData context
                if let context = appModel.modelContext {
                    context.insert(application)
                    try? context.save()
                }
                
                // Add to model array
                appModel.applications.append(application)
            }
        }
        
        // Clear selections after adding
        selectedApps.removeAll()
    }
}

struct AppCard: View {
    let app: InstalledApp
    let isSelected: Bool
    let isAlreadyAdded: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: {
            if !isAlreadyAdded {
                onToggle()
            }
        }) {
            HStack(spacing: 12) {
                // App icon
                if let icon = app.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 32, height: 32)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 32, height: 32)
                        .overlay(
                            Image(systemName: "app")
                                .foregroundColor(.secondary)
                        )
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(app.name)
                        .font(.headline)
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(app.bundleID)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Text(app.path)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                VStack {
                    if isAlreadyAdded {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isSelected ? .accentColor : .secondary)
                    }
                    
                    if isAlreadyAdded {
                        Text("Added")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? Color.accentColor : 
                                isAlreadyAdded ? Color.green.opacity(0.5) : Color.gray.opacity(0.3),
                                lineWidth: isSelected || isAlreadyAdded ? 2 : 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .disabled(isAlreadyAdded)
    }
}

// MARK: - App Scanner

struct InstalledApp: Hashable, Identifiable {
    let id = UUID()
    let name: String
    let bundleID: String
    let path: String
    let icon: NSImage?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(bundleID)
    }
    
    static func == (lhs: InstalledApp, rhs: InstalledApp) -> Bool {
        lhs.bundleID == rhs.bundleID
    }
}

class AppScanner {
    static func scanForApplications() async -> [InstalledApp] {
        return await withCheckedContinuation { continuation in
            DispatchQueue.global(qos: .userInitiated).async {
                var apps: [InstalledApp] = []
                
                // Scan common application directories
                let searchPaths = [
                    "/Applications",
                    "/System/Applications",
                    "/System/Library/CoreServices",
                    NSHomeDirectory() + "/Applications"
                ]
                
                for searchPath in searchPaths {
                    let url = URL(fileURLWithPath: searchPath)
                    guard let enumerator = FileManager.default.enumerator(at: url, includingPropertiesForKeys: [.isDirectoryKey, .isApplicationKey]) else { continue }
                    
                    for case let fileURL as URL in enumerator {
                        guard fileURL.pathExtension == "app" else { continue }
                        
                        if let app = loadAppInfo(from: fileURL) {
                            apps.append(app)
                        }
                    }
                }
                
                // Remove duplicates based on bundle ID
                var seenBundleIDs = Set<String>()
                apps = apps.filter { app in
                    if seenBundleIDs.contains(app.bundleID) {
                        return false
                    } else {
                        seenBundleIDs.insert(app.bundleID)
                        return true
                    }
                }
                
                continuation.resume(returning: apps)
            }
        }
    }
    
    private static func loadAppInfo(from url: URL) -> InstalledApp? {
        guard let bundle = Bundle(url: url),
              let bundleID = bundle.bundleIdentifier,
              let name = bundle.localizedInfoDictionary?["CFBundleDisplayName"] as? String ??
                         bundle.infoDictionary?["CFBundleDisplayName"] as? String ??
                         bundle.infoDictionary?["CFBundleName"] as? String else {
            return nil
        }
        
        // Get app icon
        let icon = NSWorkspace.shared.icon(forFile: url.path)
        
        return InstalledApp(
            name: name,
            bundleID: bundleID,
            path: url.path,
            icon: icon
        )
    }
}

#Preview {
    AppSelectorView(appModel: AppModel.shared)
}