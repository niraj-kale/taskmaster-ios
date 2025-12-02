//
//  GetTasksUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol GetTasksUseCaseProtocol {
    func execute() async throws -> [Task]
}

final class GetTasksUseCase: GetTasksUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute() async throws -> [Task] {
        try await taskRepository.getTasks()
    }
}
