//
//  TaskDetailViewModel.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation

@MainActor
final class TaskDetailViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var title: String = ""
    @Published var description: String = ""
    @Published var priority: TaskPriority = .medium
    @Published var status: TaskStatus = .pending
    @Published var dueDate: Date?
    @Published var hasDueDate: Bool = false
    @Published var selectedCategoryId: String?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var isSaved: Bool = false
    
    // MARK: - Properties
    
    private var existingTask: TaskItem?
    private let firestoreService: FirestoreServiceProtocol
    private let authService: AuthenticationService
    
    var isEditing: Bool {
        existingTask != nil
    }
    
    var isFormValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Initialization
    
    init(
        task: TaskItem? = nil,
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared,
        authService: AuthenticationService = .shared
    ) {
        self.existingTask = task
        self.firestoreService = firestoreService
        self.authService = authService
        
        if let task = task {
            loadTask(task)
        }
    }
    
    // MARK: - Data Loading
    
    private func loadTask(_ task: TaskItem) {
        title = task.title
        description = task.description
        priority = task.priority
        status = task.status
        dueDate = task.dueDate
        hasDueDate = task.dueDate != nil
        selectedCategoryId = task.categoryId
    }
    
    // MARK: - Actions
    
    func save() async {
        guard isFormValid else {
            errorMessage = "Please enter a task title."
            return
        }
        
        guard let userId = authService.currentUser?.id else {
            errorMessage = "Please sign in to save tasks."
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        let task = TaskItem(
            id: existingTask?.id ?? UUID().uuidString,
            title: title.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            priority: priority,
            status: status,
            dueDate: hasDueDate ? dueDate : nil,
            categoryId: selectedCategoryId,
            userId: userId,
            createdAt: existingTask?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        do {
            if isEditing {
                try await firestoreService.updateTask(task)
            } else {
                try await firestoreService.createTask(task)
            }
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func delete() async {
        guard let task = existingTask else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await firestoreService.deleteTask(task.id)
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    func toggleDueDate() {
        if hasDueDate && dueDate == nil {
            dueDate = Date()
        }
    }
}
