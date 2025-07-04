//
//  BeautifulMainContentView.swift
//  ShortcutsKeeper
//
//  Created by Claude on 7/4/25.
//

import SwiftUI

// MARK: - Beautiful Main Content View

struct BeautifulMainContentView: View {
    let selectedSection: SidebarSection
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var navigationTitle: String {
        switch selectedSection {
        case .allApps:
            if let app = appModel.selectedApplication {
                return app.name
            } else {
                return "Applications"
            }
        default:
            return selectedSection.rawValue
        }
    }
    
    var body: some View {
        Group {
            switch selectedSection {
            case .myShortcuts:
                BeautifulAllShortcutsView(appModel: appModel, selectedShortcut: $selectedShortcut)
            case .allApps:
                if let app = appModel.selectedApplication {
                    BeautifulAppShortcutsView(application: app, appModel: appModel, selectedShortcut: $selectedShortcut)
                } else {
                    BeautifulAppSelectionView(appModel: appModel)
                }
            case .allTags:
                BeautifulTaggedShortcutsView(appModel: appModel, selectedShortcut: $selectedShortcut)
            case .bin:
                BeautifulBinView(appModel: appModel)
            }
        }
        .background(.regularMaterial)
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Context-specific toolbar items with enhanced design
                if selectedSection == .myShortcuts {
                    BeautifulToolbarButton(
                        title: "Add Shortcut",
                        systemImage: "plus",
                        style: .prominent
                    ) {
                        appModel.showNewShortcutSheet = true
                    }
                }
                
                if selectedSection == .allApps, appModel.selectedApplication != nil {
                    BeautifulToolbarButton(
                        title: "Add Shortcut",
                        systemImage: "plus",
                        style: .prominent
                    ) {
                        appModel.showNewShortcutSheet = true
                    }
                    
                    BeautifulToolbarButton(
                        title: "Extract Shortcuts",
                        systemImage: "wand.and.stars",
                        style: .normal
                    ) {
                        if let app = appModel.selectedApplication {
                            Task {
                                await appModel.extractShortcutsFromRunningApp(app)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Beautiful All Shortcuts View

struct BeautifulAllShortcutsView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @State private var sortOption: ShortcutSortOption = .name
    @State private var groupByApp = false
    @AppStorage("useTableView") private var useTableView = false
    
    var sortedShortcuts: [Shortcut] {
        let filtered = appModel.shortcuts.filter { !($0.isDeleted ?? false) }
        
        switch sortOption {
        case .name:
            return filtered.sorted { $0.title < $1.title }
        case .app:
            return filtered.sorted { ($0.application?.name ?? "") < ($1.application?.name ?? "") }
        case .recent:
            return filtered.sorted { ($0.dateAdded ?? Date.distantPast) > ($1.dateAdded ?? Date.distantPast) }
        case .frequency:
            return filtered.sorted { ($0.usageCount ?? 0) > ($1.usageCount ?? 0) }
        }
    }
    
    var groupedShortcuts: [String: [Shortcut]] {
        Dictionary(grouping: sortedShortcuts) { shortcut in
            shortcut.application?.name ?? "No Application"
        }
    }
    
    var body: some View {
        if useTableView {
            // Table view layout
            TableShortcutListView(appModel: appModel, selectedShortcut: $selectedShortcut)
        } else {
            // Card view layout
            VStack(spacing: 0) {
                // Beautiful header with controls
                BeautifulContentHeader(
                    title: "My Shortcuts",
                    subtitle: "Your personal collection of keyboard shortcuts",
                    count: sortedShortcuts.count,
                    sortOption: $sortOption,
                    groupByApp: $groupByApp
                ) {
                    appModel.showNewShortcutSheet = true
                }
                
                // Content area
                if sortedShortcuts.isEmpty {
                    BeautifulEmptyState(
                        icon: "keyboard",
                        title: "No shortcuts yet",
                        subtitle: "Add your first shortcut to get started organizing your workflow and boost your productivity",
                        action: { appModel.showNewShortcutSheet = true },
                        actionTitle: "Add Your First Shortcut"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            if groupByApp {
                                ForEach(groupedShortcuts.keys.sorted(), id: \.self) { appName in
                                    VStack(alignment: .leading, spacing: 12) {
                                        BeautifulSectionHeader(
                                            title: appName,
                                            subtitle: nil,
                                            count: groupedShortcuts[appName]?.count
                                        )
                                        
                                        LazyVStack(spacing: 12) {
                                            ForEach(groupedShortcuts[appName] ?? []) { shortcut in
                                                BeautifulShortcutRow(shortcut: shortcut, appModel: appModel)
                                            }
                                        }
                                    }
                                }
                            } else {
                                ForEach(sortedShortcuts) { shortcut in
                                    BeautifulShortcutRow(shortcut: shortcut, appModel: appModel)
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Beautiful App Shortcuts View

struct BeautifulAppShortcutsView: View {
    let application: Application
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    @AppStorage("useTableView") private var useTableView = false
    
    var appShortcuts: [Shortcut] {
        appModel.shortcuts.filter { 
            $0.application == application && !($0.isDeleted ?? false)
        }.sorted { $0.title < $1.title }
    }
    
    var body: some View {
        if useTableView {
            // Table view with filtered shortcuts for this app
            VStack(spacing: 0) {
                BeautifulAppHeader(application: application, shortcutCount: appShortcuts.count, appModel: appModel)
                
                if appShortcuts.isEmpty {
                    BeautifulEmptyState(
                        icon: "keyboard",
                        title: "No shortcuts for \(application.name)",
                        subtitle: "Add shortcuts for this application or extract them automatically from the running app to start organizing your workflow",
                        action: { appModel.showNewShortcutSheet = true },
                        actionTitle: "Add Shortcut"
                    )
                } else {
                    FilteredTableShortcutListView(shortcuts: appShortcuts, appModel: appModel, selectedShortcut: $selectedShortcut)
                }
            }
        } else {
            // Card view layout
            VStack(spacing: 0) {
                // Beautiful app header
                BeautifulAppHeader(application: application, shortcutCount: appShortcuts.count, appModel: appModel)
                
                // Content area
                if appShortcuts.isEmpty {
                    BeautifulEmptyState(
                        icon: "keyboard",
                        title: "No shortcuts for \(application.name)",
                        subtitle: "Add shortcuts for this application or extract them automatically from the running app to start organizing your workflow",
                        action: { appModel.showNewShortcutSheet = true },
                        actionTitle: "Add Shortcut"
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(appShortcuts) { shortcut in
                                BeautifulShortcutRow(shortcut: shortcut, appModel: appModel, showAppName: false)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                    }
                }
            }
        }
    }
}

// MARK: - Support Views

struct BeautifulContentHeader: View {
    let title: String
    let subtitle: String
    let count: Int
    @Binding var sortOption: ShortcutSortOption
    @Binding var groupByApp: Bool
    let onAddShortcut: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Title and description
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text(subtitle)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    Text("\(count) shortcuts")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.blue.opacity(0.1), in: Capsule())
                }
            }
            
            // Controls
            HStack(spacing: 12) {
                // Sort options
                Menu {
                    ForEach(ShortcutSortOption.allCases, id: \.self) { option in
                        Button(option.rawValue) {
                            sortOption = option
                        }
                    }
                    
                    Divider()
                    
                    Toggle("Group by Application", isOn: $groupByApp)
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.callout)
                        Text("Sort")
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .foregroundColor(.primary)
                }
                .menuStyle(.borderlessButton)
                
                Spacer()
                
                // Add shortcut button
                Button(action: onAddShortcut) {
                    HStack(spacing: 6) {
                        Image(systemName: "plus")
                            .font(.callout)
                        Text("Add Shortcut")
                            .font(.callout)
                            .fontWeight(.semibold)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.blue, in: Capsule())
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(.thickMaterial)
    }
}

struct BeautifulAppHeader: View {
    let application: Application
    let shortcutCount: Int
    @Bindable var appModel: AppModel
    
    var body: some View {
        HStack(spacing: 20) {
            // App icon
            AppIconView(application: application, size: 64)
            
            // App info
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    Text(application.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    if application.isSystemApp {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.title3)
                            .foregroundColor(.blue)
                    }
                }
                
                Text("\(shortcutCount) keyboard shortcuts")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Actions
            VStack(spacing: 8) {
                BeautifulToolbarButton(
                    title: "Extract Shortcuts",
                    systemImage: "wand.and.stars",
                    style: .normal
                ) {
                    Task {
                        await appModel.extractShortcutsFromRunningApp(application)
                    }
                }
                
                BeautifulToolbarButton(
                    title: "Add Shortcut",
                    systemImage: "plus",
                    style: .prominent
                ) {
                    appModel.selectedApplication = application
                    appModel.showNewShortcutSheet = true
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .background(.thickMaterial)
    }
}

struct BeautifulToolbarButton: View {
    let title: String
    let systemImage: String
    let style: Style
    let action: () -> Void
    
    enum Style {
        case normal, prominent
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                    .font(.callout)
                Text(title)
                    .font(.callout)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                style == .prominent ? 
                AnyShapeStyle(.blue) : 
                AnyShapeStyle(.regularMaterial),
                in: Capsule()
            )
            .foregroundColor(
                style == .prominent ? 
                .white : 
                .primary
            )
            .shadow(
                color: style == .prominent ? .blue.opacity(0.3) : .clear,
                radius: style == .prominent ? 2 : 0,
                y: style == .prominent ? 1 : 0
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
        .pressEvents(
            onPress: { isPressed = true },
            onRelease: { isPressed = false }
        )
    }
}

// MARK: - Additional Views

struct BeautifulAppSelectionView: View {
    @Bindable var appModel: AppModel
    
    var body: some View {
        BeautifulEmptyState(
            icon: "square.grid.2x2",
            title: "Select an Application",
            subtitle: "Choose an app from the sidebar to view and organize its keyboard shortcuts",
            action: appModel.filteredApplications.isEmpty ? {
                Task {
                    await appModel.scanForAllApplications()
                }
            } : nil,
            actionTitle: appModel.filteredApplications.isEmpty ? "Scan for Applications" : nil
        )
    }
}

struct BeautifulTaggedShortcutsView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var body: some View {
        VStack {
            Text("Tagged Shortcuts")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Feature coming soon...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct BeautifulBinView: View {
    @Bindable var appModel: AppModel
    
    var body: some View {
        VStack {
            Text("Bin")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Deleted shortcuts will appear here")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    BeautifulMainContentView(
        selectedSection: .myShortcuts,
        appModel: AppModel.shared,
        selectedShortcut: Binding.constant(nil)
    )
    .frame(width: 800, height: 600)
}