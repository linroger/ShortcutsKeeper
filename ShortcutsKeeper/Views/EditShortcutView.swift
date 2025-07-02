//
//  EditShortcutView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct EditShortcutView: View {
    let shortcut: Shortcut
    let viewModel: ShortcutsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var keyCombination: String
    @State private var description: String
    @State private var category: String
    @State private var selectedApplication: Application?
    @State private var tags: String
    @State private var isCapturing = false
    @State private var showConflicts = false
    
    init(shortcut: Shortcut, viewModel: ShortcutsViewModel) {
        self.shortcut = shortcut
        self.viewModel = viewModel
        
        _title = State(initialValue: shortcut.title)
        _keyCombination = State(initialValue: shortcut.keyCombination)
        _description = State(initialValue: shortcut.shortcutDescription)
        _category = State(initialValue: shortcut.category)
        _selectedApplication = State(initialValue: shortcut.application)
        _tags = State(initialValue: shortcut.tags.joined(separator: ", "))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    HStack {
                        TextField("Keyboard Shortcut", text: $keyCombination)
                            .textFieldStyle(.roundedBorder)
                            .disabled(isCapturing)
                        
                        Button(action: captureShortcut) {
                            Label(isCapturing ? "Capturing..." : "Capture", 
                                  systemImage: "keyboard")
                        }
                        .disabled(isCapturing)
                    }
                    
                    if !viewModel.conflictingShortcuts.isEmpty && showConflicts {
                        ConflictWarningView(conflicts: viewModel.conflictingShortcuts.filter { $0.id != shortcut.id })
                    }
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
                
                Section("Organization") {
                    Picker("Application", selection: $selectedApplication) {
                        Text("None").tag(nil as Application?)
                        ForEach(viewModel.applications.sorted(by: { $0.name < $1.name })) { app in
                            Text(app.name).tag(app as Application?)
                        }
                    }
                    
                    TextField("Category", text: $category)
                        .textFieldStyle(.roundedBorder)
                    
                    TextField("Tags (comma separated)", text: $tags)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .formStyle(.grouped)
            .scrollContentBackground(.hidden)
            
            Divider()
            
            footerView
        }
        .frame(width: 500, height: 500)
    }
    
    private var headerView: some View {
        HStack {
            Text("Edit Shortcut")
                .font(.largeTitle)
                .fontWeight(.semibold)
            
            Spacer()
        }
        .padding()
    }
    
    private var footerView: some View {
        HStack {
            Button("Cancel") {
                dismiss()
            }
            .keyboardShortcut(.escape)
            
            Spacer()
            
            Button("Save Changes") {
                saveChanges()
            }
            .keyboardShortcut(.return)
            .disabled(title.isEmpty || keyCombination.isEmpty)
        }
        .padding()
    }
    
    private func captureShortcut() {
        isCapturing = true
        viewModel.startCapturingShortcut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkForCapturedShortcut()
        }
    }
    
    private func checkForCapturedShortcut() {
        if !viewModel.capturedShortcut.isEmpty {
            keyCombination = viewModel.capturedShortcut
            viewModel.capturedShortcut = ""
            isCapturing = false
            checkForConflicts()
        } else if isCapturing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                checkForCapturedShortcut()
            }
        }
    }
    
    private func checkForConflicts() {
        viewModel.checkForConflicts(keyCombination)
        showConflicts = !viewModel.conflictingShortcuts.isEmpty
    }
    
    private func saveChanges() {
        shortcut.title = title
        shortcut.keyCombination = keyCombination
        shortcut.shortcutDescription = description
        shortcut.category = category
        shortcut.application = selectedApplication
        shortcut.tags = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        viewModel.updateShortcut(shortcut)
        dismiss()
    }
}