//
//  NewShortcutView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct NewShortcutView: View {
    let viewModel: ShortcutsViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var keyCombination = ""
    @State private var description = ""
    @State private var category = "General"
    @State private var selectedApplication: Application?
    @State private var tags = ""
    @State private var isCapturing = false
    @State private var showConflicts = false
    
    // Dropdown selection states
    @State private var useDropdowns = false
    @State private var hasCommand = false
    @State private var hasShift = false
    @State private var hasOption = false
    @State private var hasControl = false
    @State private var selectedKey = "A"
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            Form {
                Section("Basic Information") {
                    TextField("Title", text: $title)
                        .textFieldStyle(.roundedBorder)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        // Toggle between capture and dropdown modes
                        Picker("Input Method", selection: $useDropdowns) {
                            Text("Capture Shortcut").tag(false)
                            Text("Select Keys").tag(true)
                        }
                        .pickerStyle(.segmented)
                        
                        if useDropdowns {
                            ShortcutDropdownPicker(
                                hasCommand: $hasCommand,
                                hasShift: $hasShift,
                                hasOption: $hasOption,
                                hasControl: $hasControl,
                                selectedKey: $selectedKey,
                                keyCombination: $keyCombination
                            )
                        } else {
                            HStack {
                                TextField("Keyboard Shortcut", text: $keyCombination)
                                    .textFieldStyle(.roundedBorder)
                                    .disabled(isCapturing)
                                
                                Button(action: isCapturing ? cancelCapture : captureShortcut) {
                                    Label(isCapturing ? "Cancel" : "Capture", 
                                          systemImage: isCapturing ? "xmark.circle" : "keyboard")
                                }
                                .foregroundColor(isCapturing ? .red : .blue)
                            }
                        }
                    }
                    
                    if !viewModel.conflictingShortcuts.isEmpty && showConflicts {
                        EnhancedConflictWarningView(conflicts: viewModel.conflictingShortcuts)
                            .transition(.opacity.combined(with: .scale(scale: 0.95)))
                            .animation(.easeInOut(duration: 0.3), value: showConflicts)
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
        .onAppear {
            if !viewModel.capturedShortcut.isEmpty {
                keyCombination = viewModel.capturedShortcut
                viewModel.capturedShortcut = ""
                checkForConflicts()
            }
        }
        .onDisappear {
            // Clean up capture service if view is dismissed
            cancelCapture()
        }
        // ERROR HANDLING: Validation error alert
        .alert("Input Error", isPresented: $showingErrorAlert) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private var headerView: some View {
        HStack {
            Text("New Shortcut")
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
            
            Button("Add Shortcut") {
                saveShortcut()
            }
            .keyboardShortcut(.return)
            .disabled(title.isEmpty || keyCombination.isEmpty)
        }
        .padding()
    }
    
    private func captureShortcut() {
        guard !isCapturing else { return }
        
        isCapturing = true
        
        // ENHANCED SHORTCUT CAPTURE: Use proper capture service API
        captureService = ShortcutCaptureService()
        captureService?.startCapturing { capturedKeys in
            DispatchQueue.main.async {
                self.keyCombination = capturedKeys
                self.checkForConflicts()
                self.isCapturing = false
                self.captureService = nil
                print("✅ Captured shortcut: \(capturedKeys)")
            }
        }
    }
    
    private func cancelCapture() {
        captureService?.stopCapturing()
        captureService = nil
        isCapturing = false
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
    
    private func saveShortcut() {
        // INPUT VALIDATION: Enhanced validation with user feedback
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            // Show error alert for empty title
            showValidationError("Please enter a title for the shortcut")
            return
        }
        
        guard !keyCombination.trimmingCharacters(in: .whitespaces).isEmpty else {
            showValidationError("Please enter or capture a keyboard shortcut")
            return
        }
        
        // Validate shortcut format
        if !isValidShortcutFormat(keyCombination) {
            showValidationError("Invalid shortcut format. Use combinations like ⌘K or Command+K")
            return
        }
        
        let tagArray = tags.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        viewModel.addShortcut(
            title: title.trimmingCharacters(in: .whitespaces),
            keyCombination: keyCombination.trimmingCharacters(in: .whitespaces),
            description: description.trimmingCharacters(in: .whitespaces),
            category: category.isEmpty ? "General" : category,
            application: selectedApplication,
            tags: tagArray
        )
        
        print("✅ Successfully added shortcut: \(title)")
        dismiss()
    }
    
    private func isValidShortcutFormat(_ shortcut: String) -> Bool {
        // Basic validation for shortcut format
        let trimmed = shortcut.trimmingCharacters(in: .whitespaces)
        return !trimmed.isEmpty && 
               (trimmed.contains("⌘") || trimmed.contains("⌃") || trimmed.contains("⌥") || trimmed.contains("⇧") ||
                trimmed.lowercased().contains("command") || trimmed.lowercased().contains("ctrl") || 
                trimmed.lowercased().contains("option") || trimmed.lowercased().contains("shift") ||
                trimmed.count == 1) // Single key shortcuts are valid
    }
    
    @State private var showingErrorAlert = false
    @State private var errorMessage = ""
    @State private var captureService: ShortcutCaptureService?
    
    private func showValidationError(_ message: String) {
        errorMessage = message
        showingErrorAlert = true
        print("❌ Validation error: \(message)")
    }
}

struct ConflictWarningView: View {
    let conflicts: [Shortcut]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("This shortcut is already in use:", systemImage: "exclamationmark.triangle")
                .foregroundColor(.orange)
                .font(.caption)
            
            ForEach(conflicts) { conflict in
                HStack {
                    Text("• \(conflict.title)")
                        .font(.caption)
                    if let app = conflict.application {
                        Text("(\(app.name))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ShortcutDropdownPicker: View {
    @Binding var hasCommand: Bool
    @Binding var hasShift: Bool
    @Binding var hasOption: Bool
    @Binding var hasControl: Bool
    @Binding var selectedKey: String
    @Binding var keyCombination: String
    
    private let availableKeys = [
        "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
        "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z",
        "0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
        "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",
        "Space", "↩", "⇥", "⌫", "⎋", "←", "→", "↑", "↓", "↖", "↘", "⇞", "⇟"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Select Modifier Keys:")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                Toggle("⌘ Command", isOn: $hasCommand)
                    .toggleStyle(.checkbox)
                
                Toggle("⇧ Shift", isOn: $hasShift)
                    .toggleStyle(.checkbox)
                
                Toggle("⌥ Option", isOn: $hasOption)
                    .toggleStyle(.checkbox)
                
                Toggle("⌃ Control", isOn: $hasControl)
                    .toggleStyle(.checkbox)
            }
            
            Text("Select Key:")
                .font(.headline)
            
            Picker("Key", selection: $selectedKey) {
                ForEach(availableKeys, id: \.self) { key in
                    Text(key).tag(key)
                }
            }
            .pickerStyle(.menu)
            
            if !keyCombination.isEmpty {
                HStack {
                    Text("Preview:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(keyCombination)
                        .font(.system(.body, design: .monospaced))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(6)
                }
            }
        }
        .onChange(of: hasCommand) { _, _ in updateKeyCombination() }
        .onChange(of: hasShift) { _, _ in updateKeyCombination() }
        .onChange(of: hasOption) { _, _ in updateKeyCombination() }
        .onChange(of: hasControl) { _, _ in updateKeyCombination() }
        .onChange(of: selectedKey) { _, _ in updateKeyCombination() }
        .onAppear { updateKeyCombination() }
    }
    
    private func updateKeyCombination() {
        var modifiers: [String] = []
        
        if hasCommand { modifiers.append("⌘") }
        if hasControl { modifiers.append("⌃") }
        if hasOption { modifiers.append("⌥") }
        if hasShift { modifiers.append("⇧") }
        
        keyCombination = modifiers.joined() + selectedKey
    }
}

// MARK: - Enhanced Conflict Warning View

struct EnhancedConflictWarningView: View {
    let conflicts: [Shortcut]
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Enhanced header with animation
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                        .font(.system(size: 16, weight: .semibold))
                    
                    Text("Shortcut Conflict Warning")
                        .font(.headline)
                        .foregroundColor(.orange)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(.orange)
                        .font(.caption)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.easeInOut(duration: 0.2), value: isExpanded)
                }
            }
            .buttonStyle(.plain)
            
            Text("This shortcut is already used by \(conflicts.count) other \(conflicts.count == 1 ? "item" : "items")")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if isExpanded {
                LazyVStack(alignment: .leading, spacing: 8) {
                    ForEach(conflicts) { conflict in
                        HStack {
                            // App icon or placeholder
                            if let app = conflict.application, let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                                    .clipShape(RoundedRectangle(cornerRadius: 3))
                            } else {
                                Image(systemName: "app.fill")
                                    .foregroundColor(.secondary)
                                    .frame(width: 16, height: 16)
                            }
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(conflict.title)
                                    .font(.callout)
                                    .fontWeight(.medium)
                                
                                if let app = conflict.application {
                                    Text(app.name)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            // Shortcut display
                            Text(conflict.keyCombination)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(.ultraThinMaterial)
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 4)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                )
        )
        // ACCESSIBILITY: Enhanced VoiceOver support
        .accessibilityLabel("Shortcut conflict warning")
        .accessibilityHint("This shortcut is already in use by other items. Tap to see details.")
        .accessibilityAddTraits([.isButton])
    }
}