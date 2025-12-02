//
//  LocalTaskDataSource.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol LocalTaskDataSourceProtocol {
    func getTasks() -> [Task]
    func getTask(id: UUID) -> Task?
    func saveTask(_ task: Task)
    func saveTasks(_ tasks: [Task])
    func deleteTask(id: UUID)
    func clear()
}

/// In-memory cache for tasks (can be replaced with Core Data/SwiftData later)
final class LocalTaskDataSource: LocalTaskDataSourceProtocol {
    
    private var cache: [UUID: Task] = [:]
    
    func getTasks() -> [Task] {
        Array(cache.values).sorted { $0.createdAt > $1.createdAt }
    }
    
    func getTask(id: UUID) -> Task? {
        cache[id]
    }
    
    func saveTask(_ task: Task) {
        cache[task.id] = task
    }
    
    func saveTasks(_ tasks: [Task]) {
        tasks.forEach { cache[$0.id] = $0 }
    }
    
    func deleteTask(id: UUID) {
        cache.removeValue(forKey: id)
    }
    
    func clear() {
        cache.removeAll()
    }
}
