//
//  SignOutUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct SignOutUseCaseTests {
    
    @Test func execute_callsRepositorySignOut() throws {
        let mock = MockAuthRepo()
        let useCase = SignOutUseCase(authRepository: mock)
        
        try useCase.execute()
        
        #expect(mock.signOutCalled == true)
    }
    
    @Test func execute_whenRepositoryThrows_propagatesError() {
        let mock = MockAuthRepo()
        mock.shouldThrow = true
        let useCase = SignOutUseCase(authRepository: mock)
        
        #expect(throws: Error.self) {
            try useCase.execute()
        }
    }
}

// MARK: - Mock

private final class MockAuthRepo: AuthRepositoryProtocol {
    var signOutCalled = false
    var shouldThrow = false
    
    func signIn(email: String, password: String) async throws -> User { fatalError() }
    func signUp(email: String, password: String) async throws -> User { fatalError() }
    func signInWithGoogle() async throws -> User { fatalError() }
    
    func signOut() throws {
        if shouldThrow {
            throw NSError(domain: "Test", code: 1)
        }
        signOutCalled = true
    }
    
    func getCurrentUser() -> User? { nil }
}
