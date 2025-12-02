//
//  CreateCategoryUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol CreateCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws -> Category
}

final class CreateCategoryUseCase: CreateCategoryUseCaseProtocol {
    
    private let categoryRepository: CategoryRepositoryProtocol
    
    init(categoryRepository: CategoryRepositoryProtocol) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(_ category: Category) async throws -> Category {
        try await categoryRepository.createCategory(category)
    }
}

