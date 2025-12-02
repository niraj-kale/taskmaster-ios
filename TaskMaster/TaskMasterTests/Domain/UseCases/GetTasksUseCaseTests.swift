//
//  GetTasksUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct GetTasksUseCaseTests {
    
    @Test func execute_returnsTasks() async throws {
        let mock = MockTaskRepo()
        let expectedTasks = [
            Task(title: "Task 1"),
            Task(title: "Task 2")
        ]
        mock.tasks = expectedTasks
        
        let useCase = GetTasksUseCase(taskRepository: mock)
        let result = try await useCase.execute()
        
        #expect(result.count == 2)
        #expect(result[0].title == "Task 1")
    }
    
    @Test func execute_whenEmpty_returnsEmptyArray() async throws {
        let mock = MockTaskRepo()
        mock.tasks = []
        
        let useCase = GetTasksUseCase(taskRepository: mock)
        let result = try await useCase.execute()
        
        #expect(result.isEmpty)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = GetTasksUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute()
        }
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var tasks: [Task] = []
    var shouldThrow = false
    
    func getTasks() async throws -> [Task] {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return tasks
    }
    
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    func updateTask(_ task: Task) async throws -> Task { task }
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}
