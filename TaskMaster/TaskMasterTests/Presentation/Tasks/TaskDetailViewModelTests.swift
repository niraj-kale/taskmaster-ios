//
//  TaskDetailViewModelTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

@MainActor
struct TaskDetailViewModelTests {
    
    // MARK: - Toggle Completion
    
    @Test func toggleCompletion_updatesTask() async {
        let mock = MockTaskRepo()
        let task = Task(title: "Test", isCompleted: false)
        
        let viewModel = TaskDetailViewModel(task: task, taskRepository: mock)
        
        await viewModel.toggleCompletion()
        
        #expect(viewModel.task.isCompleted == true)
    }
    
    @Test func toggleCompletion_revertsOnFailure() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        let task = Task(title: "Test", isCompleted: false)
        
        let viewModel = TaskDetailViewModel(task: task, taskRepository: mock)
        
        await viewModel.toggleCompletion()
        
        #expect(viewModel.task.isCompleted == false)
        #expect(viewModel.errorMessage != nil)
    }
    
    // MARK: - Delete Task
    
    @Test func deleteTask_success_setsIsDeleted() async {
        let mock = MockTaskRepo()
        let task = Task(title: "To Delete")
        
        let viewModel = TaskDetailViewModel(task: task, taskRepository: mock)
        
        await viewModel.deleteTask()
        
        #expect(viewModel.isDeleted == true)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func deleteTask_failure_setsError() async {
        let mock = MockTaskRepo()
        mock.shouldThrowOnDelete = true
        let task = Task(title: "Test")
        
        let viewModel = TaskDetailViewModel(task: task, taskRepository: mock)
        
        await viewModel.deleteTask()
        
        #expect(viewModel.isDeleted == false)
        #expect(viewModel.errorMessage != nil)
    }
}

// MARK: - Mock

private final class MockTaskRepo: TaskRepositoryProtocol {
    var shouldThrow = false
    var shouldThrowOnDelete = false
    
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    
    func updateTask(_ task: Task) async throws -> Task {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return task
    }
    
    func deleteTask(id: UUID) async throws {
        if shouldThrowOnDelete { throw NSError(domain: "Test", code: 1) }
    }
    
    func searchTasks(query: String) async throws -> [Task] { [] }
}
