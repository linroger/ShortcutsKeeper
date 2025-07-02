//
//  GlobalHotkeyService.swift
//  ShortcutsKeeper
//
//  Created by Roger Lin on 6/27/25.
//

import AppKit
import Carbon
import Combine

class GlobalHotkeyService: ObservableObject {
    private var hotKeyRef: EventHotKeyRef?
    private var hotKeyID: EventHotKeyID
    private var eventHandler: EventHandlerRef?
    @Published var isEnabled = false
    
    var onHotKeyPressed: (() -> Void)?
    
    init() {
        // Create a simple signature using FourCharCode
        let signature = OSType(0x534B484B) // 'SKHK' in ASCII
        hotKeyID = EventHotKeyID(signature: signature, id: 1)
    }
    
    func registerHotKey(keyCode: Int, modifiers: UInt32) -> Bool {
        unregisterHotKey()
        
        let modifierFlags = carbonModifiersFromCocoa(modifiers)
        
        let status = RegisterEventHotKey(
            UInt32(keyCode),
            modifierFlags,
            hotKeyID,
            GetApplicationEventTarget(),
            0,
            &hotKeyRef
        )
        
        if status == noErr {
            isEnabled = true
            installEventHandler()
            return true
        }
        
        return false
    }
    
    func unregisterHotKey() {
        if let hotKeyRef = hotKeyRef {
            UnregisterEventHotKey(hotKeyRef)
            self.hotKeyRef = nil
        }
        
        if let eventHandler = eventHandler {
            RemoveEventHandler(eventHandler)
            self.eventHandler = nil
        }
        
        isEnabled = false
    }
    
    private func installEventHandler() {
        let eventTypes = [EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: OSType(kEventHotKeyPressed))]
        
        InstallEventHandler(
            GetApplicationEventTarget(),
            { (nextHandler, theEvent, userData) -> OSStatus in
                guard let userData = userData else { return noErr }
                let service = Unmanaged<GlobalHotkeyService>.fromOpaque(userData).takeUnretainedValue()
                service.handleHotKeyEvent(theEvent)
                return noErr
            },
            1,
            eventTypes,
            Unmanaged.passUnretained(self).toOpaque(),
            &eventHandler
        )
    }
    
    private func handleHotKeyEvent(_ event: EventRef?) {
        guard let event = event else { return }
        
        var hotKeyID = EventHotKeyID()
        let status = GetEventParameter(
            event,
            EventParamName(kEventParamDirectObject),
            EventParamType(typeEventHotKeyID),
            nil,
            MemoryLayout<EventHotKeyID>.size,
            nil,
            &hotKeyID
        )
        
        if status == noErr && hotKeyID.id == self.hotKeyID.id {
            DispatchQueue.main.async {
                self.onHotKeyPressed?()
            }
        }
    }
    
    private func carbonModifiersFromCocoa(_ modifiers: UInt32) -> UInt32 {
        var carbonModifiers: UInt32 = 0
        
        if modifiers & UInt32(NSEvent.ModifierFlags.command.rawValue) != 0 {
            carbonModifiers |= UInt32(cmdKey)
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.option.rawValue) != 0 {
            carbonModifiers |= UInt32(optionKey)
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.control.rawValue) != 0 {
            carbonModifiers |= UInt32(controlKey)
        }
        if modifiers & UInt32(NSEvent.ModifierFlags.shift.rawValue) != 0 {
            carbonModifiers |= UInt32(shiftKey)
        }
        
        return carbonModifiers
    }
    
    deinit {
        unregisterHotKey()
    }
}

extension GlobalHotkeyService {
    static func parseKeyCombo(_ combo: String) -> (keyCode: Int, modifiers: UInt32)? {
        // Parse combinations like "⌘⌥K", "Cmd+Alt+K", etc.
        let parts = combo.replacingOccurrences(of: "+", with: " ")
                        .replacingOccurrences(of: "⌘", with: "Cmd ")
                        .replacingOccurrences(of: "⌃", with: "Ctrl ")
                        .replacingOccurrences(of: "⌥", with: "Alt ")
                        .replacingOccurrences(of: "⇧", with: "Shift ")
                        .components(separatedBy: .whitespacesAndNewlines)
                        .filter { !$0.isEmpty }
        
        var modifiers: UInt32 = 0
        var keyChar: String = ""
        
        for part in parts {
            switch part.lowercased() {
            case "cmd", "command":
                modifiers |= UInt32(NSEvent.ModifierFlags.command.rawValue)
            case "ctrl", "control":
                modifiers |= UInt32(NSEvent.ModifierFlags.control.rawValue)
            case "alt", "option":
                modifiers |= UInt32(NSEvent.ModifierFlags.option.rawValue)
            case "shift":
                modifiers |= UInt32(NSEvent.ModifierFlags.shift.rawValue)
            default:
                keyChar = part.uppercased()
            }
        }
        
        guard let keyCode = keyCodeForCharacter(keyChar) else { return nil }
        return (keyCode: keyCode, modifiers: modifiers)
    }
    
    private static func keyCodeForCharacter(_ char: String) -> Int? {
        switch char.uppercased() {
        case "A": return 0
        case "B": return 11
        case "C": return 8
        case "D": return 2
        case "E": return 14
        case "F": return 3
        case "G": return 5
        case "H": return 4
        case "I": return 34
        case "J": return 38
        case "K": return 40
        case "L": return 37
        case "M": return 46
        case "N": return 45
        case "O": return 31
        case "P": return 35
        case "Q": return 12
        case "R": return 15
        case "S": return 1
        case "T": return 17
        case "U": return 32
        case "V": return 9
        case "W": return 13
        case "X": return 7
        case "Y": return 16
        case "Z": return 6
        case "1": return 18
        case "2": return 19
        case "3": return 20
        case "4": return 21
        case "5": return 23
        case "6": return 22
        case "7": return 26
        case "8": return 28
        case "9": return 25
        case "0": return 29
        case "SPACE": return 49
        case "RETURN", "ENTER": return 36
        case "TAB": return 48
        case "ESCAPE": return 53
        case "DELETE": return 51
        case "F1": return 122
        case "F2": return 120
        case "F3": return 99
        case "F4": return 118
        case "F5": return 96
        case "F6": return 97
        case "F7": return 98
        case "F8": return 100
        case "F9": return 101
        case "F10": return 109
        case "F11": return 103
        case "F12": return 111
        default: return nil
        }
    }
}