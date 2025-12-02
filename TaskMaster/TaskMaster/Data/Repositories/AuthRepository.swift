//
//  AuthRepository.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import UIKit

final class AuthRepository: AuthRepositoryProtocol {
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    // MARK: - Email/Password
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return mapFirebaseUser(result.user)
    }
    
    func signUp(email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return mapFirebaseUser(result.user)
    }
    
    // MARK: - Google Sign-In
    
    @MainActor
    func signInWithGoogle() async throws -> User {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw AuthError.missingClientID
        }
        
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else {
            throw AuthError.noRootViewController
        }
        
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootVC)
        
        guard let idToken = result.user.idToken?.tokenString else {
            throw AuthError.missingToken
        }
        
        let credential = GoogleAuthProvider.credential(
            withIDToken: idToken,
            accessToken: result.user.accessToken.tokenString
        )
        
        let authResult = try await auth.signIn(with: credential)
        return mapFirebaseUser(authResult.user)
    }
    
    // MARK: - Session
    
    func signOut() throws {
        try auth.signOut()
        GIDSignIn.sharedInstance.signOut()
    }
    
    func getCurrentUser() -> User? {
        guard let user = auth.currentUser else { return nil }
        return mapFirebaseUser(user)
    }
    
    func updateProfile(displayName: String?) async throws -> User {
        guard let user = auth.currentUser else {
            throw AuthError.noCurrentUser
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
        
        // Reload to get updated data
        try await user.reload()
        return mapFirebaseUser(user)
    }
    
    // MARK: - Private
    
    private func mapFirebaseUser(_ user: FirebaseAuth.User) -> User {
        User(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName,
            photoURL: user.photoURL,
            createdAt: user.metadata.creationDate ?? Date()
        )
    }
}

// MARK: - Auth Errors

enum AuthError: LocalizedError {
    case missingClientID
    case noRootViewController
    case missingToken
    case noCurrentUser
    
    var errorDescription: String? {
        switch self {
        case .missingClientID: return "Firebase client ID not found"
        case .noRootViewController: return "Unable to present sign-in"
        case .missingToken: return "Google sign-in failed"
        case .noCurrentUser: return "No user is currently signed in"
        }
    }
}
