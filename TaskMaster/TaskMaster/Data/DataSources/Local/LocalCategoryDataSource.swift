//
//  LocalCategoryDataSource.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol LocalCategoryDataSourceProtocol {
    func getCategories() -> [Category]
    func getCategory(id: UUID) -> Category?
    func saveCategory(_ category: Category)
    func saveCategories(_ categories: [Category])
    func deleteCategory(id: UUID)
    func clear()
}

/// In-memory cache for categories
final class LocalCategoryDataSource: LocalCategoryDataSourceProtocol {
    
    private var cache: [UUID: Category] = [:]
    
    func getCategories() -> [Category] {
        Array(cache.values).sorted { $0.createdAt > $1.createdAt }
    }
    
    func getCategory(id: UUID) -> Category? {
        cache[id]
    }
    
    func saveCategory(_ category: Category) {
        cache[category.id] = category
    }
    
    func saveCategories(_ categories: [Category]) {
        categories.forEach { cache[$0.id] = $0 }
    }
    
    func deleteCategory(id: UUID) {
        cache.removeValue(forKey: id)
    }
    
    func clear() {
        cache.removeAll()
    }
}

