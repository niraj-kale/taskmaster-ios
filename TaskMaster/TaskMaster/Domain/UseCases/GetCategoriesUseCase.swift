//
//  GetCategoriesUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol GetCategoriesUseCaseProtocol {
    func execute() async throws -> [Category]
}

final class GetCategoriesUseCase: GetCategoriesUseCaseProtocol {
    
    private let categoryRepository: CategoryRepositoryProtocol
    
    init(categoryRepository: CategoryRepositoryProtocol) {
        self.categoryRepository = categoryRepository
    }
    
    func execute() async throws -> [Category] {
        try await categoryRepository.getCategories()
    }
}

