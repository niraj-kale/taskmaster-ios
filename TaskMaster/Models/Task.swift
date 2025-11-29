//
//  Task.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation

/// Priority levels for tasks
enum TaskPriority: String, Codable, CaseIterable {
    case low = "low"
    case medium = "medium"
    case high = "high"
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
    
    var sortOrder: Int {
        switch self {
        case .high: return 0
        case .medium: return 1
        case .low: return 2
        }
    }
}

/// Status of a task
enum TaskStatus: String, Codable, CaseIterable {
    case pending = "pending"
    case inProgress = "in_progress"
    case completed = "completed"
    
    var displayName: String {
        switch self {
        case .pending: return "Pending"
        case .inProgress: return "In Progress"
        case .completed: return "Completed"
        }
    }
}

/// Represents a task in the TaskMaster app
struct TaskItem: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var description: String
    var priority: TaskPriority
    var status: TaskStatus
    var dueDate: Date?
    var categoryId: String?
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    var isDeleted: Bool
    
    init(
        id: String = UUID().uuidString,
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        status: TaskStatus = .pending,
        dueDate: Date? = nil,
        categoryId: String? = nil,
        userId: String,
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        isDeleted: Bool = false
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.priority = priority
        self.status = status
        self.dueDate = dueDate
        self.categoryId = categoryId
        self.userId = userId
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.isDeleted = isDeleted
    }
}

extension TaskItem {
    /// Creates a dictionary representation for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "title": title,
            "description": description,
            "priority": priority.rawValue,
            "status": status.rawValue,
            "userId": userId,
            "createdAt": createdAt,
            "updatedAt": updatedAt,
            "isDeleted": isDeleted
        ]
        if let dueDate = dueDate {
            dict["dueDate"] = dueDate
        }
        if let categoryId = categoryId {
            dict["categoryId"] = categoryId
        }
        return dict
    }
    
    /// Creates a TaskItem from a Firestore dictionary
    static func fromDictionary(_ dict: [String: Any], id: String) -> TaskItem? {
        guard let title = dict["title"] as? String,
              let userId = dict["userId"] as? String else {
            return nil
        }
        
        let priorityString = dict["priority"] as? String ?? "medium"
        let statusString = dict["status"] as? String ?? "pending"
        
        return TaskItem(
            id: id,
            title: title,
            description: dict["description"] as? String ?? "",
            priority: TaskPriority(rawValue: priorityString) ?? .medium,
            status: TaskStatus(rawValue: statusString) ?? .pending,
            dueDate: dict["dueDate"] as? Date,
            categoryId: dict["categoryId"] as? String,
            userId: userId,
            createdAt: (dict["createdAt"] as? Date) ?? Date(),
            updatedAt: (dict["updatedAt"] as? Date) ?? Date(),
            isDeleted: dict["isDeleted"] as? Bool ?? false
        )
    }
}
