//
//  EnhancedKeyDisplayView.swift
//  ShortcutsKeeper
//
//  Created by Claude on 7/4/25.
//

import SwiftUI

// MARK: - Enhanced Key Display Components

struct EnhancedKeyDisplayView: View {
    let keyCombination: String
    var style: KeyDisplayStyle = .normal
    var interactive: Bool = false
    var ordered: Bool = false
    var useCustomSettings: Bool = true
    
    @AppStorage("keyDisplaySize") private var keyDisplaySize: Double = 1.0
    @AppStorage("keyVerticalPadding") private var keyVerticalPadding: Double = 6.0
    @AppStorage("keyHorizontalPadding") private var keyHorizontalPadding: Double = 10.0
    
    enum KeyDisplayStyle {
        case normal
        case compact
        case prominent
        case minimal
    }
    
    private var keyComponents: [EnhancedKeyComponent] {
        let components = parseKeyCombination(keyCombination)
        return ordered ? orderComponents(components) : components
    }
    
    var body: some View {
        HStack(spacing: style == .compact ? 4 : 6) {
            ForEach(Array(keyComponents.enumerated()), id: \.offset) { index, component in
                if index > 0 {
                    PlusSymbol(style: style)
                }
                
                EnhancedKeyCap(
                    component: component,
                    style: style,
                    interactive: interactive,
                    customSize: useCustomSettings ? keyDisplaySize : nil,
                    customVerticalPadding: useCustomSettings ? keyVerticalPadding : nil,
                    customHorizontalPadding: useCustomSettings ? keyHorizontalPadding : nil
                )
            }
        }
    }
    
    func parseKeyCombination(_ combo: String) -> [EnhancedKeyComponent] {
        var components: [EnhancedKeyComponent] = []
        var remaining = combo
        
        // Parse all possible modifiers and special keys
        // Support both Unicode symbols and text representations
        let allKeys = [
            // Modifiers
            ("fn", "Function", "fn", KeyType.fn),
            ("⌘", "Command", "Command", KeyType.command),
            ("⌃", "Control", "Control", KeyType.control),
            ("⌥", "Option", "Option", KeyType.option),
            ("⇧", "Shift", "Shift", KeyType.shift),
            
            // Special keys
            ("⎋", "Escape", "Escape", KeyType.escape),
            ("⇥", "Tab", "Tab", KeyType.tab),
            ("↩", "Return", "Return", KeyType.special),
            ("⌫", "Delete", "Delete", KeyType.special),
            ("⌦", "Del", "Del", KeyType.special),
            ("⌃", "Control", "Ctrl", KeyType.control),
            
            // Function keys F1-F17
            ("F1", "F1", "F1", KeyType.function),
            ("F2", "F2", "F2", KeyType.function),
            ("F3", "F3", "F3", KeyType.function),
            ("F4", "F4", "F4", KeyType.function),
            ("F5", "F5", "F5", KeyType.function),
            ("F6", "F6", "F6", KeyType.function),
            ("F7", "F7", "F7", KeyType.function),
            ("F8", "F8", "F8", KeyType.function),
            ("F9", "F9", "F9", KeyType.function),
            ("F10", "F10", "F10", KeyType.function),
            ("F11", "F11", "F11", KeyType.function),
            ("F12", "F12", "F12", KeyType.function),
            ("F13", "F13", "F13", KeyType.function),
            ("F14", "F14", "F14", KeyType.function),
            ("F15", "F15", "F15", KeyType.function),
            ("F16", "F16", "F16", KeyType.function),
            ("F17", "F17", "F17", KeyType.function),
            
            // Arrow keys
            ("←", "Left Arrow", "Left", KeyType.arrow),
            ("→", "Right Arrow", "Right", KeyType.arrow),
            ("↑", "Up Arrow", "Up", KeyType.arrow),
            ("↓", "Down Arrow", "Down", KeyType.arrow),
            
            // Special characters and punctuation
            ("`", "Backtick", "`", KeyType.special),
            ("~", "Tilde", "~", KeyType.special),
            ("\\", "Backslash", "\\", KeyType.special),
            (";", "Semicolon", ";", KeyType.special),
            (":", "Colon", ":", KeyType.special),
            ("{", "Left Brace", "{", KeyType.special),
            ("}", "Right Brace", "}", KeyType.special),
            ("|", "Pipe", "|", KeyType.special),
            ("[", "Left Bracket", "[", KeyType.special),
            ("]", "Right Bracket", "]", KeyType.special),
            (".", "Period", ".", KeyType.special),
            ("?", "Question Mark", "?", KeyType.special),
            ("<", "Less Than", "<", KeyType.special),
            (">", "Greater Than", ">", KeyType.special),
            
            // Gestures
            ("􀊜", "Click", "Click", KeyType.gesture),
            ("􀆔", "Tap", "Tap", KeyType.gesture),
            ("􀦍", "Drag", "Drag", KeyType.gesture),
            ("􀅭", "Rotate", "Rotate", KeyType.gesture),
            ("􀣸", "Pinch", "Pinch", KeyType.gesture),
            ("􀺪", "Two-Finger", "Two-Finger", KeyType.gesture)
        ]
        
        // First, handle text-based format (e.g., "Command-K", "Option-Command-K")
        if remaining.contains("-") {
            let parts = remaining.split(separator: "-").map { String($0) }
            for part in parts.dropLast() { // All but the last part are modifiers
                for (symbol, name, textForm, keyType) in allKeys {
                    if part == textForm || part == symbol {
                        components.append(EnhancedKeyComponent(
                            symbol: symbol,
                            name: name,
                            keyType: keyType
                        ))
                        break
                    }
                }
            }
            // The last part is the main key
            if let lastPart = parts.last {
                remaining = lastPart
            }
        } else {
            // Handle Unicode symbol format
            for (symbol, name, _, keyType) in allKeys {
                if remaining.contains(symbol) {
                    components.append(EnhancedKeyComponent(
                        symbol: symbol,
                        name: name,
                        keyType: keyType
                    ))
                    remaining = remaining.replacingOccurrences(of: symbol, with: "")
                }
            }
        }
        
        // Add the main key
        if !remaining.isEmpty {
            let mainKey = remaining.trimmingCharacters(in: .whitespacesAndNewlines)
            let keyType = determineKeyType(for: mainKey)
            components.append(EnhancedKeyComponent(
                symbol: mainKey,
                name: mainKey,
                keyType: keyType
            ))
        }
        
        return components
    }
    
    private func orderComponents(_ components: [EnhancedKeyComponent]) -> [EnhancedKeyComponent] {
        // Define the ordering priority as requested by the user
        let keyOrder: [KeyType] = [
            .fn,        // fn always first
            .command,   // then command
            .option,    // then option
            .control,   // then control
            .escape,    // then escape
            .function,  // F1-F17
            .tab,       // then tab
            .shift,     // then shift
            .space,     // then space
            .arrow,     // arrow keys
            .special,   // punctuation/+=-_`~\|, etc
            .number,    // numbers
            .letter,    // letters
            .navigation,
            .other
        ]
        
        return components.sorted { component1, component2 in
            let index1 = keyOrder.firstIndex(of: component1.keyType) ?? keyOrder.count
            let index2 = keyOrder.firstIndex(of: component2.keyType) ?? keyOrder.count
            
            if index1 != index2 {
                return index1 < index2
            }
            
            // For same type, sort by symbol
            return component1.symbol < component2.symbol
        }
    }
    
    private func determineKeyType(for key: String) -> KeyType {
        switch key {
        case "Space":
            return .space
        case "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12", "F13", "F14", "F15", "F16", "F17":
            return .function
        case "⎋", "Escape", "Esc":
            return .escape
        case "⇥", "Tab":
            return .tab
        case "↩", "Return", "Enter", "⌫", "Delete", "⌦", "Del", "`", "~", "\\", ";", ":", "{", "}", "|", "[", "]", ".", "?", "<", ">":
            return .special
        case "←", "→", "↑", "↓", "Left", "Right", "Up", "Down":
            return .arrow
        case "⇞", "⇟", "↖", "↘": // Page Up, Page Down, Home, End
            return .navigation
        case let k where k.rangeOfCharacter(from: .decimalDigits) != nil && k.rangeOfCharacter(from: .decimalDigits.inverted) == nil:
            return .number
        case let k where k.count == 1 && k.rangeOfCharacter(from: .letters) != nil:
            return .letter
        default:
            return .other
        }
    }
}

struct EnhancedKeyComponent {
    let symbol: String
    let name: String
    let keyType: KeyType
}

enum KeyType {
    case fn, command, control, option, shift
    case letter, number, function
    case space, special, arrow, navigation
    case escape, tab
    case gesture
    case other
    
    var isModifier: Bool {
        switch self {
        case .fn, .command, .control, .option, .shift:
            return true
        default:
            return false
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .fn:
            return Color(red: 0.5, green: 0.0, blue: 0.5) // Deep purple
        case .command:
            return Color(red: 0.2, green: 0.6, blue: 1.0) // Blue
        case .control:
            return Color(red: 1.0, green: 0.5, blue: 0.0) // Orange
        case .option:
            return Color(red: 0.3, green: 0.8, blue: 0.3) // Green
        case .shift:
            return Color(red: 0.8, green: 0.3, blue: 0.8) // Purple
        case .escape:
            return Color(red: 0.9, green: 0.2, blue: 0.2) // Red
        case .tab:
            return Color(red: 0.0, green: 0.6, blue: 0.8) // Sky blue
        case .space:
            return Color(red: 0.9, green: 0.9, blue: 0.95) // Light gray-blue
        case .function:
            return Color(red: 0.4, green: 0.3, blue: 0.9) // Indigo
        case .special:
            return Color(red: 0.9, green: 0.4, blue: 0.4) // Red
        case .arrow:
            return Color(red: 0.0, green: 0.7, blue: 0.7) // Teal
        case .navigation:
            return Color(red: 0.7, green: 0.5, blue: 0.0) // Brown
        case .number:
            return Color(red: 1.0, green: 0.7, blue: 0.3) // Orange-yellow
        case .letter:
            return Color(red: 0.7, green: 0.9, blue: 0.7) // Light green
        case .gesture:
            return Color(red: 0.9, green: 0.6, blue: 1.0) // Light purple for gestures
        case .other:
            return Color(NSColor.controlBackgroundColor)
        }
    }
    
    var foregroundColor: Color {
        switch self {
        case .fn, .command, .control, .option, .shift, .function, .special, .escape, .tab, .gesture:
            return .white
        default:
            return .primary
        }
    }
    
    var shadowColor: Color {
        backgroundColor.opacity(0.3)
    }
}

struct EnhancedKeyCap: View {
    let component: EnhancedKeyComponent
    let style: EnhancedKeyDisplayView.KeyDisplayStyle
    let interactive: Bool
    let customSize: Double?
    let customVerticalPadding: Double?
    let customHorizontalPadding: Double?
    
    @State private var isPressed = false
    @State private var isHovered = false
    
    private var fontSize: Font {
        switch style {
        case .compact:
            return .system(.caption, design: .rounded, weight: .semibold)
        case .prominent:
            return .system(.body, design: .rounded, weight: .bold)
        case .minimal:
            return .system(.caption2, design: .rounded, weight: .medium)
        case .normal:
            return .system(.callout, design: .rounded, weight: .semibold)
        }
    }
    
    private var keySize: CGSize {
        let baseSize: CGSize
        switch style {
        case .compact:
            baseSize = CGSize(width: 32, height: 20)
        case .prominent:
            baseSize = CGSize(width: 48, height: 32)
        case .minimal:
            baseSize = CGSize(width: 24, height: 16)
        case .normal:
            baseSize = CGSize(width: 40, height: 26)
        }
        
        let sizeMultiplier = customSize ?? 1.0
        return CGSize(
            width: baseSize.width * sizeMultiplier,
            height: baseSize.height * sizeMultiplier
        )
    }
    
    private var padding: EdgeInsets {
        switch style {
        case .compact:
            return EdgeInsets(top: 2, leading: 4, bottom: 2, trailing: 4)
        case .prominent:
            return EdgeInsets(top: 4, leading: 6, bottom: 4, trailing: 6)
        case .minimal:
            return EdgeInsets(top: 1, leading: 3, bottom: 1, trailing: 3)
        case .normal:
            return EdgeInsets(top: 3, leading: 5, bottom: 3, trailing: 5)
        }
    }
    
    private var cornerRadius: CGFloat {
        let baseRadius: CGFloat
        switch style {
        case .compact, .minimal:
            baseRadius = 4
        case .prominent:
            baseRadius = 10
        case .normal:
            baseRadius = 7
        }
        
        let sizeMultiplier = customSize ?? 1.0
        return baseRadius * sizeMultiplier
    }
    
    var body: some View {
        Text(component.symbol)
            .font(fontSize)
            .foregroundColor(component.keyType.foregroundColor)
            .frame(width: keySize.width, height: keySize.height)
            .background(
                ZStack {
                    // Main background with subtle gradient
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [
                                    component.keyType.backgroundColor,
                                    component.keyType.backgroundColor.opacity(0.8)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // Highlight effect for modifiers
                    if component.keyType.isModifier {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.3),
                                        Color.clear
                                    ],
                                    startPoint: .top,
                                    endPoint: .center
                                )
                            )
                    }
                    
                    // Subtle inner border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            ),
                            lineWidth: 0.5
                        )
                    
                    // Outer border
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(
                            component.keyType.backgroundColor.opacity(0.6),
                            lineWidth: 1
                        )
                }
            )
            .shadow(
                color: isPressed ? .clear : component.keyType.shadowColor,
                radius: isPressed ? 0 : (style == .prominent ? 4 : 2) * (customSize ?? 1.0),
                x: 0,
                y: isPressed ? 0 : (style == .prominent ? 2 : 1) * (customSize ?? 1.0)
            )
            .scaleEffect(isPressed ? 0.95 : (isHovered && interactive ? 1.05 : 1.0))
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            .animation(.easeInOut(duration: 0.2), value: isHovered)
            .onTapGesture {
                if interactive {
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = false
                        }
                    }
                }
            }
            .onHover { hovering in
                if interactive {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isHovered = hovering
                    }
                }
            }
            .help(component.keyType.isModifier ? component.name : "Key: \(component.name)")
    }
}

struct PlusSymbol: View {
    let style: EnhancedKeyDisplayView.KeyDisplayStyle
    
    private var fontSize: Font {
        switch style {
        case .compact, .minimal:
            return .system(.caption2, weight: .medium)
        case .prominent:
            return .system(.body, weight: .medium)
        case .normal:
            return .system(.callout, weight: .medium)
        }
    }
    
    var body: some View {
        Text("+")
            .font(fontSize)
            .foregroundColor(.secondary)
            .opacity(0.7)
    }
}

// MARK: - Convenience Views

struct CompactKeyDisplay: View {
    let keyCombination: String
    
    var body: some View {
        EnhancedKeyDisplayView(keyCombination: keyCombination, style: .compact, useCustomSettings: false)
    }
}

struct ProminentKeyDisplay: View {
    let keyCombination: String
    let interactive: Bool
    
    init(keyCombination: String, interactive: Bool = false) {
        self.keyCombination = keyCombination
        self.interactive = interactive
    }
    
    var body: some View {
        EnhancedKeyDisplayView(
            keyCombination: keyCombination,
            style: .prominent,
            interactive: interactive,
            useCustomSettings: false
        )
    }
}

struct MinimalKeyDisplay: View {
    let keyCombination: String
    
    var body: some View {
        EnhancedKeyDisplayView(keyCombination: keyCombination, style: .minimal, useCustomSettings: false)
    }
}

struct CustomizableKeyDisplayView: View {
    let keyCombination: String
    let size: Double
    let verticalPadding: Double
    let horizontalPadding: Double
    
    private var keyComponents: [EnhancedKeyComponent] {
        let enhancedView = EnhancedKeyDisplayView(keyCombination: keyCombination)
        return enhancedView.parseKeyCombination(keyCombination)
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(keyComponents.enumerated()), id: \.offset) { index, component in
                if index > 0 {
                    Text("+")
                        .font(.system(.caption2, weight: .medium))
                        .foregroundColor(.secondary)
                        .opacity(0.7)
                }
                
                CustomizableKeyCap(
                    component: component,
                    size: size,
                    verticalPadding: verticalPadding,
                    horizontalPadding: horizontalPadding
                )
            }
        }
    }
}

struct CustomizableKeyCap: View {
    let component: EnhancedKeyComponent
    let size: Double
    let verticalPadding: Double
    let horizontalPadding: Double
    
    private var scaledSize: CGSize {
        CGSize(
            width: 40 * size,
            height: 26 * size
        )
    }
    
    private var fontSize: Font {
        .system(size: 16 * size, weight: .semibold, design: .rounded)
    }
    
    var body: some View {
        Text(component.symbol)
            .font(fontSize)
            .foregroundColor(component.keyType.foregroundColor)
            .frame(width: scaledSize.width, height: scaledSize.height)
            .background(
                RoundedRectangle(cornerRadius: 7 * size)
                    .fill(
                        LinearGradient(
                            colors: [
                                component.keyType.backgroundColor,
                                component.keyType.backgroundColor.opacity(0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 7 * size)
                            .stroke(
                                component.keyType.backgroundColor.opacity(0.6),
                                lineWidth: 1
                            )
                    )
            )
            .shadow(
                color: component.keyType.shadowColor,
                radius: 2 * size,
                x: 0,
                y: 1 * size
            )
    }
}

#Preview {
    VStack(spacing: 20) {
        VStack(alignment: .leading, spacing: 8) {
            Text("New Keys Support")
                .font(.headline)
            EnhancedKeyDisplayView(keyCombination: "⌘F1")
            EnhancedKeyDisplayView(keyCombination: "⌃⌥F17")
            EnhancedKeyDisplayView(keyCombination: "⇧⇥")
            EnhancedKeyDisplayView(keyCombination: "⌘⌫")
            EnhancedKeyDisplayView(keyCombination: "⌘;")
            EnhancedKeyDisplayView(keyCombination: "⌘{")
            EnhancedKeyDisplayView(keyCombination: "⌘←")
            EnhancedKeyDisplayView(keyCombination: "⌘`")
            EnhancedKeyDisplayView(keyCombination: "⌘\\")
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Customizable Display")
                .font(.headline)
            CustomizableKeyDisplayView(
                keyCombination: "⌘⇧K",
                size: 1.5,
                verticalPadding: 8,
                horizontalPadding: 12
            )
            CustomizableKeyDisplayView(
                keyCombination: "⌃⌥F12",
                size: 0.8,
                verticalPadding: 4,
                horizontalPadding: 6
            )
        }
        
        VStack(alignment: .leading, spacing: 8) {
            Text("Normal Style")
                .font(.headline)
            EnhancedKeyDisplayView(keyCombination: "⌘K")
            EnhancedKeyDisplayView(keyCombination: "⌃⌥A")
            EnhancedKeyDisplayView(keyCombination: "⇧⇥")
        }
    }
    .padding()
}