//
//  AboutFAQView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/30/25.
//

import SwiftUI

struct AboutFAQView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header with app icon and info
                    HStack(spacing: 20) {
                        // App icon
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.accentColor.gradient)
                            .frame(width: 80, height: 80)
                            .overlay(
                                Image(systemName: "keyboard")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                            )
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Shortcut Keeper")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Version: 2.2.8+48")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Text("Developed by Minas Giannekas.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            HStack {
                                Text("Personal website and projects:")
                                Link("whidev.com", destination: URL(string: "https://whidev.com")!)
                                    .foregroundColor(.accentColor)
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
                    .cornerRadius(12)
                    
                    // FAQ Sections
                    VStack(alignment: .leading, spacing: 20) {
                        FAQSection(
                            title: "What is this?",
                            content: "This is a small utility app that lets you save shortcuts (hotkeys) you use daily in your apps or want to learn and use more frequently."
                        )
                        
                        FAQSection(title: "Why should I use this?") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("It can be difficult to remember all shortcuts you use in every app, especially if you depend on your keyboard a lot in your daily tasks.")
                                Text("Shortcut Keeper keeps your favourite shortcuts or the ones you want to learn in a lightweight interface.")
                                    .fontWeight(.medium)
                                Text("Keep it running in the background and refer to it once in a while.")
                                Text("Use the global shortcut (default is Command-Option-K) to bring it to the front at any time.")
                            }
                        }
                        
                        FAQSection(title: "How to save a shortcut?") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Press the")
                                    Image(systemName: "plus.square")
                                        .foregroundColor(.accentColor)
                                    Text("button at the top right. In the dialog that appears:")
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack {
                                        Text("- Use")
                                        Text("Record...")
                                            .foregroundColor(.accentColor)
                                            .fontWeight(.medium)
                                        Text("or")
                                        Text("Select...")
                                            .foregroundColor(.accentColor)
                                            .fontWeight(.medium)
                                        Text("to set your shortcut's keyboard combination.")
                                    }
                                    Text("- Fill in the description to set what that shortcut does.")
                                    Text("- Select the App for the shortcut and optionally add some tags.")
                                    HStack {
                                        Text("- Select")
                                        Text("Save Shortcut")
                                            .foregroundColor(.accentColor)
                                            .fontWeight(.medium)
                                        Text(".")
                                    }
                                }
                                .padding(.leading)
                                
                                Text("Your shortcut will be added to your list of shortcuts.")
                                Text("You can filter the list of shortcuts by app, tag, or perform a search.")
                            }
                        }
                        
                        FAQSection(
                            title: "How to change the icon for an app that I added?",
                            content: "Send me an e-mail with the name of the app you added and I will include its icon with the next update!"
                        )
                        
                        FAQSection(title: "When I try to record a shortcut, it doesn't register!") {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("This can happen with shortcuts that are already in use from your operating system. For example, trying to record Command-Space will bring up Spotlight Search instead.")
                                HStack {
                                    Text("To work around this, you should use the")
                                    Text("Select...")
                                        .foregroundColor(.accentColor)
                                        .fontWeight(.medium)
                                    Text("option instead of")
                                    Text("Record...")
                                        .foregroundColor(.accentColor)
                                        .fontWeight(.medium)
                                    Text("to set your shortcut's combination.")
                                }
                            }
                        }
                        
                        FAQSection(title: "How to edit or delete a shortcut?") {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Text("Click on a shortcut to select it and then use the")
                                    Image(systemName: "pencil")
                                        .foregroundColor(.accentColor)
                                    Text("or")
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                    Text("button to edit or delete it.")
                                }
                                Text("Deleted shortcuts stay in the Bin for 30 days, in case you change your mind and need to restore them.")
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("About & FAQ")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 700, height: 600)
    }
}

struct FAQSection: View {
    let title: String
    let content: any View
    
    init(title: String, content: String) {
        self.title = title
        self.content = Text(content)
    }
    
    init<Content: View>(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            AnyView(content)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    AboutFAQView()
}