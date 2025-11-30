//
//  AuthRepositoryProtocol.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

protocol AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User
    func signUp(email: String, password: String) async throws -> User
    func signOut() async throws -> Bool
    func getCurrentUser() async throws -> User?
    func signInWithGoogle() async throws -> User
}
