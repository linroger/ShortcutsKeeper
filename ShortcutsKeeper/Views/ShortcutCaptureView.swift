//
//  ShortcutCaptureView.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import SwiftUI

struct ShortcutCaptureView: View {
    let viewModel: ShortcutsViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var capturedShortcut = ""
    @State private var matchingShortcuts: [Shortcut] = []
    @State private var isCapturing = false
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
            
            if isCapturing {
                capturingView
            } else if !capturedShortcut.isEmpty {
                resultsView
            } else {
                instructionsView
            }
        }
        .frame(width: 500, height: 400)
        .onAppear {
            startCapture()
        }
        .onDisappear {
            viewModel.stopCapturingShortcut()
        }
    }
    
    private var headerView: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Shortcut Capture")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                
                Text("Press any keyboard shortcut to find where it's used")
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("Done") {
                dismiss()
            }
            .keyboardShortcut(.escape)
        }
        .padding()
    }
    
    private var capturingView: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard")
                .font(.system(size: 60))
                .foregroundColor(.accentColor)
                .symbolEffect(.pulse)
            
            Text("Listening for keyboard shortcut...")
                .font(.title2)
            
            Text("Press any key combination")
                .foregroundColor(.secondary)
            
            Button("Cancel") {
                viewModel.stopCapturingShortcut()
                isCapturing = false
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var instructionsView: some View {
        VStack(spacing: 20) {
            Image(systemName: "keyboard")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("Ready to capture")
                .font(.title2)
            
            Button("Start Capturing") {
                startCapture()
            }
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Captured shortcut:")
                    .font(.headline)
                
                ShortcutKeyView(keyCombination: capturedShortcut)
                    .scaleEffect(1.2)
                
                Spacer()
                
                Button("Capture Another") {
                    capturedShortcut = ""
                    matchingShortcuts = []
                    startCapture()
                }
            }
            .padding()
            
            Divider()
            
            if matchingShortcuts.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    
                    Text("No shortcuts found for \(capturedShortcut)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Button("Add This Shortcut") {
                        viewModel.capturedShortcut = capturedShortcut
                        viewModel.showNewShortcutSheet = true
                        dismiss()
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Found \(matchingShortcuts.count) shortcut\(matchingShortcuts.count == 1 ? "" : "s"):")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(matchingShortcuts) { shortcut in
                            CaptureResultRow(shortcut: shortcut)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
    }
    
    private func startCapture() {
        isCapturing = true
        capturedShortcut = ""
        matchingShortcuts = []
        
        viewModel.startCapturingShortcut()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            checkForCapturedShortcut()
        }
    }
    
    private func checkForCapturedShortcut() {
        if !viewModel.capturedShortcut.isEmpty {
            capturedShortcut = viewModel.capturedShortcut
            matchingShortcuts = viewModel.findShortcutsByKeyCombination(capturedShortcut)
            isCapturing = false
        } else if isCapturing {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                checkForCapturedShortcut()
            }
        }
    }
}

struct CaptureResultRow: View {
    let shortcut: Shortcut
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(shortcut.title)
                    .font(.headline)
                
                if !shortcut.shortcutDescription.isEmpty {
                    Text(shortcut.shortcutDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
            }
            
            Spacer()
            
            if let app = shortcut.application {
                HStack(spacing: 6) {
                    if let icon = app.icon {
                        Image(nsImage: icon)
                            .resizable()
                            .frame(width: 24, height: 24)
                    }
                    Text(app.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}