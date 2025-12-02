//
//  DeleteCategoryUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct DeleteCategoryUseCaseTests {
    
    @Test func execute_callsRepositoryDelete() async throws {
        let mock = MockCategoryRepo()
        let category = Category(name: "Work", color: "#FF5733", icon: "briefcase", createdAt: Date())
        
        let useCase = DeleteCategoryUseCase(categoryRepository: mock)
        try await useCase.execute(category)
        
        #expect(mock.deletedCategoryId == category.id)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockCategoryRepo()
        mock.shouldThrow = true
        
        let useCase = DeleteCategoryUseCase(categoryRepository: mock)
        
        await #expect(throws: Error.self) {
            try await useCase.execute(Category(name: "Test", color: "#000", icon: "folder", createdAt: Date()))
        }
    }
}

// MARK: - Mock

private final class MockCategoryRepo: CategoryRepositoryProtocol {
    var deletedCategoryId: UUID?
    var shouldThrow = false
    
    func getCategories() async throws -> [Category] { [] }
    func createCategory(_ category: Category) async throws -> Category { category }
    func updateCategory(_ category: Category) async throws -> Category { category }
    
    func deleteCategory(_ category: Category) async throws -> Bool {
        if shouldThrow { throw NSError(domain: "Test", code: 1) }
        deletedCategoryId = category.id
        return true
    }
}

