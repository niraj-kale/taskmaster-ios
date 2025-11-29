//
//  AuthenticationViewModel.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation
import Combine

/// Authentication view model states
enum AuthViewState {
    case idle
    case loading
    case authenticated
    case unauthenticated
    case error(String)
}

/// Authentication mode
enum AuthMode {
    case signIn
    case signUp
}

@MainActor
final class AuthenticationViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    @Published var displayName: String = ""
    @Published var authMode: AuthMode = .signIn
    @Published var viewState: AuthViewState = .idle
    @Published var errorMessage: String?
    @Published var showResetPassword: Bool = false
    @Published var resetEmail: String = ""
    @Published var resetPasswordSent: Bool = false
    
    // MARK: - Dependencies
    
    private let authService: AuthenticationServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Computed Properties
    
    var isFormValid: Bool {
        switch authMode {
        case .signIn:
            return !email.isEmpty && !password.isEmpty
        case .signUp:
            return !email.isEmpty && !password.isEmpty && password == confirmPassword
        }
    }
    
    var isLoading: Bool {
        if case .loading = viewState {
            return true
        }
        return false
    }
    
    var currentUser: User? {
        (authService as? AuthenticationService)?.currentUser
    }
    
    // MARK: - Initialization
    
    init(authService: AuthenticationServiceProtocol = AuthenticationService.shared) {
        self.authService = authService
        
        // Observe authentication state
        if let service = authService as? AuthenticationService {
            service.$isAuthenticated
                .receive(on: DispatchQueue.main)
                .sink { [weak self] isAuthenticated in
                    self?.viewState = isAuthenticated ? .authenticated : .unauthenticated
                }
                .store(in: &cancellables)
        }
    }
    
    // MARK: - Actions
    
    func signIn() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields."
            return
        }
        
        viewState = .loading
        errorMessage = nil
        
        do {
            _ = try await authService.signIn(email: email, password: password)
            viewState = .authenticated
            clearForm()
        } catch let error as AuthError {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        } catch {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func signUp() async {
        guard isFormValid else {
            errorMessage = "Please fill in all fields correctly."
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            return
        }
        
        viewState = .loading
        errorMessage = nil
        
        do {
            _ = try await authService.signUp(
                email: email,
                password: password,
                displayName: displayName.isEmpty ? nil : displayName
            )
            viewState = .authenticated
            clearForm()
        } catch let error as AuthError {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        } catch {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func signInWithGoogle() async {
        viewState = .loading
        errorMessage = nil
        
        do {
            _ = try await authService.signInWithGoogle(presenting: nil)
            viewState = .authenticated
        } catch let error as AuthError {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        } catch {
            viewState = .error(error.localizedDescription)
            errorMessage = error.localizedDescription
        }
    }
    
    func resetPassword() async {
        guard !resetEmail.isEmpty else {
            errorMessage = "Please enter your email address."
            return
        }
        
        viewState = .loading
        errorMessage = nil
        
        do {
            try await authService.resetPassword(email: resetEmail)
            resetPasswordSent = true
            resetEmail = ""
        } catch let error as AuthError {
            errorMessage = error.localizedDescription
        } catch {
            errorMessage = error.localizedDescription
        }
        
        viewState = .idle
    }
    
    func signOut() {
        do {
            try authService.signOut()
            viewState = .unauthenticated
            clearForm()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func toggleAuthMode() {
        authMode = authMode == .signIn ? .signUp : .signIn
        clearForm()
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    private func clearForm() {
        email = ""
        password = ""
        confirmPassword = ""
        displayName = ""
        errorMessage = nil
    }
}
