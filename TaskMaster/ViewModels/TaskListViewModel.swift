//
//  TaskListViewModel.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation
import Combine
import FirebaseFirestore

/// Filter options for task list
enum TaskFilter: String, CaseIterable {
    case all = "All"
    case pending = "Pending"
    case inProgress = "In Progress"
    case completed = "Completed"
}

/// Sort options for task list
enum TaskSortOption: String, CaseIterable {
    case dateCreated = "Date Created"
    case dueDate = "Due Date"
    case priority = "Priority"
    case title = "Title"
}

@MainActor
final class TaskListViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var tasks: [TaskItem] = []
    @Published var categories: [TaskCategory] = []
    @Published var searchText: String = ""
    @Published var selectedFilter: TaskFilter = .all
    @Published var selectedCategoryId: String?
    @Published var sortOption: TaskSortOption = .dateCreated
    @Published var sortAscending: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Computed Properties
    
    var filteredTasks: [TaskItem] {
        var result = tasks
        
        // Apply status filter
        switch selectedFilter {
        case .all:
            break
        case .pending:
            result = result.filter { $0.status == .pending }
        case .inProgress:
            result = result.filter { $0.status == .inProgress }
        case .completed:
            result = result.filter { $0.status == .completed }
        }
        
        // Apply category filter
        if let categoryId = selectedCategoryId {
            result = result.filter { $0.categoryId == categoryId }
        }
        
        // Apply search filter
        if !searchText.isEmpty {
            result = result.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.description.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Apply sorting
        result = sortTasks(result)
        
        return result
    }
    
    var pendingTasksCount: Int {
        tasks.filter { $0.status == .pending }.count
    }
    
    var completedTasksCount: Int {
        tasks.filter { $0.status == .completed }.count
    }
    
    // MARK: - Dependencies
    
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthenticationService
    private var taskListener: ListenerRegistration?
    private var categoryListener: ListenerRegistration?
    
    // MARK: - Initialization
    
    init(
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authService: AuthenticationService = .shared
    ) {
        self.firestoreService = firestoreService
        self.authService = authService
    }
    
    deinit {
        taskListener?.remove()
        categoryListener?.remove()
    }
    
    // MARK: - Data Loading
    
    func startObserving() {
        guard let userId = authService.currentUser?.id else { return }
        
        taskListener?.remove()
        categoryListener?.remove()
        
        // Observe tasks
        taskListener = firestoreService.observeTasks(for: userId) { [weak self] tasks in
            DispatchQueue.main.async {
                self?.tasks = tasks
            }
        }
        
        // Observe categories
        categoryListener = firestoreService.observeCategories(for: userId) { [weak self] categories in
            DispatchQueue.main.async {
                self?.categories = categories
            }
        }
    }
    
    func stopObserving() {
        taskListener?.remove()
        categoryListener?.remove()
        taskListener = nil
        categoryListener = nil
    }
    
    func loadTasks() async {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "Please sign in to view tasks."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            tasks = try await firestoreService.getTasks(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadCategories() async {
        guard let userId = authService.currentUser?.id else { return }
        
        do {
            categories = try await firestoreService.getCategories(for: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Task Operations
    
    func createTask(
        title: String,
        description: String = "",
        priority: TaskPriority = .medium,
        dueDate: Date? = nil,
        categoryId: String? = nil
    ) async {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "Please sign in to create tasks."
            return
        }
        
        let task = TaskItem(
            title: title,
            description: description,
            priority: priority,
            dueDate: dueDate,
            categoryId: categoryId,
            userId: userId
        )
        
        do {
            try await firestoreService.createTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateTask(_ task: TaskItem) async {
        do {
            try await firestoreService.updateTask(task)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteTask(_ task: TaskItem) async {
        do {
            try await firestoreService.deleteTask(task.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleTaskCompletion(_ task: TaskItem) async {
        var updatedTask = task
        updatedTask.status = task.status == .completed ? .pending : .completed
        await updateTask(updatedTask)
    }
    
    // MARK: - Category Operations
    
    func createCategory(name: String, colorHex: String, iconName: String) async {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "Please sign in to create categories."
            return
        }
        
        let category = TaskCategory(
            name: name,
            colorHex: colorHex,
            iconName: iconName,
            userId: userId
        )
        
        do {
            try await firestoreService.createCategory(category)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func createDefaultCategories() async {
        guard let userId = authService.currentUser?.id else { return }
        
        for defaultCategory in TaskCategory.defaultCategories {
            let category = TaskCategory(
                name: defaultCategory.name,
                colorHex: defaultCategory.colorHex,
                iconName: defaultCategory.iconName,
                userId: userId
            )
            
            do {
                try await firestoreService.createCategory(category)
            } catch {
                // Log error but continue creating other categories
                print("Failed to create default category '\(defaultCategory.name)': \(error.localizedDescription)")
            }
        }
    }
    
    func deleteCategory(_ category: TaskCategory) async {
        do {
            try await firestoreService.deleteCategory(category.id)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Helper Methods
    
    func getCategoryName(for categoryId: String?) -> String? {
        guard let categoryId = categoryId else { return nil }
        return categories.first { $0.id == categoryId }?.name
    }
    
    func getCategory(for categoryId: String?) -> TaskCategory? {
        guard let categoryId = categoryId else { return nil }
        return categories.first { $0.id == categoryId }
    }
    
    private func sortTasks(_ tasks: [TaskItem]) -> [TaskItem] {
        let sorted: [TaskItem]
        
        switch sortOption {
        case .dateCreated:
            sorted = tasks.sorted { $0.createdAt > $1.createdAt }
        case .dueDate:
            sorted = tasks.sorted {
                guard let date1 = $0.dueDate else { return false }
                guard let date2 = $1.dueDate else { return true }
                return date1 < date2
            }
        case .priority:
            sorted = tasks.sorted { $0.priority.sortOrder < $1.priority.sortOrder }
        case .title:
            sorted = tasks.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        }
        
        return sortAscending ? sorted.reversed() : sorted
    }
    
    func clearError() {
        errorMessage = nil
    }
}
