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
    var categories: [Category] = []
    var isLoading = false
    var errorMessage: String?
    var selectedCategoryId: UUID?
    
    var pendingTasks: [Task] { tasks.filter { !$0.isCompleted } }
    var completedTasks: [Task] { tasks.filter { $0.isCompleted } }
    var isEmpty: Bool { tasks.isEmpty && !isLoading }
    
    // MARK: - Dependencies
    
    private let getTasksUseCase: GetTasksUseCaseProtocol
    private let getTasksByCategoryUseCase: GetTasksByCategoryUseCaseProtocol?
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol?
    private let taskRepository: TaskRepositoryProtocol
    
    // MARK: - Init
    
    init(
        getTasksUseCase: GetTasksUseCaseProtocol,
        taskRepository: TaskRepositoryProtocol,
        getTasksByCategoryUseCase: GetTasksByCategoryUseCaseProtocol? = nil,
        getCategoriesUseCase: GetCategoriesUseCaseProtocol? = nil
    ) {
        self.getTasksUseCase = getTasksUseCase
        self.taskRepository = taskRepository
        self.getTasksByCategoryUseCase = getTasksByCategoryUseCase
        self.getCategoriesUseCase = getCategoriesUseCase
    }
    
    // MARK: - Category Lookup
    
    func category(for task: Task) -> Category? {
        guard let categoryId = task.categoryId else { return nil }
        return categories.first { $0.id == categoryId }
    }
    
    // MARK: - Actions
    
    func loadTasks() async {
        isLoading = true
        errorMessage = nil
        
        // Load categories in parallel
        async let categoriesTask: () = loadCategories()
        
        do {
            if let categoryId = selectedCategoryId,
               let useCase = getTasksByCategoryUseCase {
                tasks = try await useCase.execute(categoryId: categoryId)
            } else {
                tasks = try await getTasksUseCase.execute()
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        await categoriesTask
        isLoading = false
    }
    
    private func loadCategories() async {
        guard let useCase = getCategoriesUseCase else { return }
        do {
            categories = try await useCase.execute()
        } catch {
            // Silently fail - categories are optional for display
        }
    }
    
    func filterByCategory(_ categoryId: UUID?) async {
        selectedCategoryId = categoryId
        await loadTasks()
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
