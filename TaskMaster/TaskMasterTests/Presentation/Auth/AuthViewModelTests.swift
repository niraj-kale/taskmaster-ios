//
//  AuthViewModelTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 30/11/25.
//

import Testing
@testable import TaskMaster

@MainActor
struct AuthViewModelTests {
    
    // MARK: - Form Validation
    
    @Test func isFormValid_signUpMode_withEmptyFields_returnsFalse() {
        let viewModel = AuthViewModel(authRepository: MockAuthRepository())
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func isFormValid_signUpMode_withValidInputs_returnsTrue() {
        let viewModel = AuthViewModel(authRepository: MockAuthRepository())
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        #expect(viewModel.isFormValid == true)
    }
    
    @Test func isFormValid_signUpMode_withMismatchedPasswords_returnsFalse() {
        let viewModel = AuthViewModel(authRepository: MockAuthRepository())
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "different"
        #expect(viewModel.isFormValid == false)
    }
    
    @Test func isFormValid_signInMode_withoutConfirmPassword_returnsTrue() {
        let viewModel = AuthViewModel(authRepository: MockAuthRepository())
        viewModel.isSignUpMode = false
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        // No confirmPassword needed for sign in
        #expect(viewModel.isFormValid == true)
    }
    
    // MARK: - Sign Up
    
    @Test func submit_signUpMode_success() async {
        let mock = MockAuthRepository()
        let expectedUser = User(id: "123", email: "test@example.com")
        mock.signUpResult = .success(expectedUser)
        
        let viewModel = AuthViewModel(authRepository: mock)
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        viewModel.confirmPassword = "password123"
        
        await viewModel.submit()
        
        #expect(viewModel.currentUser?.email == expectedUser.email)
        #expect(viewModel.errorMessage == nil)
    }
    
    // MARK: - Sign In
    
    @Test func submit_signInMode_success() async {
        let mock = MockAuthRepository()
        let expectedUser = User(id: "456", email: "test@example.com")
        mock.signInResult = .success(expectedUser)
        
        let viewModel = AuthViewModel(authRepository: mock)
        viewModel.isSignUpMode = false
        viewModel.email = "test@example.com"
        viewModel.password = "password123"
        
        await viewModel.submit()
        
        #expect(viewModel.currentUser?.email == expectedUser.email)
        #expect(viewModel.errorMessage == nil)
    }
    
    @Test func submit_signInMode_failure() async {
        let mock = MockAuthRepository()
        mock.signInResult = .failure(NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid credentials"]))
        
        let viewModel = AuthViewModel(authRepository: mock)
        viewModel.isSignUpMode = false
        viewModel.email = "test@example.com"
        viewModel.password = "wrongpassword"
        
        await viewModel.submit()
        
        #expect(viewModel.currentUser == nil)
        #expect(viewModel.errorMessage != nil)
    }
    
    // MARK: - Google Sign-In
    
    @Test func signInWithGoogle_success() async {
        let mock = MockAuthRepository()
        let expectedUser = User(id: "789", email: "google@gmail.com")
        mock.googleSignInResult = .success(expectedUser)
        
        let viewModel = AuthViewModel(authRepository: mock)
        await viewModel.signInWithGoogle()
        
        #expect(viewModel.currentUser?.email == expectedUser.email)
    }
    
    // MARK: - Mode Toggle
    
    @Test func toggleMode_switchesBetweenModes() {
        let viewModel = AuthViewModel(authRepository: MockAuthRepository())
        #expect(viewModel.isSignUpMode == true)
        
        viewModel.toggleMode()
        #expect(viewModel.isSignUpMode == false)
        
        viewModel.toggleMode()
        #expect(viewModel.isSignUpMode == true)
    }
}

// MARK: - Mock

@MainActor
final class MockAuthRepository: AuthRepositoryProtocol {
    var signUpResult: Result<User, Error> = .success(User(email: ""))
    var signInResult: Result<User, Error> = .success(User(email: ""))
    var googleSignInResult: Result<User, Error> = .success(User(email: ""))
    
    func signUp(email: String, password: String) async throws -> User {
        try signUpResult.get()
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try signInResult.get()
    }
    
    func signInWithGoogle() async throws -> User {
        try googleSignInResult.get()
    }
    
    func signOut() throws {}
    func getCurrentUser() -> User? { nil }
    func updateProfile(displayName: String?) async throws -> User { fatalError() }
}
