//
//  SyncDataUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct SyncDataUseCaseTests {
    
    @Test func execute_returnsSyncedStatus() async throws {
        let mock = MockSyncRepo()
        mock.syncResult = .synced
        
        let useCase = SyncDataUseCase(syncRepository: mock)
        let result = try await useCase.execute()
        
        #expect(result == .synced)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockSyncRepo()
        mock.shouldThrow = true
        
        let useCase = SyncDataUseCase(syncRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute()
        }
    }
    
    @Test func getStatus_returnsCurrentStatus() async {
        let mock = MockSyncRepo()
        mock.currentStatus = .pending
        
        let useCase = SyncDataUseCase(syncRepository: mock)
        let result = await useCase.getStatus()
        
        #expect(result == .pending)
    }
}

// MARK: - Mock

private final class MockSyncRepo: SyncRepositoryProtocol {
    var syncResult: SyncStatus = .synced
    var currentStatus: SyncStatus = .none
    var shouldThrow = false
    
    func syncTasks() async throws -> SyncStatus {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return syncResult
    }
    
    func getSyncStatus() async -> SyncStatus {
        return currentStatus
    }
}

