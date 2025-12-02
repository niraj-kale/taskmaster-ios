//
//  ResolveConflictUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct ResolveConflictUseCaseTests {
    
    @Test func execute_keepLocal_updatesWithLocalVersion() async throws {
        let mock = MockTaskRepo()
        let localTask = Task(title: "Local Version")
        let remoteTask = Task(title: "Remote Version")
        let conflict = TaskConflict(localVersion: localTask, remoteVersion: remoteTask)
        
        let useCase = ResolveConflictUseCase(taskRepository: mock)
        let result = try await useCase.execute(conflict: conflict, resolution: .keepLocal)
        
        #expect(result.title == "Local Version")
        #expect(mock.updatedTask?.title == "Local Version")
    }
    
    @Test func execute_keepRemote_returnsRemoteVersion() async throws {
        let mock = MockTaskRepo()
        let localTask = Task(title: "Local Version")
        let remoteTask = Task(title: "Remote Version")
        let conflict = TaskConflict(localVersion: localTask, remoteVersion: remoteTask)
        
        let useCase = ResolveConflictUseCase(taskRepository: mock)
        let result = try await useCase.execute(conflict: conflict, resolution: .keepRemote)
        
        #expect(result.title == "Remote Version")
        #expect(mock.updatedTask == nil) // No update called for keepRemote
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        let conflict = TaskConflict(
            localVersion: Task(title: "Local"),
            remoteVersion: Task(title: "Remote")
        )
        
        let useCase = ResolveConflictUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(conflict: conflict, resolution: .keepLocal)
        }
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var updatedTask: Task?
    var shouldThrow = false
    
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    
    func updateTask(_ task: Task) async throws -> Task {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        updatedTask = task
        return task
    }
    
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}

