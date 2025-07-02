//
//  EnhancedShortcutRecordingView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/30/25.
//

import SwiftUI

struct EnhancedShortcutRecordingView: View {
    @Bindable var appModel: AppModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var recordingMode: RecordingMode = .none
    @State private var capturedShortcut = ""
    @State private var shortcutDescription = ""
    @State private var selectedApplication: Application?
    @State private var tags = ""
    @State private var isRecording = false
    @State private var showingConflictAlert = false
    @State private var conflictingShortcuts: [Shortcut] = []
    
    // For manual input mode
    @State private var hasControl = false
    @State private var hasOption = false
    @State private var hasShift = false
    @State private var hasCommand = false
    @State private var selectedKey = ""
    @State private var isChordShortcut = false
    
    enum RecordingMode {
        case none, recording, selecting, entering
    }
    
    var body: some View {
        VStack(spacing: 24) {
            // Header with keyboard icon
            VStack(spacing: 16) {
                Image(systemName: "keyboard")
                    .font(.system(size: 60))
                    .foregroundColor(.accentColor)
                
                Text("Save a new shortcut.")
                    .font(.title)
                    .fontWeight(.semibold)
            }
            
            // Keyboard combination section
            VStack(spacing: 16) {
                HStack {
                    Text("Keyboard combination:")
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                // Recording method buttons
                HStack(spacing: 8) {
                    Button("Record...") {
                        startRecording()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Text("or")
                        .foregroundColor(.secondary)
                    
                    Button("Select...") {
                        recordingMode = .selecting
                    }
                    .buttonStyle(.bordered)
                    
                    Text("or")
                        .foregroundColor(.secondary)
                    
                    Button("Enter...") {
                        recordingMode = .entering
                    }
                    .buttonStyle(.bordered)
                }
                
                // Recording interface based on mode
                Group {
                    switch recordingMode {
                    case .none:
                        EmptyView()
                    case .recording:
                        RecordingInterface(
                            isRecording: $isRecording,
                            capturedShortcut: $capturedShortcut,
                            onStopRecording: stopRecording
                        )
                    case .selecting:
                        ShortcutSelectionInterface(
                            hasControl: $hasControl,
                            hasOption: $hasOption,
                            hasShift: $hasShift,
                            hasCommand: $hasCommand,
                            selectedKey: $selectedKey,
                            capturedShortcut: $capturedShortcut,
                            isChordShortcut: $isChordShortcut
                        )
                    case .entering:
                        ManualEntryInterface(capturedShortcut: $capturedShortcut)
                    }
                }
                
                // Shortcut display
                if !capturedShortcut.isEmpty {
                    HStack {
                        Text(capturedShortcut)
                            .font(.system(.title2, design: .monospaced))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color(NSColor.controlBackgroundColor))
                            .cornerRadius(8)
                        
                        Button(action: { capturedShortcut = ""; recordingMode = .none }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                // Chord shortcut option
                if recordingMode == .selecting || recordingMode == .entering {
                    Toggle("Chord shortcut (e.g. ⌘K ⌘S)", isOn: $isChordShortcut)
                        .font(.caption)
                }
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor).opacity(0.3))
            .cornerRadius(12)
            
            // Description field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Description:")
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                TextField("e.g. Creates a new tab", text: $shortcutDescription)
                    .textFieldStyle(.roundedBorder)
            }
            
            // App selection
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("App:")
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                Picker("Application", selection: $selectedApplication) {
                    Text("Select App").tag(nil as Application?)
                    ForEach(appModel.applications.sorted(by: { $0.name < $1.name })) { app in
                        HStack {
                            if let icon = app.icon {
                                Image(nsImage: icon)
                                    .resizable()
                                    .frame(width: 16, height: 16)
                            }
                            Text(app.name)
                        }
                        .tag(app as Application?)
                    }
                }
                .pickerStyle(.menu)
            }
            
            // Tags field
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Tags:")
                        .font(.body)
                        .fontWeight(.medium)
                    Spacer()
                }
                
                TextField("e.g. browser, work, files", text: $tags)
                    .textFieldStyle(.roundedBorder)
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 12) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("Save Shortcut") {
                    saveShortcut()
                }
                .buttonStyle(.borderedProminent)
                .disabled(capturedShortcut.isEmpty || shortcutDescription.isEmpty)
            }
        }
        .padding(24)
        .frame(width: 500, height: 600)
        .onAppear {
            // Pre-select the current app if we came from an app view
            selectedApplication = appModel.selectedApplication
        }
        .alert("Shortcut Conflict", isPresented: $showingConflictAlert) {
            Button("Save Anyway") {
                forceSaveShortcut()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This shortcut conflicts with \(conflictingShortcuts.count) existing shortcut(s). Do you want to save it anyway?")
        }
    }
    
    private func startRecording() {
        recordingMode = .recording
        isRecording = true
        capturedShortcut = ""
        
        // Simulate recording (in real implementation, this would use the actual capture service)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            // This would be replaced with actual shortcut capture logic
            // For demo, we'll just wait for user input
        }
    }
    
    private func stopRecording() {
        isRecording = false
        recordingMode = .none
    }
    
    private func saveShortcut() {
        // Check for conflicts
        let conflicts = appModel.shortcuts.filter { shortcut in
            shortcut.keyCombination == capturedShortcut &&
            shortcut.application == selectedApplication
        }
        
        if !conflicts.isEmpty {
            conflictingShortcuts = conflicts
            showingConflictAlert = true
            return
        }
        
        forceSaveShortcut()
    }
    
    private func forceSaveShortcut() {
        let tagArray = tags.components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        
        appModel.addShortcut(
            title: shortcutDescription,
            keyCombination: capturedShortcut,
            description: shortcutDescription,
            category: "User Added",
            application: selectedApplication,
            tags: tagArray
        )
        
        dismiss()
    }
}

// MARK: - Recording Interface Components

struct RecordingInterface: View {
    @Binding var isRecording: Bool
    @Binding var capturedShortcut: String
    let onStopRecording: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if isRecording {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Press any key combination...")
                        .foregroundColor(.secondary)
                }
                
                Button("Stop Recording") {
                    onStopRecording()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}

struct ShortcutSelectionInterface: View {
    @Binding var hasControl: Bool
    @Binding var hasOption: Bool
    @Binding var hasShift: Bool
    @Binding var hasCommand: Bool
    @Binding var selectedKey: String
    @Binding var capturedShortcut: String
    @Binding var isChordShortcut: Bool
    
    let keys = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/", "Space", "Tab", "Return", "Delete", "Escape"]
    
    var body: some View {
        VStack(spacing: 12) {
            // Modifier checkboxes
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Toggle("Control (^)", isOn: $hasControl)
                    Spacer()
                }
                HStack {
                    Toggle("Option (⌥)", isOn: $hasOption)
                    Spacer()
                }
                HStack {
                    Toggle("Shift (⇧)", isOn: $hasShift)
                    Spacer()
                }
                HStack {
                    Toggle("Command (⌘)", isOn: $hasCommand)
                    Spacer()
                }
            }
            
            // Key selection
            HStack {
                Text("+")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Picker("Key", selection: $selectedKey) {
                    Text("Select Key").tag("")
                    ForEach(keys, id: \.self) { key in
                        Text(key).tag(key)
                    }
                }
                .pickerStyle(.menu)
                
                Button(action: updateShortcut) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.green)
                }
                .buttonStyle(.plain)
                .disabled(selectedKey.isEmpty)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
        .onChange(of: hasControl) { _, _ in updateShortcut() }
        .onChange(of: hasOption) { _, _ in updateShortcut() }
        .onChange(of: hasShift) { _, _ in updateShortcut() }
        .onChange(of: hasCommand) { _, _ in updateShortcut() }
        .onChange(of: selectedKey) { _, _ in updateShortcut() }
    }
    
    private func updateShortcut() {
        guard !selectedKey.isEmpty else {
            capturedShortcut = ""
            return
        }
        
        var modifiers: [String] = []
        if hasControl { modifiers.append("⌃") }
        if hasOption { modifiers.append("⌥") }
        if hasShift { modifiers.append("⇧") }
        if hasCommand { modifiers.append("⌘") }
        
        let keyToUse = selectedKey == "Space" ? "Space" : selectedKey
        capturedShortcut = modifiers.joined() + keyToUse
    }
}

struct ManualEntryInterface: View {
    @Binding var capturedShortcut: String
    
    var body: some View {
        VStack(spacing: 8) {
            TextField("Enter shortcut (e.g. Command-R)", text: $capturedShortcut)
                .textFieldStyle(.roundedBorder)
            
            Text("You can type shortcuts like: Command-R, Shift-Command-5, etc.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .cornerRadius(8)
    }
}

#Preview {
    EnhancedShortcutRecordingView(appModel: AppModel.shared)
}