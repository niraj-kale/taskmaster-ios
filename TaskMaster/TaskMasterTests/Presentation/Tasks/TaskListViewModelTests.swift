//
//  TaskListViewModelTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

@MainActor
struct TaskListViewModelTests {
    
    // MARK: - Load Tasks
    
    @Test func loadTasks_success_populatesTasks() async {
        let mock = MockTaskRepo()
        mock.tasks = [Task(title: "Test Task")]
        
        let viewModel = TaskListViewModel(
            getTasksUseCase: GetTasksUseCase(taskRepository: mock),
            taskRepository: mock
        )
        
        await viewModel.loadTasks()
        
        #expect(viewModel.tasks.count == 1)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func loadTasks_failure_setsError() async {
        let mock = MockTaskRepo()
        mock.shouldThrow = true
        
        let viewModel = TaskListViewModel(
            getTasksUseCase: GetTasksUseCase(taskRepository: mock),
            taskRepository: mock
        )
        
        await viewModel.loadTasks()
        
        #expect(viewModel.tasks.isEmpty)
        #expect(viewModel.errorMessage != nil)
    }
    
    // MARK: - Computed Properties
    
    @Test func pendingTasks_filtersCorrectly() async {
        let mock = MockTaskRepo()
        mock.tasks = [
            Task(title: "Pending", isCompleted: false),
            Task(title: "Done", isCompleted: true)
        ]
        
        let viewModel = TaskListViewModel(
            getTasksUseCase: GetTasksUseCase(taskRepository: mock),
            taskRepository: mock
        )
        
        await viewModel.loadTasks()
        
        #expect(viewModel.pendingTasks.count == 1)
        #expect(viewModel.completedTasks.count == 1)
    }
    
    // MARK: - Toggle Task
    
    @Test func toggleTask_updatesCompletion() async {
        let mock = MockTaskRepo()
        let task = Task(title: "Test", isCompleted: false)
        mock.tasks = [task]
        
        let viewModel = TaskListViewModel(
            getTasksUseCase: GetTasksUseCase(taskRepository: mock),
            taskRepository: mock
        )
        
        await viewModel.loadTasks()
        await viewModel.toggleTask(task)
        
        #expect(viewModel.tasks.first?.isCompleted == true)
    }
    
    // MARK: - Delete Task
    
    @Test func deleteTask_removesFromList() async {
        let mock = MockTaskRepo()
        let task = Task(title: "To Delete")
        mock.tasks = [task]
        
        let viewModel = TaskListViewModel(
            getTasksUseCase: GetTasksUseCase(taskRepository: mock),
            taskRepository: mock
        )
        
        await viewModel.loadTasks()
        await viewModel.deleteTask(task)
        
        #expect(viewModel.tasks.isEmpty)
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
    
    func updateTask(_ task: Task) async throws -> Task {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        }
        return task
    }
    
    func deleteTask(id: UUID) async throws {
        tasks.removeAll { $0.id == id }
    }
    
    func searchTasks(query: String) async throws -> [Task] { [] }
}
