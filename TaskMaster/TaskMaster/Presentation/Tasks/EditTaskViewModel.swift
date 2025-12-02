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
    var categoryId: UUID?
    var categories: [Category] = []
    
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
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol?
    
    // MARK: - Init
    
    init(
        task: Task,
        updateTaskUseCase: UpdateTaskUseCaseProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol? = nil
    ) {
        self.originalTask = task
        self.updateTaskUseCase = updateTaskUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
        
        // Populate form with existing values
        self.title = task.title
        self.description = task.description ?? ""
        self.priority = task.priority
        self.dueDate = task.dueDate
        self.hasDueDate = task.dueDate != nil
        self.categoryId = task.categoryId
    }
    
    // MARK: - Actions
    
    func loadCategories() async {
        guard let useCase = getCategoriesUseCase else { return }
        do {
            categories = try await useCase.execute()
        } catch {
            // Silently fail - categories are optional
        }
    }
    
    func updateTask() async {
        isLoading = true
        errorMessage = nil
        
        var task = originalTask
        task.title = title.trimmingCharacters(in: .whitespaces)
        task.description = description.isEmpty ? nil : description
        task.priority = priority
        task.dueDate = hasDueDate ? dueDate : nil
        task.categoryId = categoryId
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
