//
//  ToggleTaskCompletionUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct ToggleTaskCompletionUseCaseTests {
    
    @Test func execute_togglesFromIncompleteToComplete() async throws {
        let mock = MockTaskRepo()
        let task = Task(title: "Test", isCompleted: false)
        
        let useCase = ToggleTaskCompletionUseCase(taskRepository: mock)
        let result = try await useCase.execute(task)
        
        #expect(result.isCompleted == true)
    }
    
    @Test func execute_togglesFromCompleteToIncomplete() async throws {
        let mock = MockTaskRepo()
        let task = Task(title: "Test", isCompleted: true)
        
        let useCase = ToggleTaskCompletionUseCase(taskRepository: mock)
        let result = try await useCase.execute(task)
        
        #expect(result.isCompleted == false)
    }
    
    @Test func execute_updatesTimestamp() async throws {
        let mock = MockTaskRepo()
        let oldDate = Date.distantPast
        var task = Task(title: "Test")
        task.updatedAt = oldDate
        
        let useCase = ToggleTaskCompletionUseCase(taskRepository: mock)
        let result = try await useCase.execute(task)
        
        #expect(result.updatedAt > oldDate)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = ToggleTaskCompletionUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(Task(title: "Test"))
        }
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var shouldThrow = false
    
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    
    func updateTask(_ task: Task) async throws -> Task {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return task
    }
    
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}
