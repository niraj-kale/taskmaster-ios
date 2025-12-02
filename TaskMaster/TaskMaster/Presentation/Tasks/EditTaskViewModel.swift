//
//  EditTaskViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class EditTaskViewModel {
    
    // MARK: - Form Properties
    
    var title: String
    var description: String
    var priority: Priority
    var dueDate: Date?
    var hasDueDate: Bool
    
    // MARK: - State
    
    var isLoading = false
    var errorMessage: String?
    var updatedTask: Task?
    
    // MARK: - Computed
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    // MARK: - Private
    
    private let originalTask: Task
    private let updateTaskUseCase: UpdateTaskUseCaseProtocol
    
    // MARK: - Init
    
    init(task: Task, updateTaskUseCase: UpdateTaskUseCaseProtocol) {
        self.originalTask = task
        self.updateTaskUseCase = updateTaskUseCase
        
        // Populate form with existing values
        self.title = task.title
        self.description = task.description ?? ""
        self.priority = task.priority
        self.dueDate = task.dueDate
        self.hasDueDate = task.dueDate != nil
    }
    
    // MARK: - Actions
    
    func updateTask() async {
        isLoading = true
        errorMessage = nil
        
        var task = originalTask
        task.title = title.trimmingCharacters(in: .whitespaces)
        task.description = description.isEmpty ? nil : description
        task.priority = priority
        task.dueDate = hasDueDate ? dueDate : nil
        task.updatedAt = Date()
        
        do {
            updatedTask = try await updateTaskUseCase.execute(task)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
