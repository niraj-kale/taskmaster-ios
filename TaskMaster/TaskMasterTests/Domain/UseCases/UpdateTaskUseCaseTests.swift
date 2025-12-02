//
//  UpdateTaskUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct UpdateTaskUseCaseTests {
    
    @Test func execute_updatesTask() async throws {
        let mock = MockTaskRepo()
        var task = Task(title: "Original")
        task.title = "Updated"
        
        let useCase = UpdateTaskUseCase(taskRepository: mock)
        let result = try await useCase.execute(task)
        
        #expect(result.title == "Updated")
        #expect(mock.updatedTask?.title == "Updated")
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = UpdateTaskUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(Task(title: "Test"))
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
