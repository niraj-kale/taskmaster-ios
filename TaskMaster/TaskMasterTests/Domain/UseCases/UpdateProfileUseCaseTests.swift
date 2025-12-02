//
//  UpdateProfileUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct UpdateProfileUseCaseTests {
    
    @Test func execute_withDisplayName_updatesProfile() async throws {
        let mock = MockAuthRepo()
        let expectedUser = User(id: "123", email: "test@example.com", displayName: "John")
        mock.updatedUser = expectedUser
        
        let useCase = UpdateProfileUseCase(authRepository: mock)
        let result = try await useCase.execute(displayName: "John")
        
        #expect(result.displayName == "John")
        #expect(mock.lastDisplayName == "John")
    }
    
    @Test func execute_withNilDisplayName_clearsDisplayName() async throws {
        let mock = MockAuthRepo()
        let expectedUser = User(id: "123", email: "test@example.com", displayName: nil)
        mock.updatedUser = expectedUser
        
        let useCase = UpdateProfileUseCase(authRepository: mock)
        let result = try await useCase.execute(displayName: nil)
        
        #expect(result.displayName == nil)
        #expect(mock.lastDisplayName == nil)
    }
    
    @Test func execute_whenError_throws() async {
        let mock = MockAuthRepo()
        mock.shouldThrow = true
        
        let useCase = UpdateProfileUseCase(authRepository: mock)
        
        await #expect(throws: MockError.self) {
            try await useCase.execute(displayName: "Test")
        }
    }
}

// MARK: - Mock

private final class MockAuthRepo: AuthRepositoryProtocol {
    var updatedUser: User?
    var lastDisplayName: String?
    var shouldThrow = false
    
    func signIn(email: String, password: String) async throws -> User { fatalError() }
    func signUp(email: String, password: String) async throws -> User { fatalError() }
    func signInWithGoogle() async throws -> User { fatalError() }
    func signOut() throws {}
    func getCurrentUser() -> User? { nil }
    
    func updateProfile(displayName: String?) async throws -> User {
        if shouldThrow { throw MockError.testError }
        lastDisplayName = displayName
        return updatedUser ?? User(id: "1", email: "test@example.com")
    }
}

private enum MockError: Error {
    case testError
}

