//
//  CreateTaskUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol CreateTaskUseCaseProtocol {
    func execute(_ task: Task) async throws -> Task
}

final class CreateTaskUseCase: CreateTaskUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(_ task: Task) async throws -> Task {
        try await taskRepository.createTask(task)
    }
}
