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
    
    // MARK: - Auth
    
    lazy var firebaseAuthDataSource: FirebaseAuthDataSourceProtocol = {
        FirebaseAuthDataSource()
    }()
    
    lazy var authRepository: AuthRepositoryProtocol = {
        AuthRepository()
    }()
}
