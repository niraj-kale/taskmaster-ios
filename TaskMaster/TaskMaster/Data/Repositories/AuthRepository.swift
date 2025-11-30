//
//  AuthRepository.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import FirebaseAuth

final class AuthRepository: AuthRepositoryProtocol {
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    func signIn(email: String, password: String) async throws -> User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return mapFirebaseUser(result.user)
    }
    
    func signUp(email: String, password: String) async throws -> User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return mapFirebaseUser(result.user)
    }
    
    func signOut() async throws -> Bool {
        try auth.signOut()
        return true
    }
    
    func getCurrentUser() async throws -> User? {
        guard let firebaseUser = auth.currentUser else {
            return nil
        }
        return mapFirebaseUser(firebaseUser)
    }
    
    func signInWithGoogle() async throws -> User {
        // TODO: Implement Google Sign-In
        fatalError("Google Sign-In not yet implemented")
    }
    
    // MARK: - Private Helpers
    
    private func mapFirebaseUser(_ firebaseUser: FirebaseAuth.User) -> User {
        return User(
            id: UUID(uuidString: firebaseUser.uid) ?? UUID(),
            email: firebaseUser.email ?? "",
            displayName: firebaseUser.displayName ?? "",
            photoURL: firebaseUser.photoURL,
            createdAt: firebaseUser.metadata.creationDate ?? Date()
        )
    }
}
