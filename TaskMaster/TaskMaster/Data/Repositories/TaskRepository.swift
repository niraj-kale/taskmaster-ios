//
//  TaskRepository.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

final class TaskRepository: TaskRepositoryProtocol {
    
    private let local: LocalTaskDataSourceProtocol
    private let remote: RemoteTaskDataSourceProtocol
    
    init(
        local: LocalTaskDataSourceProtocol = LocalTaskDataSource(),
        remote: RemoteTaskDataSourceProtocol = RemoteTaskDataSource()
    ) {
        self.local = local
        self.remote = remote
    }
    
    func getTasks() async throws -> [Task] {
        // Try remote first, fall back to local cache
        do {
            let tasks = try await remote.getTasks()
            local.saveTasks(tasks)
            return tasks
        } catch {
            let cached = local.getTasks()
            if cached.isEmpty { throw error }
            return cached
        }
    }
    
    func getTask(id: UUID) async throws -> Task? {
        // Check local first, then remote
        if let cached = local.getTask(id: id) {
            return cached
        }
        
        let task = try await remote.getTask(id: id)
        if let task { local.saveTask(task) }
        return task
    }
    
    func createTask(_ task: Task) async throws -> Task {
        let created = try await remote.createTask(task)
        local.saveTask(created)
        return created
    }
    
    func updateTask(_ task: Task) async throws -> Task {
        let updated = try await remote.updateTask(task)
        local.saveTask(updated)
        return updated
    }
    
    func deleteTask(id: UUID) async throws {
        try await remote.deleteTask(id: id)
        local.deleteTask(id: id)
    }
    
    func searchTasks(query: String) async throws -> [Task] {
        let tasks = try await getTasks()
        guard !query.isEmpty else { return tasks }
        
        let lowercased = query.lowercased()
        return tasks.filter {
            $0.title.lowercased().contains(lowercased) ||
            ($0.description?.lowercased().contains(lowercased) ?? false)
        }
    }
}
