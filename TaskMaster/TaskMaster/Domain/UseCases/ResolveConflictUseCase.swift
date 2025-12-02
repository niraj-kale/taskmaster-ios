//
//  ResolveConflictUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol ResolveConflictUseCaseProtocol {
    func execute(conflict: TaskConflict, resolution: ConflictResolution) async throws -> Task
}

final class ResolveConflictUseCase: ResolveConflictUseCaseProtocol {
    
    private let taskRepository: TaskRepositoryProtocol
    
    init(taskRepository: TaskRepositoryProtocol) {
        self.taskRepository = taskRepository
    }
    
    func execute(conflict: TaskConflict, resolution: ConflictResolution) async throws -> Task {
        let resolvedTask: Task
        
        switch resolution {
        case .keepLocal:
            // Update remote with local version
            resolvedTask = try await taskRepository.updateTask(conflict.localVersion)
        case .keepRemote:
            // Local will be overwritten by remote on next sync
            resolvedTask = conflict.remoteVersion
        }
        
        return resolvedTask
    }
}

