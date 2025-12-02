//
//  EditTaskViewModelTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

@MainActor
struct EditTaskViewModelTests {
    
    // MARK: - Initialization
    
    @Test func init_populatesFormWithTaskData() {
        let task = Task(
            title: "Test Task",
            description: "Description",
            priority: .high,
            dueDate: Date()
        )
        let mock = MockUpdateUseCase()
        
        let viewModel = EditTaskViewModel(task: task, updateTaskUseCase: mock)
        
        #expect(viewModel.title == "Test Task")
        #expect(viewModel.description == "Description")
        #expect(viewModel.priority == .high)
        #expect(viewModel.hasDueDate == true)
    }
    
    // MARK: - Validation
    
    @Test func isFormValid_withEmptyTitle_returnsFalse() {
        let task = Task(title: "Test")
        let mock = MockUpdateUseCase()
        let viewModel = EditTaskViewModel(task: task, updateTaskUseCase: mock)
        
        viewModel.title = "   "
        
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func isFormValid_withValidTitle_returnsTrue() {
        let task = Task(title: "Test")
        let mock = MockUpdateUseCase()
        let viewModel = EditTaskViewModel(task: task, updateTaskUseCase: mock)
        
        viewModel.title = "Updated Title"
        
        #expect(viewModel.isFormValid == true)
    }
    
    // MARK: - Update
    
    @Test func updateTask_success_setsUpdatedTask() async {
        let task = Task(title: "Original")
        let mock = MockUpdateUseCase()
        let viewModel = EditTaskViewModel(task: task, updateTaskUseCase: mock)
        
        viewModel.title = "Updated"
        await viewModel.updateTask()
        
        #expect(viewModel.updatedTask != nil)
        #expect(viewModel.updatedTask?.title == "Updated")
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func updateTask_failure_setsError() async {
        let task = Task(title: "Test")
        let mock = MockUpdateUseCase()
        mock.shouldThrow = true
        let viewModel = EditTaskViewModel(task: task, updateTaskUseCase: mock)
        
        await viewModel.updateTask()
        
        #expect(viewModel.updatedTask == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    @Test func updateTask_clearsDescriptionWhenEmpty() async {
        let task = Task(title: "Test", description: "Old description")
        let mock = MockUpdateUseCase()
        let viewModel = EditTaskViewModel(task: task, updateTaskUseCase: mock)
        
        viewModel.description = ""
        await viewModel.updateTask()
        
        #expect(viewModel.updatedTask?.description == nil)
    }
}

// MARK: - Mock

private final class MockUpdateUseCase: UpdateTaskUseCaseProtocol {
    var shouldThrow = false
    
    func execute(_ task: Task) async throws -> Task {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return task
    }
}
