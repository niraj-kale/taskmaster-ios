//
//  UpdateProfileUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol UpdateProfileUseCaseProtocol {
    func execute(displayName: String?) async throws -> User
}

final class UpdateProfileUseCase: UpdateProfileUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute(displayName: String?) async throws -> User {
        try await authRepository.updateProfile(displayName: displayName)
    }
}

