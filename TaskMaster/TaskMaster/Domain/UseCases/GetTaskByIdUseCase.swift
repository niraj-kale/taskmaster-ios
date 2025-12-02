//
//  GetTaskByIdUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol GetTaskByIdUseCaseProtocol {
    func execute(id: UUID) async throws -> Task?
}

final class GetTaskByIdUseCase: GetTaskByIdUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(id: UUID) async throws -> Task? {
        try await taskRepository.getTask(id: id)
    }
}
