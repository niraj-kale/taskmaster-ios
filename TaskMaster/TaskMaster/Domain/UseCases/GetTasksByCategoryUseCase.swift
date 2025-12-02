//
//  GetTasksByCategoryUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol GetTasksByCategoryUseCaseProtocol {
    func execute(categoryId: UUID) async throws -> [Task]
}

final class GetTasksByCategoryUseCase: GetTasksByCategoryUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(categoryId: UUID) async throws -> [Task] {
        let tasks = try await taskRepository.getTasks()
        return tasks.filter { $0.categoryId == categoryId }
    }
}

