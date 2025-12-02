//
//  GetCategoriesUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct GetCategoriesUseCaseTests {
    
    @Test func execute_returnsCategories() async throws {
        let mock = MockCategoryRepo()
        let expectedCategories = [
            Category(name: "Work", color: "#FF5733", icon: "briefcase", createdAt: Date()),
            Category(name: "Personal", color: "#33A1FF", icon: "person", createdAt: Date())
        ]
        mock.categories = expectedCategories
        
        let useCase = GetCategoriesUseCase(categoryRepository: mock)
        let result = try await useCase.execute()
        
        #expect(result.count == 2)
        #expect(result[0].name == "Work")
    }
    
    @Test func execute_whenEmpty_returnsEmptyArray() async throws {
        let mock = MockCategoryRepo()
        mock.categories = []
        
        let useCase = GetCategoriesUseCase(categoryRepository: mock)
        let result = try await useCase.execute()
        
        #expect(result.isEmpty)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockCategoryRepo()
        mock.shouldThrow = true
        
        let useCase = GetCategoriesUseCase(categoryRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute()
        }
    }
}

// MARK: - Mock

private final class MockCategoryRepo: CategoryRepositoryProtocol {
    var categories: [Category] = []
    var shouldThrow = false
    
    func getCategories() async throws -> [Category] {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        return categories
    }
    
    func createCategory(_ category: Category) async throws -> Category { category }
    func updateCategory(_ category: Category) async throws -> Category { category }
    func deleteCategory(_ category: Category) async throws -> Bool { true }
}

