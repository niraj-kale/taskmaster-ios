//
//  TaskDetailViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class TaskDetailViewModel {
    
    // MARK: - Properties
    
    var task: Task
    var isLoading = false
    var errorMessage: String?
    var isDeleted = false
    
    // MARK: - Dependencies
    
    private let taskRepository: TaskRepositoryProtocol
    
    // MARK: - Init
    
    init(task: Task, taskRepository: TaskRepositoryProtocol) {
        self.task = task
        self.taskRepository = taskRepository
    }
    
    // MARK: - Actions
    
    func toggleCompletion() async {
        task.isCompleted.toggle()
        await updateTask()
    }
    
    func deleteTask() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await taskRepository.deleteTask(id: task.id)
            isDeleted = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func updateTask() async {
        do {
            task = try await taskRepository.updateTask(task)
        } catch {
            errorMessage = error.localizedDescription
            task.isCompleted.toggle() // Revert on failure
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
