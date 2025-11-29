//
//  Task.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

/// Priority levels for tasks
enum Priority: Int, CaseIterable, Codable {
    case low = 0
    case medium = 1
    case high = 2
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

/// Domain entity representing a task
struct Task: Identifiable, Equatable, Codable {
    let id: UUID
    var title: String
    var description: String?
    var priority: Priority
    var dueDate: Date?
    var isCompleted: Bool
    var categoryId: UUID?
    let createdAt: Date
    var updatedAt: Date
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String? = nil,
        priority: Priority = .medium,
        dueDate: Date? = nil,
        isCompleted: Bool = false,
        categoryId: UUID? = nil,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.dueDate = dueDate
        self.isCompleted = isCompleted
        self.categoryId = categoryId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
