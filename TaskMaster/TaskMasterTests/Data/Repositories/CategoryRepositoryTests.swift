//
//  CategoryRepositoryTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct CategoryRepositoryTests {
    
    // MARK: - getCategories
    
    @Test func getCategories_remoteSuccess_cachesLocally() async throws {
        let local = MockLocalCategoryDataSource()
        let remote = MockRemoteCategoryDataSource()
        remote.categories = [Category(name: "Work", color: "blue", icon: "briefcase", createdAt: .now)]
        
        let repo = CategoryRepository(local: local, remote: remote)
        let categories = try await repo.getCategories()
        
        #expect(categories.count == 1)
        #expect(categories[0].name == "Work")
        #expect(local.savedCategories.count == 1)
    }
    
    @Test func getCategories_remoteFails_returnsCached() async throws {
        let local = MockLocalCategoryDataSource()
        local.categories = [Category(name: "Cached", color: "red", icon: "star", createdAt: .now)]
        let remote = MockRemoteCategoryDataSource()
        remote.shouldFail = true
        
        let repo = CategoryRepository(local: local, remote: remote)
        let categories = try await repo.getCategories()
        
        #expect(categories.count == 1)
        #expect(categories[0].name == "Cached")
    }
    
    // MARK: - createCategory
    
    @Test func createCategory_savesToBothSources() async throws {
        let local = MockLocalCategoryDataSource()
        let remote = MockRemoteCategoryDataSource()
        
        let repo = CategoryRepository(local: local, remote: remote)
        let category = Category(name: "Personal", color: "green", icon: "person", createdAt: .now)
        let result = try await repo.createCategory(category)
        
        #expect(result.name == "Personal")
        #expect(remote.createCalled)
        #expect(local.savedCategories.contains { $0.name == "Personal" })
    }
    
    // MARK: - deleteCategory
    
    @Test func deleteCategory_deletesFromBothSources() async throws {
        let category = Category(name: "ToDelete", color: "gray", icon: "trash", createdAt: .now)
        let local = MockLocalCategoryDataSource()
        let remote = MockRemoteCategoryDataSource()
        
        let repo = CategoryRepository(local: local, remote: remote)
        let result = try await repo.deleteCategory(category)
        
        #expect(result == true)
        #expect(remote.deletedId == category.id)
        #expect(local.deletedId == category.id)
    }
}

// MARK: - Mocks

private final class MockLocalCategoryDataSource: LocalCategoryDataSourceProtocol {
    var categories: [Category] = []
    var savedCategories: [Category] = []
    var deletedId: UUID?
    
    func getCategories() -> [Category] { categories }
    func saveCategory(_ category: Category) { savedCategories.append(category) }
    func saveCategories(_ categories: [Category]) { savedCategories.append(contentsOf: categories) }
    func deleteCategory(id: UUID) { deletedId = id }
    func clear() { categories.removeAll() }
}

private final class MockRemoteCategoryDataSource: RemoteCategoryDataSourceProtocol {
    var categories: [Category] = []
    var shouldFail = false
    var createCalled = false
    var deletedId: UUID?
    
    func getCategories() async throws -> [Category] {
        if shouldFail { throw NSError(domain: "Test", code: 1) }
        return categories
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        createCalled = true
        return category
    }
    
    func updateCategory(_ category: Category) async throws -> Category { category }
    
    func deleteCategory(id: UUID) async throws {
        deletedId = id
    }
}

