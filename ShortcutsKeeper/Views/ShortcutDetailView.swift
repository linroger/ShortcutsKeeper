//
//  ShortcutDetailView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct ShortcutDetailView: View {
    let shortcut: Shortcut
    let viewModel: ShortcutsViewModel
    @State private var isEditing = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                
                shortcutInfoSection
                
                if !shortcut.tags.isEmpty {
                    tagsSection
                }
                
                conflictsSection
                
                metadataSection
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .toolbar {
            ToolbarItemGroup {
                Button(action: { viewModel.toggleFavorite(shortcut) }) {
                    Label(shortcut.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                          systemImage: shortcut.isFavorite ? "star.fill" : "star")
                }
                
                Button(action: { isEditing = true }) {
                    Label("Edit", systemImage: "pencil")
                }
            }
        }
        .sheet(isPresented: $isEditing) {
            EditShortcutView(shortcut: shortcut, viewModel: viewModel)
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(shortcut.title)
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                if shortcut.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
            }
            
            HStack(spacing: 16) {
                ShortcutKeyView(keyCombination: shortcut.keyCombination)
                    .scaleEffect(1.2)
                
                if let app = shortcut.application {
                    HStack(spacing: 6) {
                        if let icon = app.icon {
                            Image(nsImage: icon)
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        Text(app.name)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private var shortcutInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Description", systemImage: "text.alignleft")
                .font(.headline)
            
            Text(shortcut.shortcutDescription.isEmpty ? "No description provided" : shortcut.shortcutDescription)
                .foregroundColor(shortcut.shortcutDescription.isEmpty ? .secondary : .primary)
                .textSelection(.enabled)
            
            Divider()
            
            HStack {
                Label("Category", systemImage: "folder")
                    .font(.headline)
                Spacer()
                Text(shortcut.category)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Tags", systemImage: "tag")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(shortcut.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.1))
                            .cornerRadius(4)
                    }
                }
            }
        }
    }
    
    private var conflictsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            let conflicts = viewModel.findShortcutsByKeyCombination(shortcut.keyCombination)
                .filter { $0.id != shortcut.id }
            
            if !conflicts.isEmpty {
                Label("Conflicts", systemImage: "exclamationmark.triangle")
                    .font(.headline)
                    .foregroundColor(.orange)
                
                ForEach(conflicts) { conflict in
                    HStack {
                        Image(systemName: "keyboard")
                            .foregroundColor(.orange)
                        
                        VStack(alignment: .leading) {
                            Text(conflict.title)
                                .font(.subheadline)
                            if let app = conflict.application {
                                Text(app.name)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }
    
    private var metadataSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Divider()
            
            HStack {
                Label("Created", systemImage: "calendar")
                    .foregroundColor(.secondary)
                Spacer()
                Text(shortcut.dateCreated.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
            
            HStack {
                Label("Modified", systemImage: "clock")
                    .foregroundColor(.secondary)
                Spacer()
                Text(shortcut.dateModified.formatted(date: .abbreviated, time: .shortened))
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
}