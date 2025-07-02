//
//  ShortcutCaptureService.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import Foundation
import AppKit
import Carbon

class ShortcutCaptureService: NSObject {
    typealias ShortcutHandler = (String) -> Void
    
    private var localEventMonitor: Any?
    private var globalEventMonitor: Any?
    private var captureHandler: ShortcutHandler?
    private var isCapturing = false
    private var captureTimer: Timer?
    
    func startCapturing(handler: @escaping ShortcutHandler) {
        guard !isCapturing else { return }
        
        isCapturing = true
        captureHandler = handler
        
        // Create a local event tap that completely blocks all keyboard events
        localEventMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { [weak self] event in
            guard let self = self, self.isCapturing else { return event }
            
            // Only process keyDown events for capture
            if event.type == .keyDown {
                let shortcut = self.parseKeyEvent(event)
                if !shortcut.isEmpty {
                    DispatchQueue.main.async {
                        self.captureHandler?(shortcut)
                        self.stopCapturing()
                    }
                    return nil // Block the event
                }
            }
            
            // Block ALL keyboard events during capture to prevent shortcuts from triggering
            return nil
        }
        
        // Monitor global events to catch system-wide shortcuts
        globalEventMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.keyDown, .keyUp, .flagsChanged]) { [weak self] event in
            guard let self = self, self.isCapturing else { return }
            
            if event.type == .keyDown {
                let shortcut = self.parseKeyEvent(event)
                if !shortcut.isEmpty {
                    DispatchQueue.main.async {
                        self.captureHandler?(shortcut)
                        self.stopCapturing()
                    }
                }
            }
        }
        
        // Set up a timeout to automatically stop capturing after 10 seconds
        captureTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: false) { [weak self] _ in
            DispatchQueue.main.async {
                self?.stopCapturing()
            }
        }
    }
    
    func stopCapturing() {
        isCapturing = false
        
        if let monitor = localEventMonitor {
            NSEvent.removeMonitor(monitor)
            localEventMonitor = nil
        }
        
        if let monitor = globalEventMonitor {
            NSEvent.removeMonitor(monitor)
            globalEventMonitor = nil
        }
        
        captureTimer?.invalidate()
        captureTimer = nil
        
        captureHandler = nil
    }
    
    private func parseKeyEvent(_ event: NSEvent) -> String {
        var modifiers: [String] = []
        
        if event.modifierFlags.contains(.command) {
            modifiers.append("⌘")
        }
        if event.modifierFlags.contains(.shift) {
            modifiers.append("⇧")
        }
        if event.modifierFlags.contains(.option) {
            modifiers.append("⌥")
        }
        if event.modifierFlags.contains(.control) {
            modifiers.append("⌃")
        }
        
        guard !modifiers.isEmpty else { return "" }
        
        if let characters = event.charactersIgnoringModifiers?.uppercased() {
            modifiers.append(characters)
            return modifiers.joined(separator: "")
        }
        
        if let specialKey = specialKeyString(for: event.keyCode) {
            modifiers.append(specialKey)
            return modifiers.joined(separator: "")
        }
        
        return ""
    }
    
    private func specialKeyString(for keyCode: UInt16) -> String? {
        switch Int(keyCode) {
        case kVK_F1: return "F1"
        case kVK_F2: return "F2"
        case kVK_F3: return "F3"
        case kVK_F4: return "F4"
        case kVK_F5: return "F5"
        case kVK_F6: return "F6"
        case kVK_F7: return "F7"
        case kVK_F8: return "F8"
        case kVK_F9: return "F9"
        case kVK_F10: return "F10"
        case kVK_F11: return "F11"
        case kVK_F12: return "F12"
        case kVK_Return: return "↩"
        case kVK_Tab: return "⇥"
        case kVK_Space: return "Space"
        case kVK_Delete: return "⌫"
        case kVK_Escape: return "⎋"
        case kVK_LeftArrow: return "←"
        case kVK_RightArrow: return "→"
        case kVK_UpArrow: return "↑"
        case kVK_DownArrow: return "↓"
        case kVK_Home: return "↖"
        case kVK_End: return "↘"
        case kVK_PageUp: return "⇞"
        case kVK_PageDown: return "⇟"
        default: return nil
        }
    }
    
    static func normalizeShortcut(_ shortcut: String) -> String {
        let components = shortcut.components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { !$0.isEmpty }
        
        var normalized = ""
        
        if shortcut.contains("⌘") { normalized += "⌘" }
        if shortcut.contains("⌃") { normalized += "⌃" }
        if shortcut.contains("⌥") { normalized += "⌥" }
        if shortcut.contains("⇧") { normalized += "⇧" }
        
        if let lastComponent = components.last {
            normalized += lastComponent.uppercased()
        }
        
        return normalized
    }
}