//
//  BeautifulNativeViews.swift
//  ShortcutsKeeper
//
//  Created by Claude on 7/4/25.
//

import SwiftUI

// MARK: - Enhanced Native macOS Design Components

struct BeautifulShortcutRow: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    var showAppName: Bool = true
    @State private var isHovered = false
    @State private var isSelected = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                // Leading content
                HStack(spacing: 12) {
                    // App icon with enhanced styling
                    if showAppName, let app = shortcut.application {
                        AppIconView(application: app, size: 28)
                    }
                    
                    // Shortcut content
                    VStack(alignment: .leading, spacing: 6) {
                        // Title with enhanced typography
                        HStack(spacing: 8) {
                            Text(shortcut.title)
                                .font(.system(.body, design: .default, weight: .medium))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            if shortcut.isFavorite {
                                Image(systemName: "star.fill")
                                    .font(.caption)
                                    .foregroundColor(.yellow)
                                    .shadow(color: .yellow.opacity(0.3), radius: 1)
                            }
                        }
                        
                        // Description with improved typography
                        if !shortcut.description.isEmpty && shortcut.description != shortcut.title {
                            Text(shortcut.description)
                                .font(.system(.subheadline, design: .default))
                                .foregroundColor(.secondary)
                                .lineLimit(2)
                        }
                        
                        // Enhanced tags and metadata
                        TagsAndMetadataView(shortcut: shortcut, showAppName: showAppName)
                    }
                }
                
                Spacer()
                
                // Enhanced key display with metadata
                VStack(alignment: .trailing, spacing: 8) {
                    // Beautiful key combination display
                    EnhancedKeyDisplayView(
                        keyCombination: shortcut.keyCombination,
                        style: .normal,
                        interactive: false
                    )
                    
                    // Usage statistics with improved design
                    if let usageCount = shortcut.usageCount, usageCount > 0 {
                        HStack(spacing: 4) {
                            Image(systemName: "chart.bar.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            Text("\(usageCount)")
                                .font(.caption2)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(.ultraThinMaterial, in: Capsule())
                    }
                }
            }
            
            // Action buttons with enhanced design (visible on hover)
            if isHovered {
                Divider()
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                
                HStack(spacing: 12) {
                    Spacer()
                    
                    ActionButton(
                        title: "Edit",
                        systemImage: "pencil",
                        color: .blue
                    ) {
                        // Edit action
                    }
                    
                    ActionButton(
                        title: "Duplicate",
                        systemImage: "doc.on.doc",
                        color: .green
                    ) {
                        appModel.duplicateShortcut(shortcut)
                    }
                    
                    ActionButton(
                        title: "Delete",
                        systemImage: "trash",
                        color: .red
                    ) {
                        appModel.deleteShortcut(shortcut)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isSelected ? 
                            .blue.opacity(0.8) : 
                            Color.clear, 
                            lineWidth: 2
                        )
                )
                .shadow(
                    color: isHovered ? .black.opacity(0.1) : .clear,
                    radius: isHovered ? 4 : 0,
                    x: 0,
                    y: isHovered ? 2 : 0
                )
        )
        .scaleEffect(isHovered ? 1.01 : 1.0)
        .animation(.easeInOut(duration: 0.15), value: isHovered)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
        .onHover { hovering in
            isHovered = hovering
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.15)) {
                isSelected.toggle()
            }
        }
        .contextMenu {
            ContextMenuContent(shortcut: shortcut, appModel: appModel)
        }
    }
}

struct AppIconView: View {
    let application: Application
    let size: CGFloat
    
    var body: some View {
        Group {
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                RoundedRectangle(cornerRadius: size * 0.2)
                    .fill(.blue.opacity(0.15))
                    .overlay(
                        Image(systemName: "app.fill")
                            .font(.system(size: size * 0.5))
                            .foregroundColor(.blue)
                    )
            }
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.2))
        .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: 0.5)
    }
}

struct TagsAndMetadataView: View {
    let shortcut: Shortcut
    let showAppName: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            // App name tag
            if showAppName, let app = shortcut.application {
                AppTag(application: app)
            }
            
            // Category tag
            if shortcut.category != "General" {
                CategoryTag(category: shortcut.category)
            }
            
            // Tags (limited to 2 visible)
            ForEach(shortcut.tags.prefix(2), id: \.self) { tag in
                TagLabel(tag: tag)
            }
            
            // More tags indicator
            if shortcut.tags.count > 2 {
                Text("+\(shortcut.tags.count - 2)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 1)
                    .background(.ultraThinMaterial, in: Capsule())
            }
        }
    }
}

struct AppTag: View {
    let application: Application
    
    var body: some View {
        HStack(spacing: 4) {
            if let icon = application.icon {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 12, height: 12)
                    .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            Text(application.name)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.blue.opacity(0.15))
        .foregroundColor(.blue)
        .clipShape(Capsule())
    }
}

struct CategoryTag: View {
    let category: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "folder.fill")
                .font(.caption2)
            Text(category)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.purple.opacity(0.15))
        .foregroundColor(.purple)
        .clipShape(Capsule())
    }
}

struct TagLabel: View {
    let tag: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "tag.fill")
                .font(.caption2)
            Text(tag)
                .font(.caption)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 3)
        .background(.orange.opacity(0.15))
        .foregroundColor(.orange)
        .clipShape(Capsule())
    }
}

struct ActionButton: View {
    let title: String
    let systemImage: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: systemImage)
                    .font(.caption)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .foregroundColor(color)
            .overlay(
                Capsule()
                    .stroke(color.opacity(0.3), lineWidth: 1)
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

struct ContextMenuContent: View {
    let shortcut: Shortcut
    @Bindable var appModel: AppModel
    
    var body: some View {
        Button {
            appModel.showNewShortcutSheet = true
        } label: {
            Label("Add New Shortcut", systemImage: "plus")
        }
        
        Divider()
        
        Button {
            // Edit shortcut action
        } label: {
            Label("Edit Shortcut", systemImage: "pencil")
        }
        
        Button {
            appModel.duplicateShortcut(shortcut)
        } label: {
            Label("Duplicate Shortcut", systemImage: "doc.on.doc")
        }
        
        Button {
            appModel.toggleFavorite(shortcut)
        } label: {
            Label(
                shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: shortcut.isFavorite ? "star.slash" : "star"
            )
        }
        
        Menu {
            ForEach(appModel.applications, id: \.self) { app in
                if app != shortcut.application {
                    Button {
                        appModel.moveShortcut(shortcut, to: app)
                    } label: {
                        HStack {
                            AppIconView(application: app, size: 16)
                            Text(app.name)
                        }
                    }
                }
            }
        } label: {
            Label("Move to App", systemImage: "arrow.right.circle")
        }
        
        Divider()
        
        Button(role: .destructive) {
            appModel.deleteShortcut(shortcut)
        } label: {
            Label("Delete Shortcut", systemImage: "trash")
        }
    }
}

// MARK: - Enhanced Empty States

struct BeautifulEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    
    var body: some View {
        VStack(spacing: 24) {
            // Animated icon
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 48, weight: .light))
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 12) {
                Text(title)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .frame(maxWidth: 400)
            }
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Image(systemName: "plus")
                            .font(.callout)
                        Text(actionTitle)
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(.blue, in: Capsule())
                    .foregroundColor(.white)
                    .shadow(color: .blue.opacity(0.3), radius: 4, y: 2)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
}

// MARK: - Enhanced Headers

struct BeautifulSectionHeader: View {
    let title: String
    let subtitle: String?
    let count: Int?
    var action: (() -> Void)? = nil
    var actionTitle: String? = nil
    var actionIcon: String? = nil
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(title)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if let count = count {
                        Text("(\(count))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(.ultraThinMaterial, in: Capsule())
                    }
                }
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    HStack(spacing: 6) {
                        if let actionIcon = actionIcon {
                            Image(systemName: actionIcon)
                                .font(.callout)
                        }
                        Text(actionTitle)
                            .font(.callout)
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(.regularMaterial, in: Capsule())
                    .foregroundColor(.blue)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(.regularMaterial)
    }
}

// MARK: - View Extensions

extension View {
    // Simplified press events without rapid-fire issues
    func pressEvents(onPress: @escaping () -> Void, onRelease: @escaping () -> Void) -> some View {
        self
            .onTapGesture {
                onPress()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    onRelease()
                }
            }
    }
}

#Preview {
    VStack(spacing: 20) {
        BeautifulSectionHeader(
            title: "My Shortcuts",
            subtitle: "Your personal collection",
            count: 42,
            action: {},
            actionTitle: "Add Shortcut",
            actionIcon: "plus"
        )
        
        BeautifulEmptyState(
            icon: "keyboard",
            title: "No shortcuts yet",
            subtitle: "Add your first shortcut to get started organizing your workflow",
            action: {},
            actionTitle: "Add Shortcut"
        )
    }
    .frame(height: 400)
}