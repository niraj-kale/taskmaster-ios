//
//  DeleteCategoryUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol DeleteCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws
}

final class DeleteCategoryUseCase: DeleteCategoryUseCaseProtocol {
    
    private let categoryRepository: CategoryRepositoryProtocol
    
    init(categoryRepository: CategoryRepositoryProtocol) {
        self.categoryRepository = categoryRepository
    }
    
    func execute(_ category: Category) async throws {
        _ = try await categoryRepository.deleteCategory(category)
    }
}

