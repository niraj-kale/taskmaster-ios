//
//  GetCurrentUserUseCaseTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

struct GetCurrentUserUseCaseTests {
    
    @Test func execute_whenUserExists_returnsUser() {
        let mock = MockAuthRepo()
        let expectedUser = User(id: "123", email: "test@example.com")
        mock.currentUser = expectedUser
        
        let useCase = GetCurrentUserUseCase(authRepository: mock)
        let result = useCase.execute()
        
        #expect(result?.id == expectedUser.id)
        #expect(result?.email == expectedUser.email)
    }
    
    @Test func execute_whenNoUser_returnsNil() {
        let mock = MockAuthRepo()
        mock.currentUser = nil
        
        let useCase = GetCurrentUserUseCase(authRepository: mock)
        let result = useCase.execute()
        
        #expect(result == nil)
    }
}

// MARK: - Mock

private final class MockAuthRepo: AuthRepositoryProtocol {
    var currentUser: User?
    
    func signIn(email: String, password: String) async throws -> User { fatalError() }
    func signUp(email: String, password: String) async throws -> User { fatalError() }
    func signInWithGoogle() async throws -> User { fatalError() }
    func signOut() throws {}
    func getCurrentUser() -> User? { currentUser }
    func updateProfile(displayName: String?) async throws -> User { fatalError() }
}
