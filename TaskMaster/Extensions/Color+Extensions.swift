//
//  Color+Extensions.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

extension Color {
    /// Initialize Color from hex string
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else {
            return nil
        }
        
        let length = hexSanitized.count
        
        switch length {
        case 6:
            self.init(
                red: Double((rgb & 0xFF0000) >> 16) / 255.0,
                green: Double((rgb & 0x00FF00) >> 8) / 255.0,
                blue: Double(rgb & 0x0000FF) / 255.0
            )
        case 8:
            self.init(
                red: Double((rgb & 0xFF000000) >> 24) / 255.0,
                green: Double((rgb & 0x00FF0000) >> 16) / 255.0,
                blue: Double((rgb & 0x0000FF00) >> 8) / 255.0,
                opacity: Double(rgb & 0x000000FF) / 255.0
            )
        default:
            return nil
        }
    }
    
    /// Convert Color to hex string
    func toHex() -> String? {
        guard let components = cgColor?.components else { return nil }
        
        let r: CGFloat = components.count >= 1 ? components[0] : 0
        let g: CGFloat = components.count >= 2 ? components[1] : 0
        let b: CGFloat = components.count >= 3 ? components[2] : 0
        
        return String(
            format: "#%02lX%02lX%02lX",
            lroundf(Float(r * 255)),
            lroundf(Float(g * 255)),
            lroundf(Float(b * 255))
        )
    }
}

// MARK: - Predefined Colors

extension Color {
    static let taskPriorityHigh = Color.red
    static let taskPriorityMedium = Color.orange
    static let taskPriorityLow = Color.blue
    
    static let taskStatusPending = Color.gray
    static let taskStatusInProgress = Color.blue
    static let taskStatusCompleted = Color.green
}
