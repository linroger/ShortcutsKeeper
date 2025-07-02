//
//  BackupRestoreView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import UniformTypeIdentifiers

struct BackupRestoreView: View {
    let appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var backupService = BackupRestoreService()
    
    @State private var availableBackups: [BackupInfo] = []
    @State private var selectedBackup: BackupInfo?
    @State private var showBackupDetails = false
    @State private var showRestoreConfirmation = false
    @State private var showCreateBackupSheet = false
    @State private var showImportSheet = false
    @State private var restoreSettings = true
    @State private var includeSettings = true
    @State private var autoBackupEnabled = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            HStack(spacing: 0) {
                backupListView
                
                Divider()
                
                backupDetailsView
            }
        }
        .frame(width: 800, height: 600)
        .onAppear {
            loadBackups()
            autoBackupEnabled = backupService.autoBackupEnabled
        }
        .fileImporter(
            isPresented: $showImportSheet,
            allowedContentTypes: [UTType(filenameExtension: "skbackup") ?? .data],
            allowsMultipleSelection: false
        ) { result in
            handleImportResult(result)
        }
        .sheet(isPresented: $showCreateBackupSheet) {
            CreateBackupSheet(
                backupService: backupService,
                appModel: appModel,
                includeSettings: $includeSettings
            ) {
                loadBackups()
            }
        }
        .alert("Confirm Restore", isPresented: $showRestoreConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Restore", role: .destructive) {
                performRestore()
            }
        } message: {
            Text("This will replace all current shortcuts and applications. This action cannot be undone.")
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Backup & Restore")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                if let lastBackup = backupService.lastBackupDate {
                    Text("Last backup: \(lastBackup.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("No backups found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            HStack(spacing: 12) {
                Toggle("Auto Backup", isOn: $autoBackupEnabled)
                    .onChange(of: autoBackupEnabled) { _, newValue in
                        UserDefaults.standard.set(newValue, forKey: "autoBackupEnabled")
                        if newValue {
                            backupService.setupAutoBackup()
                        }
                    }
                
                Button("Import Backup") {
                    showImportSheet = true
                }
                
                Button("Create Backup") {
                    showCreateBackupSheet = true
                }
                .buttonStyle(.borderedProminent)
                
                Button("Done") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
        }
        .padding()
    }
    
    private var backupListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Available Backups")
                    .font(.headline)
                    .padding()
                
                Spacer()
                
                Button(action: loadBackups) {
                    Image(systemName: "arrow.clockwise")
                }
                .buttonStyle(.plain)
                .padding()
            }
            
            Divider()
            
            if availableBackups.isEmpty {
                ContentUnavailableView {
                    Label("No Backups", systemImage: "archivebox")
                } description: {
                    Text("Create your first backup to get started")
                } actions: {
                    Button("Create Backup") {
                        showCreateBackupSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            } else {
                List(availableBackups, selection: $selectedBackup) { backup in
                    BackupRowView(backup: backup, backupService: backupService)
                        .tag(backup)
                        .contextMenu {
                            Button("Show Details") {
                                selectedBackup = backup
                                showBackupDetails = true
                            }
                            
                            Button("Restore from Backup") {
                                selectedBackup = backup
                                showRestoreConfirmation = true
                            }
                            
                            Divider()
                            
                            Button("Delete Backup", role: .destructive) {
                                deleteBackup(backup)
                            }
                        }
                }
                .listStyle(.plain)
            }
        }
        .frame(width: 350)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var backupDetailsView: some View {
        VStack {
            if let backup = selectedBackup {
                BackupDetailsView(backup: backup, backupService: backupService) {
                    showRestoreConfirmation = true
                }
            } else {
                ContentUnavailableView {
                    Label("Select Backup", systemImage: "sidebar.left")
                } description: {
                    Text("Choose a backup from the list to view details")
                }
            }
        }
    }
    
    private func loadBackups() {
        availableBackups = backupService.getAvailableBackups()
    }
    
    private func deleteBackup(_ backup: BackupInfo) {
        do {
            try backupService.deleteBackup(at: backup.url)
            loadBackups()
            if selectedBackup?.id == backup.id {
                selectedBackup = nil
            }
        } catch {
            print("Failed to delete backup: \(error)")
        }
    }
    
    private func performRestore() {
        guard let backup = selectedBackup else { return }
        
        Task {
            let success = await backupService.restoreFromBackup(
                from: backup.url,
                appModel: appModel,
                restoreSettings: restoreSettings
            )
            
            if success {
                await MainActor.run {
                    dismiss()
                }
            }
        }
    }
    
    private func handleImportResult(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }
            
            Task {
                let success = await backupService.restoreFromBackup(
                    from: url,
                    appModel: appModel,
                    restoreSettings: restoreSettings
                )
                
                if success {
                    await MainActor.run {
                        loadBackups()
                    }
                }
            }
        case .failure(let error):
            print("Import failed: \(error)")
        }
    }
}

struct BackupRowView: View {
    let backup: BackupInfo
    let backupService: BackupRestoreService
    
    @State private var backupDetails: BackupDetails?
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "archivebox.fill")
                .foregroundColor(.accentColor)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(backup.name)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(backup.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let details = backupDetails {
                    HStack {
                        Label("\(details.applicationCount)", systemImage: "app")
                        Label("\(details.shortcutCount)", systemImage: "keyboard")
                        
                        if details.hasSettings {
                            Image(systemName: "gear")
                                .foregroundColor(.secondary)
                        }
                    }
                    .font(.caption2)
                    .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(ByteCountFormatter.string(fromByteCount: Int64(backup.size), countStyle: .file))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            loadBackupDetails()
        }
    }
    
    private func loadBackupDetails() {
        backupDetails = backupService.getBackupDetails(from: backup.url)
    }
}

struct BackupDetailsView: View {
    let backup: BackupInfo
    let backupService: BackupRestoreService
    let onRestore: () -> Void
    
    @State private var backupDetails: BackupDetails?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                if let details = backupDetails {
                    statisticsSection(details)
                    compatibilitySection(details)
                }
                
                Spacer()
                
                actionSection
            }
            .padding()
        }
        .onAppear {
            loadBackupDetails()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(backup.name)
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Created: \(backup.createdAt.formatted(date: .complete, time: .shortened))")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text("Size: \(ByteCountFormatter.string(fromByteCount: Int64(backup.size), countStyle: .file))")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private func statisticsSection(_ details: BackupDetails) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                StatCard(title: "Applications", value: "\(details.applicationCount)", icon: "app.fill")
                StatCard(title: "Shortcuts", value: "\(details.shortcutCount)", icon: "keyboard")
                StatCard(title: "Categories", value: "\(details.categoryCount)", icon: "folder.fill")
                StatCard(title: "Settings", value: details.hasSettings ? "Included" : "None", icon: "gear")
            }
        }
    }
    
    private func compatibilitySection(_ details: BackupDetails) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Compatibility")
                .font(.headline)
            
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text("Compatible with current version")
                    .font(.caption)
            }
            
            Text("Backup version: \(details.version)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    private var actionSection: some View {
        VStack(spacing: 12) {
            Button(action: onRestore) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Restore from Backup")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            
            Text("This will replace all current data")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    private func loadBackupDetails() {
        backupDetails = backupService.getBackupDetails(from: backup.url)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.accentColor)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct CreateBackupSheet: View {
    let backupService: BackupRestoreService
    let appModel: AppModel
    @Binding var includeSettings: Bool
    let onComplete: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var backupName = ""
    @State private var isCreatingBackup = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Backup")
                .font(.title2)
                .fontWeight(.semibold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Backup Name")
                    .font(.headline)
                
                TextField("Enter backup name", text: $backupName)
                    .textFieldStyle(.roundedBorder)
                
                Toggle("Include settings and preferences", isOn: $includeSettings)
            }
            
            if isCreatingBackup {
                VStack {
                    ProgressView(value: backupService.backupProgress)
                        .progressViewStyle(.linear)
                    
                    Text("Creating backup...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .disabled(isCreatingBackup)
                
                Spacer()
                
                Button("Create Backup") {
                    createBackup()
                }
                .buttonStyle(.borderedProminent)
                .disabled(backupName.isEmpty || isCreatingBackup)
            }
        }
        .padding()
        .frame(width: 400)
        .onAppear {
            backupName = "Backup \(Date().formatted(date: .abbreviated, time: .omitted))"
        }
    }
    
    private func createBackup() {
        isCreatingBackup = true
        
        Task {
            if let _ = await backupService.createBackup(appModel: appModel, includeSettings: includeSettings) {
                await MainActor.run {
                    onComplete()
                    dismiss()
                }
            }
            
            await MainActor.run {
                isCreatingBackup = false
            }
        }
    }
}