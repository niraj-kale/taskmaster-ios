//
//  CreateTaskViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class CreateTaskViewModel {
    
    // MARK: - Properties
    
    var title = ""
    var description = ""
    var priority: Priority = .medium
    var dueDate: Date?
    var hasDueDate = false
    
    var isLoading = false
    var errorMessage: String?
    var createdTask: Task?
    
    var isFormValid: Bool { !title.trimmingCharacters(in: .whitespaces).isEmpty }
    
    // MARK: - Dependencies
    
    private let createTaskUseCase: CreateTaskUseCaseProtocol
    
    // MARK: - Init
    
    init(createTaskUseCase: CreateTaskUseCaseProtocol) {
        self.createTaskUseCase = createTaskUseCase
    }
    
    // MARK: - Actions
    
    func createTask() async {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        let task = Task(
            title: title.trimmingCharacters(in: .whitespaces),
            description: description.isEmpty ? nil : description,
            priority: priority,
            dueDate: hasDueDate ? dueDate : nil
        )
        
        do {
            createdTask = try await createTaskUseCase.execute(task)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}
