//
//  DeleteTaskUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol DeleteTaskUseCaseProtocol {
    func execute(id: UUID) async throws
}

final class DeleteTaskUseCase: DeleteTaskUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(id: UUID) async throws {
        try await taskRepository.deleteTask(id: id)
    }
}
