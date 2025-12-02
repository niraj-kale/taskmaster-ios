//
//  CategoryListViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class CategoryListViewModel {
    
    // MARK: - Properties
    
    var categories: [Category] = []
    var isLoading = false
    var errorMessage: String?
    
    var isEmpty: Bool { categories.isEmpty && !isLoading }
    
    // MARK: - Dependencies
    
    private let getCategoriesUseCase: GetCategoriesUseCaseProtocol
    private let deleteCategoryUseCase: DeleteCategoryUseCaseProtocol
    
    // MARK: - Init
    
    init(
        getCategoriesUseCase: GetCategoriesUseCaseProtocol,
        deleteCategoryUseCase: DeleteCategoryUseCaseProtocol
    ) {
        self.getCategoriesUseCase = getCategoriesUseCase
        self.deleteCategoryUseCase = deleteCategoryUseCase
    }
    
    // MARK: - Actions
    
    func loadCategories() async {
        isLoading = true
        errorMessage = nil
        
        do {
            categories = try await getCategoriesUseCase.execute()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func deleteCategory(_ category: Category) async {
        do {
            try await deleteCategoryUseCase.execute(category)
            categories.removeAll { $0.id == category.id }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func clearError() {
        errorMessage = nil
    }
}
