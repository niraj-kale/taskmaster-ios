//
//  GetCurrentUserUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol GetCurrentUserUseCaseProtocol {
    func execute() -> User?
}

final class GetCurrentUserUseCase: GetCurrentUserUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute() -> User? {
        authRepository.getCurrentUser()
    }
}
