//
//  CreateTaskViewModelTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

@MainActor
struct CreateTaskViewModelTests {
    
    // MARK: - Validation
    
    @Test func isFormValid_withEmptyTitle_returnsFalse() {
        let viewModel = CreateTaskViewModel(createTaskUseCase: MockCreateTaskUseCase())
        viewModel.title = ""
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func isFormValid_withWhitespaceTitle_returnsFalse() {
        let viewModel = CreateTaskViewModel(createTaskUseCase: MockCreateTaskUseCase())
        viewModel.title = "   "
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func isFormValid_withValidTitle_returnsTrue() {
        let viewModel = CreateTaskViewModel(createTaskUseCase: MockCreateTaskUseCase())
        viewModel.title = "Valid Task"
        #expect(viewModel.isFormValid == true)
    }
    
    // MARK: - Create Task
    
    @Test func createTask_success_setsCreatedTask() async {
        let mock = MockCreateTaskUseCase()
        let viewModel = CreateTaskViewModel(createTaskUseCase: mock)
        viewModel.title = "New Task"
        viewModel.priority = .high
        
        await viewModel.createTask()
        
        #expect(viewModel.createdTask != nil)
        #expect(viewModel.createdTask?.title == "New Task")
        #expect(viewModel.createdTask?.priority == .high)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func createTask_failure_setsError() async {
        let mock = MockCreateTaskUseCase()
        mock.shouldThrow = true
        
        let viewModel = CreateTaskViewModel(createTaskUseCase: mock)
        viewModel.title = "Test"
        
        await viewModel.createTask()
        
        #expect(viewModel.createdTask == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test func createTask_withDueDate_includesDate() async {
        let mock = MockCreateTaskUseCase()
        let viewModel = CreateTaskViewModel(createTaskUseCase: mock)
        viewModel.title = "Task with date"
        viewModel.hasDueDate = true
        viewModel.dueDate = Date()
        
        await viewModel.createTask()
        
        #expect(viewModel.createdTask?.dueDate != nil)
    }
    
    @Test func createTask_withoutDueDate_excludesDate() async {
        let mock = MockCreateTaskUseCase()
        let viewModel = CreateTaskViewModel(createTaskUseCase: mock)
        viewModel.title = "Task without date"
        viewModel.hasDueDate = false
        
        await viewModel.createTask()
        
        #expect(viewModel.createdTask?.dueDate == nil)
    }
}

// MARK: - Mock

private final class MockCreateTaskUseCase: CreateTaskUseCaseProtocol {
    var shouldThrow = false
    
    func execute(_ task: Task) async throws -> Task {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return task
    }
}
