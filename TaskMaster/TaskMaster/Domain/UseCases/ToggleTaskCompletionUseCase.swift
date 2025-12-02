//
//  ToggleTaskCompletionUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol ToggleTaskCompletionUseCaseProtocol {
    func execute(_ task: Task) async throws -> Task
}

final class ToggleTaskCompletionUseCase: ToggleTaskCompletionUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(_ task: Task) async throws -> Task {
        var updatedTask = task
        updatedTask.isCompleted.toggle()
        updatedTask.updatedAt = Date()
        return try await taskRepository.updateTask(updatedTask)
    }
}
