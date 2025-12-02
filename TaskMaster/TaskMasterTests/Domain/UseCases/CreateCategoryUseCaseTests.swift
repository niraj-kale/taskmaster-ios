//
//  CreateCategoryUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct CreateCategoryUseCaseTests {
    
    @Test func execute_createsCategory() async throws {
        let mock = MockCategoryRepo()
        let category = Category(name: "Work", color: "#FF5733", icon: "briefcase", createdAt: Date())
        
        let useCase = CreateCategoryUseCase(categoryRepository: mock)
        let result = try await useCase.execute(category)
        
        #expect(result.name == "Work")
        #expect(mock.createCalled == true)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockCategoryRepo()
        mock.shouldThrow = true
        
        let useCase = CreateCategoryUseCase(categoryRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(Category(name: "Test", color: "#000", icon: "folder", createdAt: Date()))
        }
    }
}

// MARK: - Mock

private final class MockCategoryRepo: CategoryRepositoryProtocol {
    var createCalled = false
    var shouldThrow = false
    
    func getCategories() async throws -> [Category] { [] }
    
    func createCategory(_ category: Category) async throws -> Category {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        createCalled = true
        return category
    }
    
    func updateCategory(_ category: Category) async throws -> Category { category }
    func deleteCategory(_ category: Category) async throws -> Bool { true }
}

