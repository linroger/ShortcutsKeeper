//
//  SettingsView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct SettingsView: View {
    let viewModel: ShortcutsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = "general"
    
    var body: some View {
        TabView(selection: $selectedTab) {
            GeneralSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("General", systemImage: "gear")
                }
                .tag("general")
            
            ApplicationsSettingsView(viewModel: viewModel)
                .tabItem {
                    Label("Applications", systemImage: "app.badge")
                }
                .tag("applications")
        }
        .frame(width: 600, height: 400)
    }
}

struct GeneralSettingsView: View {
    let viewModel: ShortcutsViewModel
    @AppStorage("showSystemApps") private var showSystemApps = true
    @AppStorage("autoScanOnLaunch") private var autoScanOnLaunch = false
    
    var body: some View {
        Form {
            Section {
                Toggle("Show system applications", isOn: $showSystemApps)
                Toggle("Automatically scan for new apps on launch", isOn: $autoScanOnLaunch)
            }
            
            Section("Export & Import") {
                HStack {
                    Button("Export Shortcuts...") {
                        exportShortcuts()
                    }
                    
                    Button("Import Shortcuts...") {
                        importShortcuts()
                    }
                }
            }
        }
        .formStyle(.grouped)
        .padding()
    }
    
    private func exportShortcuts() {
        guard let data = viewModel.exportShortcuts() else { return }
        
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.nameFieldStringValue = "shortcuts.json"
        
        if savePanel.runModal() == .OK, let url = savePanel.url {
            try? data.write(to: url)
        }
    }
    
    private func importShortcuts() {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.json]
        openPanel.allowsMultipleSelection = false
        
        if openPanel.runModal() == .OK, let url = openPanel.url {
            if let data = try? Data(contentsOf: url) {
                viewModel.importShortcuts(from: data)
            }
        }
    }
}

struct ApplicationsSettingsView: View {
    let viewModel: ShortcutsViewModel
    @State private var lastScanDate: Date?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Application Scanning")
                    .font(.headline)
                
                Text("Scan your system to discover installed applications and add them to ShortcutsKeeper.")
                    .foregroundColor(.secondary)
                
                HStack {
                    Button(action: scanApplications) {
                        Label(viewModel.isScanning ? "Scanning..." : "Scan for Applications", 
                              systemImage: viewModel.isScanning ? "arrow.triangle.2.circlepath" : "magnifyingglass")
                    }
                    .disabled(viewModel.isScanning)
                    
                    if viewModel.isScanning {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                
                if let scanDate = lastScanDate {
                    Text("Last scan: \(scanDate.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Application Statistics")
                    .font(.headline)
                
                HStack(spacing: 40) {
                    VStack(alignment: .leading) {
                        Text("\(viewModel.applications.count)")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text("Total Applications")
                            .foregroundColor(.secondary)
                    }
                    
                    VStack(alignment: .leading) {
                        Text("\(viewModel.shortcuts.count)")
                            .font(.largeTitle)
                            .fontWeight(.semibold)
                        Text("Total Shortcuts")
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    private func scanApplications() {
        viewModel.scanForAllApplications()
        lastScanDate = Date()
    }
}