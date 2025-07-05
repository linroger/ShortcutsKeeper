//
//  BeautifulSidebarView.swift
//  ShortcutsKeeper
//
//  Created by Claude on 7/4/25.
//

import SwiftUI
import SwiftData

// MARK: - Beautiful Native Sidebar

struct BeautifulSidebarView: View {
    @Bindable var appModel: AppModel
    @Binding var selectedSection: SidebarSection
    @Binding var showWelcome: Bool
    @Binding var showAbout: Bool
    @Binding var showSettings: Bool
    @Binding var showAppSelector: Bool
    @State private var showAllApps = true
    @State private var showAllTags = true
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Main shortcuts section
                BeautifulSidebarSection {
                    BeautifulSidebarRow(
                        icon: "house.fill",
                        title: "My Shortcuts",
                        count: appModel.shortcuts.count,
                        color: .blue,
                        isSelected: selectedSection == .myShortcuts
                    ) {
                        selectedSection = .myShortcuts
                    }
                }
                
                // Applications section
                BeautifulSidebarSection(title: "Applications") {
                    DisclosureGroup(
                        isExpanded: $showAllApps,
                        content: {
                            VStack(spacing: 8) {
                                ForEach(appModel.filteredApplications) { app in
                                    BeautifulAppSidebarRow(
                                        application: app,
                                        appModel: appModel,
                                        selectedSection: $selectedSection
                                    )
                                }
                                
                                // Add more apps button
                                AddAppsButton(showAppSelector: $showAppSelector)
                            }
                            .padding(.leading, 12)
                        },
                        label: {
                            BeautifulSidebarRow(
                                icon: "square.grid.2x2",
                                title: "All Apps",
                                count: appModel.filteredApplicationsCount,
                                color: .purple,
                                isSelected: false,
                                showChevron: true
                            ) {}
                        }
                    )
                    .disclosureGroupStyle(BeautifulDisclosureGroupStyle())
                }
                
                // Tags section
                BeautifulSidebarSection(title: "Tags") {
                    DisclosureGroup(
                        isExpanded: $showAllTags,
                        content: {
                            VStack(spacing: 8) {
                                ForEach(appModel.allTags, id: \.self) { tag in
                                    BeautifulTagSidebarRow(tag: tag, appModel: appModel)
                                }
                            }
                            .padding(.leading, 12)
                        },
                        label: {
                            BeautifulSidebarRow(
                                icon: "tag.fill",
                                title: "All Tags",
                                count: appModel.allTags.count,
                                color: .orange,
                                isSelected: false,
                                showChevron: true
                            ) {}
                        }
                    )
                    .disclosureGroupStyle(BeautifulDisclosureGroupStyle())
                }
                
                // Utilities section
                BeautifulSidebarSection(title: "Utilities") {
                    BeautifulSidebarRow(
                        icon: "trash.fill",
                        title: "Bin",
                        count: appModel.shortcuts.filter { $0.isDeleted ?? false }.count,
                        color: .red,
                        isSelected: selectedSection == .bin
                    ) {
                        selectedSection = .bin
                    }
                }
                
                // Quick actions section
                BeautifulSidebarSection {
                    VStack(spacing: 8) {
                        SettingsButton(showSettings: $showSettings)
                        AboutButton(showAbout: $showAbout)
                    }
                }
            }
            .padding(16)
        }
        .background(.regularMaterial)
        .scrollContentBackground(.hidden)
    }
}

struct BeautifulSidebarSection<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content
    
    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let title = title {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
            }
            
            content
        }
    }
}

struct BeautifulSidebarRow: View {
    let icon: String
    let title: String
    let count: Int?
    let color: Color
    let isSelected: Bool
    let showChevron: Bool
    let action: () -> Void
    
    @State private var isHovered = false
    
    init(
        icon: String,
        title: String,
        count: Int? = nil,
        color: Color,
        isSelected: Bool,
        showChevron: Bool = false,
        action: @escaping () -> Void
    ) {
        self.icon = icon
        self.title = title
        self.count = count
        self.color = color
        self.isSelected = isSelected
        self.showChevron = showChevron
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                // Icon with beautiful styling
                ZStack {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(isSelected ? 1.0 : 0.8),
                                    color.opacity(isSelected ? 0.8 : 0.6)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 24, height: 24)
                    
                    Image(systemName: icon)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                }
                .shadow(color: color.opacity(0.3), radius: 2, y: 1)
                
                // Title and count
                HStack {
                    Text(title)
                        .font(.callout)
                        .fontWeight(.medium)
                        .foregroundColor(isSelected ? .primary : .primary)
                    
                    Spacer()
                    
                    if let count = count, count > 0 {
                        Text("\(count)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(isSelected ? color : .secondary)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(isSelected ? AnyShapeStyle(color.opacity(0.2)) : AnyShapeStyle(.ultraThinMaterial))
                            )
                    }
                    
                    if showChevron {
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .rotationEffect(.degrees(showChevron ? 0 : 90))
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        isSelected ? 
                        AnyShapeStyle(LinearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )) : 
                        (isHovered ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isSelected ? color.opacity(0.4) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        // ACCESSIBILITY: Enhanced VoiceOver support
        .accessibilityLabel(count != nil ? "\(title), \(count!) items" : title)
        .accessibilityHint(isSelected ? "Currently selected" : "Tap to select \(title) section")
        .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : [.isButton])
    }
}

struct BeautifulAppSidebarRow: View {
    let application: Application
    @Bindable var appModel: AppModel
    @Binding var selectedSection: SidebarSection
    @State private var isHovered = false
    
    var isSelected: Bool {
        appModel.selectedApplication == application && selectedSection == .allApps
    }
    
    var shortcutCount: Int {
        appModel.shortcuts.filter { $0.application == application }.count
    }
    
    var body: some View {
        Button(action: {
            appModel.selectedApplication = application
            selectedSection = .allApps
        }) {
            HStack(spacing: 10) {
                // App icon
                AppIconView(application: application, size: 20)
                
                // App info
                VStack(alignment: .leading, spacing: 2) {
                    Text(application.name)
                        .font(.callout)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundColor(isSelected ? .primary : .primary)
                    
                    if shortcutCount > 0 {
                        Text("\(shortcutCount) shortcut\(shortcutCount == 1 ? "" : "s")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer(minLength: 4)
                
                // System app indicator
                if application.isSystemApp {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.caption2)
                        .foregroundColor(.blue)
                        .opacity(0.7)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(
                        isSelected ? 
                        AnyShapeStyle(LinearGradient(
                            colors: [
                                .blue.opacity(0.3),
                                .blue.opacity(0.2)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )) : 
                        (isHovered ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(
                                isSelected ? .blue.opacity(0.4) : Color.clear,
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
        .contextMenu {
            AppContextMenu(application: application, appModel: appModel, selectedSection: $selectedSection)
        }
    }
}

struct BeautifulTagSidebarRow: View {
    let tag: String
    @Bindable var appModel: AppModel
    @State private var isHovered = false
    
    var shortcutCount: Int {
        appModel.shortcuts.filter { $0.tags.contains(tag) }.count
    }
    
    var body: some View {
        Button(action: {
            appModel.selectedTag = tag
        }) {
            HStack(spacing: 8) {
                Image(systemName: "tag")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .frame(width: 16)
                
                Text(tag)
                    .font(.callout)
                    .fontWeight(.medium)
                    .lineLimit(1)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("\(shortcutCount)")
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct AddAppsButton: View {
    @Binding var showAppSelector: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: { showAppSelector = true }) {
            HStack(spacing: 8) {
                Image(systemName: "plus.app")
                    .font(.caption)
                    .foregroundColor(.blue)
                    .frame(width: 16)
                
                Text("Add Applications...")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(isHovered ? .blue.opacity(0.1) : .clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.blue.opacity(0.3), lineWidth: 1)
                            .opacity(isHovered ? 1 : 0)
                    )
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct SettingsButton: View {
    @Binding var showSettings: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: { showSettings = true }) {
            HStack(spacing: 12) {
                Image(systemName: "gear")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
                
                Text("Settings")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct AboutButton: View {
    @Binding var showAbout: Bool
    @State private var isHovered = false
    
    var body: some View {
        Button(action: { showAbout = true }) {
            HStack(spacing: 12) {
                Image(systemName: "info.circle")
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(width: 16)
                
                Text("About & FAQ")
                    .font(.callout)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isHovered ? AnyShapeStyle(.ultraThinMaterial) : AnyShapeStyle(.clear))
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.15)) {
                isHovered = hovering
            }
        }
    }
}

struct AppContextMenu: View {
    let application: Application
    @Bindable var appModel: AppModel
    @Binding var selectedSection: SidebarSection
    
    var body: some View {
        Button {
            appModel.selectedApplication = application
            selectedSection = .allApps
            appModel.showNewShortcutSheet = true
        } label: {
            Label("Add Shortcut to \(application.name)", systemImage: "plus")
        }
        
        Button {
            appModel.selectedApplication = application
            selectedSection = .allApps
            appModel.showCaptureWindow = true
        } label: {
            Label("Assign Keyboard Shortcut", systemImage: "keyboard")
        }
        
        Divider()
        
        Button {
            appModel.openApplicationInFinder(application)
        } label: {
            Label("Show in Finder", systemImage: "folder")
        }
        
        Button {
            appModel.launchApplication(application)
        } label: {
            Label("Launch \(application.name)", systemImage: "play")
        }
        
        Divider()
        
        Button(role: .destructive) {
            appModel.removeApplication(application)
        } label: {
            Label("Remove from Sidebar", systemImage: "minus.circle")
        }
    }
}

struct BeautifulDisclosureGroupStyle: DisclosureGroupStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    configuration.isExpanded.toggle()
                }
            } label: {
                configuration.label
            }
            .buttonStyle(.plain)
            
            if configuration.isExpanded {
                configuration.content
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity.combined(with: .move(edge: .top))
                    ))
            }
        }
    }
}

#Preview {
    BeautifulSidebarView(
        appModel: AppModel.shared,
        selectedSection: Binding.constant(.myShortcuts),
        showWelcome: Binding.constant(false),
        showAbout: Binding.constant(false),
        showSettings: Binding.constant(false),
        showAppSelector: Binding.constant(false)
    )
    .frame(width: 280, height: 600)
}