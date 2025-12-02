//
//  GetTaskByIdUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct GetTaskByIdUseCaseTests {
    
    @Test func execute_whenTaskExists_returnsTask() async throws {
        let mock = MockTaskRepo()
        let expectedTask = Task(title: "Test Task")
        mock.taskToReturn = expectedTask
        
        let useCase = GetTaskByIdUseCase(taskRepository: mock)
        let result = try await useCase.execute(id: expectedTask.id)
        
        #expect(result?.id == expectedTask.id)
        #expect(result?.title == "Test Task")
    }
    
    @Test func execute_whenTaskNotFound_returnsNil() async throws {
        let mock = MockTaskRepo()
        mock.taskToReturn = nil
        
        let useCase = GetTaskByIdUseCase(taskRepository: mock)
        let result = try await useCase.execute(id: UUID())
        
        #expect(result == nil)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = GetTaskByIdUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(id: UUID())
        }
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var taskToReturn: Task?
    var shouldThrow = false
    
    func getTasks() async throws -> [Task] { [] }
    
    func getTask(id: UUID) async throws -> Task? {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return taskToReturn
    }
    
    func createTask(_ task: Task) async throws -> Task { task }
    func updateTask(_ task: Task) async throws -> Task { task }
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}
