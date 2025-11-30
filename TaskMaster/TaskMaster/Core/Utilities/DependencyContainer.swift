//
//  DependencyContainer.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Repositories
    
    lazy var authRepository: AuthRepositoryProtocol = AuthRepository()
    
    // MARK: - View Models
    
    @MainActor
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authRepository: authRepository)
    }
}
