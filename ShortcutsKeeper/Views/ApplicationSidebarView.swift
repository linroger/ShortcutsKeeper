//
//  ApplicationSidebarView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct ApplicationSidebarView: View {
    let viewModel: ShortcutsViewModel
    @Binding var selection: Application?
    @AppStorage("showSystemApps") private var showSystemApps = true
    
    private var filteredApplications: [Application] {
        viewModel.applications
            .filter { showSystemApps || !$0.isSystemApp }
            .sorted { $0.name < $1.name }
    }
    
    var body: some View {
        List(selection: $selection) {
            if viewModel.isScanning {
                Section {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Scanning for applications...")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
            
            Section("Applications") {
                ForEach(filteredApplications) { app in
                    ApplicationSidebarRow(application: app, 
                                        shortcutCount: viewModel.shortcuts.filter { $0.application == app }.count)
                    .tag(app)
                }
            }
            
            if filteredApplications.isEmpty && !viewModel.isScanning {
                Section {
                    VStack(spacing: 12) {
                        Image(systemName: "app.dashed")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No applications found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Button("Scan for Applications") {
                            viewModel.scanForAllApplications()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                }
            }
        }
        .listStyle(SidebarListStyle())
        .navigationTitle("Applications")
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Button(action: viewModel.refreshApplications) {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                .disabled(viewModel.isScanning)
            }
        }
    }
}

struct ApplicationSidebarRow: View {
    let application: Application
    let shortcutCount: Int
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
                    .cornerRadius(6)
            } else {
                Image(systemName: "app.fill")
                    .font(.system(size: 24))
                    .frame(width: 32, height: 32)
                    .foregroundColor(.secondary)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(application.name)
                    .font(.system(.body))
                    .lineLimit(1)
                
                if shortcutCount > 0 {
                    Text("\(shortcutCount) shortcut\(shortcutCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("No shortcuts")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            if application.isSystemApp {
                Image(systemName: "lock.fill")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}