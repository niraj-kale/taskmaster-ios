//
//  UpdateTaskUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol UpdateTaskUseCaseProtocol {
    func execute(_ task: Task) async throws -> Task
}

final class UpdateTaskUseCase: UpdateTaskUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(_ task: Task) async throws -> Task {
        try await taskRepository.updateTask(task)
    }
}
