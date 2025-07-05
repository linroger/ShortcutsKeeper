//
//  ContentView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI
import SwiftData

// MARK: - Theme Support

enum AppTheme: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}

// MARK: - Enhanced Content View with Two-Column Layout

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedShortcut: Shortcut?
    @State private var columnVisibility = NavigationSplitViewVisibility.all
    @State private var showGlobalSearch = false
    @State private var showAdvancedSearch = false
    @State private var selectedSidebarSection: SidebarSection = .myShortcuts
    @State private var showWelcome = false
    @State private var showAbout = false
    @State private var showSettings = false
    @State private var showAppSelector = false
    
    @State private var appModel = AppModel.shared
    @StateObject private var globalHotkeyService = GlobalHotkeyService()
    @AppStorage("appTheme") private var appTheme = AppTheme.system
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            // Beautiful native macOS sidebar with translucent effects
            BeautifulSidebarView(
                appModel: appModel, 
                selectedSection: $selectedSidebarSection, 
                showWelcome: $showWelcome, 
                showAbout: $showAbout,
                showSettings: $showSettings,
                showAppSelector: $showAppSelector
            )
            .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 340)
            .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
        } detail: {
            // Main content view with enhanced native design
            BeautifulMainContentView(
                selectedSection: selectedSidebarSection, 
                appModel: appModel, 
                selectedShortcut: $selectedShortcut
            )
            .navigationSplitViewColumnWidth(min: 600, ideal: 900)
            .toolbarBackground(.ultraThinMaterial, for: .windowToolbar)
        }
        .navigationTitle("")
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        columnVisibility = columnVisibility == .all ? .detailOnly : .all
                    }
                }) {
                    Label("Toggle Sidebar", systemImage: "sidebar.left")
                }
                .help("Toggle sidebar visibility")
                
                Spacer()
                
                HStack {
                    Text("Applications")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("(\(appModel.filteredApplicationsCount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Menu {
                        Toggle("Show System Apps", isOn: .init(
                            get: { UserDefaults.standard.bool(forKey: "showSystemApps") },
                            set: { UserDefaults.standard.set($0, forKey: "showSystemApps") }
                        ))
                        
                        Divider()
                        
                        Button("Refresh Apps") {
                            Task {
                                await appModel.scanForAllApplications()
                            }
                        }
                        .disabled(appModel.isScanning)
                        
                        if !appModel.hiddenApplications.isEmpty {
                            Divider()
                            
                            Button("Show All Hidden Apps") {
                                appModel.restoreAllHiddenApplications()
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.secondary)
                    }
                    .menuStyle(.borderlessButton)
                }
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                Button(action: { appModel.showNewShortcutSheet = true }) {
                    Label("Add Shortcut", systemImage: "plus")
                }
                
                Button(action: { appModel.showCaptureWindow = true }) {
                    Label("Capture Shortcut", systemImage: "keyboard")
                }
                .help("Press to capture a keyboard shortcut and find where it's used")
                
                Menu {
                    Button("Extract from Running App") {
                        if let app = appModel.selectedApplication {
                            Task {
                                await appModel.extractShortcutsFromRunningApp(app)
                            }
                        }
                    }
                    .disabled(appModel.selectedApplication == nil)
                    
                    Button("Load Common Shortcuts") {
                        loadCommonShortcuts()
                    }
                    .disabled(appModel.selectedApplication == nil)
                } label: {
                    Label("Extract Shortcuts", systemImage: "wand.and.stars")
                }
                
                Button(action: { showGlobalSearch = true }) {
                    Label("Global Search", systemImage: "magnifyingglass.circle")
                }
                .help("Search all shortcuts across applications")
                
                Button(action: { showAdvancedSearch = true }) {
                    Label("Advanced Search", systemImage: "magnifyingglass.circle.fill")
                }
                .help("Advanced search with filters and sorting")
                
                Button(action: { showSettings = true }) {
                    Label("Settings", systemImage: "gear")
                }
                
                Button(action: { showAppSelector = true }) {
                    Label("Add Apps", systemImage: "plus.app")
                }
                .help("Add applications to track shortcuts")
            }
        }
        .searchable(text: $appModel.searchText, prompt: "Search shortcuts...")
        .sheet(isPresented: $appModel.showNewShortcutSheet) {
            ModernNewShortcutView(appModel: appModel)
        }
        .sheet(isPresented: $appModel.showCaptureWindow) {
            ModernShortcutCaptureView(appModel: appModel)
        }
        .sheet(isPresented: $showSettings) {
            EnhancedSettingsView(appModel: appModel)
        }
        .sheet(isPresented: $showAppSelector) {
            AppSelectorView(appModel: appModel)
        }
        .sheet(isPresented: $showGlobalSearch) {
            GlobalSearchView(appModel: appModel)
        }
        .sheet(isPresented: $showAdvancedSearch) {
            AdvancedSearchView(appModel: appModel)
        }
        .sheet(isPresented: $appModel.showEditShortcutSheet) {
            if let shortcut = appModel.selectedShortcut {
                EditShortcutWrapper(shortcut: shortcut, appModel: appModel)
            }
        }
        .keyboardNavigation(appModel: appModel)
        .onAppear {
            appModel.setup(with: modelContext)
            setupGlobalHotkey()
            checkFirstLaunch()
        }
        .onReceive(NotificationCenter.default.publisher(for: .selectedShortcutChanged)) { notification in
            if let shortcut = notification.object as? Shortcut {
                selectedShortcut = shortcut
            }
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeOnboardingView(appModel: appModel)
        }
        .sheet(isPresented: $showAbout) {
            AboutFAQView()
        }
        .preferredColorScheme(appTheme.colorScheme)
    }
    
    private func checkFirstLaunch() {
        if !UserDefaults.standard.bool(forKey: "hasLaunchedBefore") {
            showWelcome = true
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
    private func loadCommonShortcuts() {
        guard let app = appModel.selectedApplication else { return }
        
        let extractor = AccessibilityShortcutExtractor()
        let commonShortcuts = extractor.getCommonShortcuts(for: app.bundleIdentifier)
        
        for shortcutInfo in commonShortcuts {
            appModel.addShortcut(
                title: shortcutInfo.title,
                keyCombination: shortcutInfo.keyCombination,
                description: shortcutInfo.description,
                category: shortcutInfo.category,
                application: app,
                tags: ["Common"]
            )
        }
    }
    
    private func setupGlobalHotkey() {
        globalHotkeyService.onHotKeyPressed = {
            NSApp.activate(ignoringOtherApps: true)
            if let window = NSApp.windows.first {
                window.makeKeyAndOrderFront(nil)
            }
        }
        
        // Set up default hotkey (Cmd+Option+K)
        if let (keyCode, modifiers) = GlobalHotkeyService.parseKeyCombo("⌘⌥K") {
            _ = globalHotkeyService.registerHotKey(keyCode: keyCode, modifiers: modifiers)
        }
    }
}

// MARK: - Sidebar Section Enum

enum SidebarSection: String, CaseIterable, Identifiable {
    case myShortcuts = "My Shortcuts"
    case allApps = "All Apps" 
    case allTags = "All Tags"
    case bin = "Bin"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .myShortcuts: return "house.fill"
        case .allApps: return "square.grid.2x2"
        case .allTags: return "tag.fill"
        case .bin: return "trash.fill"
        }
    }
}

// MARK: - Enhanced Sidebar View

struct EnhancedSidebarView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedSection: SidebarSection
    @Binding var showWelcome: Bool
    @Binding var showAbout: Bool
    @Binding var showSettings: Bool
    @Binding var showAppSelector: Bool
    @State private var showAllApps = true
    @State private var showAllTags = true
    
    var body: some View {
        List(selection: $selectedSection) {
            // Main shortcuts section
            Section {
                NavigationLink(value: SidebarSection.myShortcuts) {
                    HStack {
                        Image(systemName: "house.fill")
                            .foregroundColor(.accentColor)
                            .frame(width: 16)
                        Text("My Shortcuts")
                        Spacer()
                        Text("\(appModel.shortcuts.count)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .listRowBackground(
                    selectedSection == .myShortcuts ? 
                    Color.accentColor.opacity(0.2) : 
                    Color.clear
                )
            }
            
            // Applications section
            Section("Applications") {
                DisclosureGroup(
                    isExpanded: $showAllApps,
                    content: {
                        ForEach(appModel.filteredApplications) { app in
                            AppSidebarRow(application: app, appModel: appModel, selectedSection: $selectedSection)
                        }
                        
                        // Add more apps button
                        Button(action: { showAppSelector = true }) {
                            HStack {
                                Image(systemName: "plus.app")
                                    .foregroundColor(.accentColor)
                                    .frame(width: 16)
                                Text("Add Applications...")
                                    .foregroundColor(.accentColor)
                                Spacer()
                            }
                        }
                        .buttonStyle(.plain)
                    },
                    label: {
                        HStack {
                            Image(systemName: "square.grid.2x2")
                                .foregroundColor(.blue)
                                .frame(width: 16)
                            Text("All Apps")
                            Spacer()
                            Text("\(appModel.filteredApplicationsCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                )
            }
            
            // Tags section
            Section("Tags") {
                DisclosureGroup(
                    isExpanded: $showAllTags,
                    content: {
                        ForEach(appModel.allTags, id: \.self) { tag in
                            TagSidebarRow(tag: tag, appModel: appModel)
                        }
                    },
                    label: {
                        HStack {
                            Image(systemName: "tag.fill")
                                .foregroundColor(.orange)
                                .frame(width: 16)
                            Text("All Tags")
                            Spacer()
                            Text("\(appModel.allTags.count)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                )
            }
            
            // Utilities section
            Section("Utilities") {
                NavigationLink(value: SidebarSection.bin) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 16)
                        Text("Bin")
                        Spacer()
                        let deletedCount = appModel.shortcuts.filter { $0.isDeleted ?? false }.count
                        if deletedCount > 0 {
                            Text("\(deletedCount)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .listRowBackground(
                    selectedSection == .bin ? 
                    Color.red.opacity(0.2) : 
                    Color.clear
                )
            }
            
            // Quick actions section
            Section {
                Button(action: { showSettings = true }) {
                    HStack {
                        Image(systemName: "gear")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text("Settings")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
                
                Button(action: { showAbout = true }) {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.secondary)
                            .frame(width: 16)
                        Text("About & FAQ")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .listStyle(.sidebar)
        .background(.thinMaterial.opacity(0.8))
        .navigationTitle("")
    }
}

// MARK: - Main Content View (Two-Column Layout)

struct MainContentView: View {
    let selectedSection: SidebarSection
    @Bindable var appModel: AppModel
    @Binding var selectedShortcut: Shortcut?
    
    var navigationTitle: String {
        switch selectedSection {
        case .allApps:
            if let app = appModel.selectedApplication {
                return app.name
            } else {
                return "All Apps"
            }
        default:
            return selectedSection.rawValue
        }
    }
    
    var body: some View {
        Group {
            switch selectedSection {
            case .myShortcuts:
                EnhancedAllShortcutsView(appModel: appModel, selectedShortcut: $selectedShortcut)
            case .allApps:
                if let app = appModel.selectedApplication {
                    EnhancedAppShortcutsView(application: app, appModel: appModel, selectedShortcut: $selectedShortcut)
                } else {
                    AppSelectionView(appModel: appModel)
                }
            case .allTags:
                EnhancedTaggedShortcutsView(appModel: appModel, selectedShortcut: $selectedShortcut)
            case .bin:
                EnhancedBinView(appModel: appModel)
            }
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                // Context-specific toolbar items
                if selectedSection == .myShortcuts {
                    Button(action: { appModel.showNewShortcutSheet = true }) {
                        Label("Add Shortcut", systemImage: "plus")
                    }
                }
                
                if selectedSection == .allApps, appModel.selectedApplication != nil {
                    Button(action: { appModel.showNewShortcutSheet = true }) {
                        Label("Add Shortcut", systemImage: "plus")
                    }
                    
                    Button("Extract Shortcuts") {
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

// MARK: - Helper Views

struct AppSidebarRow: View {
    let application: Application
    @Bindable var appModel: AppModel
    @Binding var selectedSection: SidebarSection
    
    var isSelected: Bool {
        appModel.selectedApplication == application && selectedSection == .allApps
    }
    
    var body: some View {
        Button(action: {
            appModel.selectedApplication = application
            selectedSection = .allApps
        }) {
            HStack {
                // Small app icon (16x16)
                if let icon = application.icon {
                    Image(nsImage: icon)
                        .resizable()
                        .frame(width: 16, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                } else {
                    Image(systemName: "app")
                        .foregroundColor(isSelected ? .white : .secondary)
                        .frame(width: 16, height: 16)
                }
                
                Text(application.name)
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Spacer()
                
                let shortcutCount = appModel.shortcuts.filter { $0.application == application }.count
                if shortcutCount > 0 {
                    Text("\(shortcutCount)")
                        .font(.caption)
                        .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(isSelected ? Color.white.opacity(0.2) : Color.secondary.opacity(0.2))
                        .clipShape(Capsule())
                }
            }
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.blue : Color.clear)
        )
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .contextMenu {
            Button {
                // Select the app and add a new shortcut
                appModel.selectedApplication = application
                selectedSection = .allApps
                appModel.showNewShortcutSheet = true
            } label: {
                Label("Add Shortcut to \(application.name)", systemImage: "plus")
            }
            
            Divider()
            
            Button(role: .destructive) {
                // Remove app from sidebar
                appModel.removeApplication(application)
            } label: {
                Label("Remove \(application.name) from Sidebar", systemImage: "minus.circle")
            }
        }
    }
}

struct TagSidebarRow: View {
    let tag: String
    @Bindable var appModel: AppModel
    
    var body: some View {
        Button(action: {
            appModel.selectedTag = tag
        }) {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(.orange)
                    .frame(width: 16)
                Text(tag)
                    .lineLimit(1)
                Spacer()
                let count = appModel.shortcuts.filter { $0.tags.contains(tag) }.count
                Text("\(count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.2))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
        .foregroundColor(.primary)
    }
}

struct DetailEmptyView: View {
    let selectedSection: SidebarSection
    
    var body: some View {
        VStack {
            Image(systemName: selectedSection.icon)
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            Text("Select an item to view details")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension Notification.Name {
    static let selectedShortcutChanged = Notification.Name("selectedShortcutChanged")
}

// MARK: - Edit Shortcut Wrapper

struct EditShortcutWrapper: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        let viewModel = ShortcutsViewModel()
        EditShortcutView(shortcut: shortcut, viewModel: viewModel)
            .onAppear {
                viewModel.setup(with: modelContext)
            }
            .onDisappear {
                appModel.showEditShortcutSheet = false
                appModel.fetchData() // Refresh data after edit
            }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Shortcut.self, Application.self], inMemory: true)
}
