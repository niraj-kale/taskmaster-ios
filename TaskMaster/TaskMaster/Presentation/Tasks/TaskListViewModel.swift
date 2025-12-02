//
//  TaskListViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class TaskListViewModel {
    
    // MARK: - Properties
    
    var tasks: [Task] = []
    var isLoading = false
    var errorMessage: String?
    
    var pendingTasks: [Task] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [Task] { tasks.filter { $0.isCompleted } }
    var isEmpty: Bool { tasks.isEmpty && !isLoading }
    
    // MARK: - Dependencies
    
    private let getTasksUseCase: GetTasksUseCaseProtocol
    private let taskRepository: TaskRepositoryProtocol
    
    // MARK: - Init
    
    init(
        getTasksUseCase: GetTasksUseCaseProtocol,
        taskRepository: TaskRepositoryProtocol
    ) {
        self.getTasksUseCase = getTasksUseCase
        self.taskRepository = taskRepository
    }
    
    // MARK: - Actions
    
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        do {
            tasks = try await getTasksUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func toggleTask(_ task: Task) async {
        var updated = task
        updated.isCompleted.toggle()
        
        do {
            let result = try await taskRepository.updateTask(updated)
            if let index = tasks.firstIndex(where: { $0.id == result.id }) {
                tasks[index] = result
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteTask(_ task: Task) async {
        do {
            try await taskRepository.deleteTask(id: task.id)
            tasks.removeAll { $0.id == task.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
