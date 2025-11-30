//
//  FirebaseAuthDataSource.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import FirebaseAuth

protocol FirebaseAuthDataSourceProtocol {
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User
    func signOut() throws
    func getCurrentUser() -> FirebaseAuth.User?
}

final class FirebaseAuthDataSource: FirebaseAuthDataSourceProtocol {
    
    private let auth: Auth
    
    init(auth: Auth = Auth.auth()) {
        self.auth = auth
    }
    
    func signIn(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.signIn(withEmail: email, password: password)
        return result.user
    }
    
    func signUp(email: String, password: String) async throws -> FirebaseAuth.User {
        let result = try await auth.createUser(withEmail: email, password: password)
        return result.user
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    func getCurrentUser() -> FirebaseAuth.User? {
        return auth.currentUser
    }
}

