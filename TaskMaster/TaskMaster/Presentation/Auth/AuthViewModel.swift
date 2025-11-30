//
//  AuthViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import Observation
import FirebaseAuth

@MainActor
@Observable
final class AuthViewModel {
    
    // MARK: - Properties
    
    var email = ""
    var password = ""
    var confirmPassword = ""
    var isSignUpMode = true
    var isLoading = false
    var errorMessage: String?
    var currentUser: User?
    
    // MARK: - Dependencies
    
    private let authRepository: AuthRepositoryProtocol
    
    // MARK: - Init
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    // MARK: - Validation
    
    var isFormValid: Bool {
        !email.isEmpty && password.count >= 6 && (isSignUpMode ? password == confirmPassword : true)
    }
    
    // MARK: - Actions
    
    func submit() async {
        guard isFormValid else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            if isSignUpMode {
                currentUser = try await authRepository.signUp(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
            } else {
                currentUser = try await authRepository.signIn(
                    email: email.trimmingCharacters(in: .whitespaces),
                    password: password
                )
            }
        } catch {
            errorMessage = parseFirebaseError(error)
        }
        
        isLoading = false
    }
    
    func signInWithGoogle() async {
        isLoading = true
        errorMessage = nil
        
        do {
            currentUser = try await authRepository.signInWithGoogle()
        } catch {
            errorMessage = parseFirebaseError(error)
        }
        
        isLoading = false
    }
    
    func toggleMode() {
        isSignUpMode.toggle()
        confirmPassword = ""
        errorMessage = nil
    }
    
    func clearError() {
        errorMessage = nil
    }
    
    // MARK: - Error Handling
    
    private func parseFirebaseError(_ error: Error) -> String {
        let nsError = error as NSError
        guard nsError.domain == AuthErrorDomain,
              let errorCode = AuthErrorCode(rawValue: nsError.code) else {
            return error.localizedDescription
        }
        
        switch errorCode {
        case .emailAlreadyInUse: return "Email already registered. Try signing in."
        case .invalidEmail: return "Invalid email address."
        case .weakPassword: return "Password must be at least 6 characters."
        case .wrongPassword: return "Incorrect password."
        case .userNotFound: return "No account found with this email."
        case .networkError: return "Network error. Check your connection."
        case .tooManyRequests: return "Too many attempts. Try again later."
        case .operationNotAllowed: return "Email/Password not enabled in Firebase Console."
        case .internalError: return "Server error. Enable Email/Password in Firebase Console."
        default: return error.localizedDescription
        }
    }
}
