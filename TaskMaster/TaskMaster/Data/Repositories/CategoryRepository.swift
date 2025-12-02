//
//  CategoryRepository.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

final class CategoryRepository: CategoryRepositoryProtocol {
    
    private let local: LocalCategoryDataSourceProtocol
    private let remote: RemoteCategoryDataSourceProtocol
    
    init(
        local: LocalCategoryDataSourceProtocol = LocalCategoryDataSource(),
        remote: RemoteCategoryDataSourceProtocol = RemoteCategoryDataSource()
    ) {
        self.local = local
        self.remote = remote
    }
    
    func getCategories() async throws -> [Category] {
        do {
            let categories = try await remote.getCategories()
            local.saveCategories(categories)
            return categories
        } catch {
            let cached = local.getCategories()
            if cached.isEmpty { throw error }
            return cached
        }
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        let created = try await remote.createCategory(category)
        local.saveCategory(created)
        return created
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        let updated = try await remote.updateCategory(category)
        local.saveCategory(updated)
        return updated
    }
    
    func deleteCategory(_ category: Category) async throws -> Bool {
        try await remote.deleteCategory(id: category.id)
        local.deleteCategory(id: category.id)
        return true
    }
}

