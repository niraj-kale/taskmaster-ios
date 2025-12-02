//
//  SignOutUseCase.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol SignOutUseCaseProtocol {
    func execute() throws
}

final class SignOutUseCase: SignOutUseCaseProtocol {
    
    private let authRepository: AuthRepositoryProtocol
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func execute() throws {
        try authRepository.signOut()
    }
}
