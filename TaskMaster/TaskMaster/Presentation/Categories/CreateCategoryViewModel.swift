//
//  CreateCategoryViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class CreateCategoryViewModel {
    
    // MARK: - Properties
    
    var name = ""
    var color = "#007AFF"
    var icon = "folder"
    
    var isLoading = false
    var errorMessage: String?
    var createdCategory: Category?
    
    var isFormValid: Bool { !name.trimmingCharacters(in: .whitespaces).isEmpty }
    
    // MARK: - Dependencies
    
    private let createCategoryUseCase: CreateCategoryUseCaseProtocol
    
    // MARK: - Init
    
    init(createCategoryUseCase: CreateCategoryUseCaseProtocol) {
        self.createCategoryUseCase = createCategoryUseCase
    }
    
    // MARK: - Actions
    
    func createCategory() async {
        guard isFormValid else { return }
        
        isLoading = true
        errorMessage = nil
        
        let category = Category(
            name: name.trimmingCharacters(in: .whitespaces),
            color: color,
            icon: icon,
            createdAt: Date()
        )
        
        do {
            createdCategory = try await createCategoryUseCase.execute(category)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}

