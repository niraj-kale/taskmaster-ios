//
//  TaskCategory.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation
import SwiftUI

/// Represents a task category/list in the TaskMaster app
struct TaskCategory: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var colorHex: String
    var iconName: String
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    
    init(
        id: String = UUID().uuidString,
        name: String,
        colorHex: String = "#007AFF",
        iconName: String = "folder.fill",
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }
    
    /// Returns the SwiftUI color from hex string
    var color: Color {
        Color(hex: colorHex) ?? .blue
    }
}

extension TaskCategory {
    /// Creates a dictionary representation for Firestore
    func toDictionary() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "colorHex": colorHex,
            "iconName": iconName,
            "userId": userId,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "isDeleted": isDeleted
        ]
    }
    
    /// Creates a TaskCategory from a Firestore dictionary
    static func fromDictionary(_ dict: [String: Any], id: String) -> TaskCategory? {
        guard let name = dict["name"] as? String,
              let userId = dict["userId"] as? String else {
            return nil
        }
        
        return TaskCategory(
            id: id,
            name: name,
            colorHex: dict["colorHex"] as? String ?? "#007AFF",
            iconName: dict["iconName"] as? String ?? "folder.fill",
            userId: userId,
            createdAt: (dict["createdAt"] as? Date) ?? Date(),
            updatedAt: (dict["updatedAt"] as? Date) ?? Date(),
            isDeleted: dict["isDeleted"] as? Bool ?? false
        )
    }
}

/// Default categories available in the app
extension TaskCategory {
    static let defaultCategories: [(name: String, colorHex: String, iconName: String)] = [
        ("Personal", "#FF6B6B", "person.fill"),
        ("Work", "#4ECDC4", "briefcase.fill"),
        ("Shopping", "#FFE66D", "cart.fill"),
        ("Health", "#95E1D3", "heart.fill"),
        ("Education", "#DDA0DD", "book.fill")
    ]
}
