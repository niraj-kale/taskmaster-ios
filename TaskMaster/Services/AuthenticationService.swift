//
//  AuthenticationService.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation
import FirebaseAuth
import GoogleSignIn
import FirebaseCore

/// Authentication errors
enum AuthError: LocalizedError {
    case invalidEmail
    case weakPassword
    case emailAlreadyInUse
    case invalidCredentials
    case userNotFound
    case networkError
    case googleSignInFailed
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .invalidEmail:
            return "Please enter a valid email address."
        case .weakPassword:
            return "Password must be at least 6 characters long."
        case .emailAlreadyInUse:
            return "An account with this email already exists."
        case .invalidCredentials:
            return "Invalid email or password."
        case .userNotFound:
            return "No account found with this email."
        case .networkError:
            return "Network error. Please check your connection."
        case .googleSignInFailed:
            return "Google Sign-In failed. Please try again."
        case .unknown(let message):
            return message
        }
    }
}

/// Result type for authentication operations
enum AuthResult {
    case success(User)
    case failure(AuthError)
}

/// Protocol for authentication service
protocol AuthenticationServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticated: Bool { get }
    
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String, displayName: String?) async throws -> User
    func signInWithGoogle(presenting: Any?) async throws -> User
    func signOut() throws
    func resetPassword(email: String) async throws
    func deleteAccount() async throws
    func updateProfile(displayName: String?, photoURL: String?) async throws -> User
}

/// Firebase Authentication Service implementation
final class AuthenticationService: ObservableObject, AuthenticationServiceProtocol {
    static let shared = AuthenticationService()
    
    @Published private(set) var currentUser: User?
    @Published private(set) var isAuthenticated: Bool = false
    
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    
    private init() {
        setupAuthStateListener()
    }
    
    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    private func setupAuthStateListener() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, firebaseUser in
            if let firebaseUser = firebaseUser {
                self?.currentUser = self?.mapFirebaseUser(firebaseUser)
                self?.isAuthenticated = true
            } else {
                self?.currentUser = nil
                self?.isAuthenticated = false
            }
        }
    }
    
    private func mapFirebaseUser(_ firebaseUser: FirebaseAuth.User) -> User {
        return User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL?.absoluteString,
            createdAt: firebaseUser.metadata.creationDate ?? Date(),
            lastLoginAt: firebaseUser.metadata.lastSignInDate ?? Date()
        )
    }
    
    func signIn(email: String, password: String) async throws -> User {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            let user = mapFirebaseUser(result.user)
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            return user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signUp(email: String, password: String, displayName: String?) async throws -> User {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            
            if let displayName = displayName {
                let changeRequest = result.user.createProfileChangeRequest()
                changeRequest.displayName = displayName
                try await changeRequest.commitChanges()
            }
            
            let user = mapFirebaseUser(result.user)
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            return user
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func signInWithGoogle(presenting: Any?) async throws -> User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.googleSignInFailed
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        guard let windowScene = await MainActor.run(body: {
            UIApplication.shared.connectedScenes.first as? UIWindowScene
        }),
        let rootViewController = await MainActor.run(body: {
            windowScene.windows.first?.rootViewController
        }) else {
            throw AuthError.googleSignInFailed
        }
        
        do {
            let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)
            
            guard let idToken = result.user.idToken?.tokenString else {
                throw AuthError.googleSignInFailed
            }
            
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken,
                accessToken: result.user.accessToken.tokenString
            )
            
            let authResult = try await Auth.auth().signIn(with: credential)
            let user = mapFirebaseUser(authResult.user)
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            return user
        } catch {
            throw AuthError.googleSignInFailed
        }
    }
    
    func signOut() throws {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            currentUser = nil
            isAuthenticated = false
        } catch {
            throw AuthError.unknown("Failed to sign out")
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func deleteAccount() async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        do {
            try await user.delete()
            currentUser = nil
            isAuthenticated = false
        } catch let error as NSError {
            throw mapAuthError(error)
        }
    }
    
    func updateProfile(displayName: String?, photoURL: String?) async throws -> User {
        guard let firebaseUser = Auth.auth().currentUser else {
            throw AuthError.userNotFound
        }
        
        let changeRequest = firebaseUser.createProfileChangeRequest()
        
        if let displayName = displayName {
            changeRequest.displayName = displayName
        }
        
        if let photoURLString = photoURL, let url = URL(string: photoURLString) {
            changeRequest.photoURL = url
        }
        
        try await changeRequest.commitChanges()
        
        let updatedUser = mapFirebaseUser(firebaseUser)
        await MainActor.run {
            self.currentUser = updatedUser
        }
        
        return updatedUser
    }
    
    private func mapAuthError(_ error: NSError) -> AuthError {
        guard let errorCode = AuthErrorCode(rawValue: error.code) else {
            return .unknown(error.localizedDescription)
        }
        
        switch errorCode {
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .wrongPassword, .invalidCredential:
            return .invalidCredentials
        case .userNotFound:
            return .userNotFound
        case .networkError:
            return .networkError
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
