//
//  SyncDataUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol SyncDataUseCaseProtocol {
    func execute() async throws -> SyncStatus
    func getStatus() async -> SyncStatus
}

final class SyncDataUseCase: SyncDataUseCaseProtocol {
    
    private let syncRepository: SyncRepositoryProtocol
    
    init(syncRepository: SyncRepositoryProtocol) {
        self.syncRepository = syncRepository
    }
    
    func execute() async throws -> SyncStatus {
        try await syncRepository.syncTasks()
    }
    
    func getStatus() async -> SyncStatus {
        await syncRepository.getSyncStatus()
    }
}

