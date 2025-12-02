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
    var category: Category?
    var isLoading = false
    var errorMessage: String?
    var isDeleted = false
    
    // MARK: - Dependencies
    
    private let taskRepository: TaskRepositoryProtocol
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol?
    
    // MARK: - Init
    
    init(
        task: Task,
        taskRepository: TaskRepositoryProtocol,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol? = nil
    ) {
        self.task = task
        self.taskRepository = taskRepository
        self.getCategoriesUseCase = getCategoriesUseCase
    }
    
    // MARK: - Actions
    
    func loadCategory() async {
        guard let categoryId = task.categoryId,
              let useCase = getCategoriesUseCase else { return }
        do {
            let categories = try await useCase.execute()
            category = categories.first { $0.id == categoryId }
        } catch {
            // Silently fail
        }
    }
    
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
