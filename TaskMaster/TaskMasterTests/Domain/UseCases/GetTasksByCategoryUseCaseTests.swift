//
//  GetTasksByCategoryUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct GetTasksByCategoryUseCaseTests {
    
    @Test func execute_returnsFilteredTasks() async throws {
        let mock = MockTaskRepo()
        let categoryId = UUID()
        let otherCategoryId = UUID()
        
        mock.tasks = [
            Task(title: "Task 1", categoryId: categoryId),
            Task(title: "Task 2", categoryId: otherCategoryId),
            Task(title: "Task 3", categoryId: categoryId),
            Task(title: "Task 4")
        ]
        
        let useCase = GetTasksByCategoryUseCase(taskRepository: mock)
        let result = try await useCase.execute(categoryId: categoryId)
        
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.categoryId == categoryId })
    }
    
    @Test func execute_whenNoMatch_returnsEmptyArray() async throws {
        let mock = MockTaskRepo()
        mock.tasks = [
            Task(title: "Task 1", categoryId: UUID()),
            Task(title: "Task 2")
        ]
        
        let useCase = GetTasksByCategoryUseCase(taskRepository: mock)
        let result = try await useCase.execute(categoryId: UUID())
        
        #expect(result.isEmpty)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let useCase = GetTasksByCategoryUseCase(taskRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(categoryId: UUID())
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

