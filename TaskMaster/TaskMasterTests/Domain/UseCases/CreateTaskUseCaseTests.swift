//
//  CreateTaskUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct CreateTaskUseCaseTests {
    
    @Test func execute_createsTask() async throws {
        let mock = MockTaskRepo()
        let task = Task(title: "New Task")
        
        let useCase = CreateTaskUseCase(taskRepository: mock)
        let result = try await useCase.execute(task)
        
        #expect(result.title == "New Task")
        #expect(mock.createCalled == true)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = CreateTaskUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(Task(title: "Test"))
        }
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var createCalled = false
    var shouldThrow = false
    
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    
    func createTask(_ task: Task) async throws -> Task {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        createCalled = true
        return task
    }
    
    func updateTask(_ task: Task) async throws -> Task { task }
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}
