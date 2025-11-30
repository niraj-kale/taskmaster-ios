//
//  CategoryRepositoryProtocol.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

protocol CategoryRepositoryProtocol {
    func getCategories() async throws -> [Category]
    func createCategory(_ category: Category) async throws -> Category
    func deleteCategory(_ category: Category) async throws -> Bool
    func updateCategory(_ category: Category) async throws -> Category
}
