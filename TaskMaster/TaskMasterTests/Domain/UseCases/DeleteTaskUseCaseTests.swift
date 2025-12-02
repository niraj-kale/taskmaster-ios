//
//  DeleteTaskUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct DeleteTaskUseCaseTests {
    
    @Test func execute_callsRepositoryDelete() async throws {
        let mock = MockTaskRepo()
        let taskId = UUID()
        
        let useCase = DeleteTaskUseCase(taskRepository: mock)
        try await useCase.execute(id: taskId)
        
        #expect(mock.deletedTaskId == taskId)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = DeleteTaskUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(id: UUID())
        }
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var deletedTaskId: UUID?
    var shouldThrow = false
    
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    func updateTask(_ task: Task) async throws -> Task { task }
    
    func deleteTask(id: UUID) async throws {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        deletedTaskId = id
    }
    
    func searchTasks(query: String) async throws -> [Task] { [] }
}
