//
//  ProfileViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class ProfileViewModel {
    
    // MARK: - Properties
    
    var displayName = ""
    var isLoading = false
    var errorMessage: String?
    var isSaved = false
    
    private(set) var user: User?
    
    // MARK: - Dependencies
    
    private let getCurrentUserUseCase: GetCurrentUserUseCaseProtocol
    private let updateProfileUseCase: UpdateProfileUseCaseProtocol
    
    // MARK: - Init
    
    init(
        getCurrentUserUseCase: GetCurrentUserUseCaseProtocol,
        updateProfileUseCase: UpdateProfileUseCaseProtocol
    ) {
        self.getCurrentUserUseCase = getCurrentUserUseCase
        self.updateProfileUseCase = updateProfileUseCase
    }
    
    // MARK: - Actions
    
    func loadUser() {
        user = getCurrentUserUseCase.execute()
        displayName = user?.displayName ?? ""
    }
    
    func saveProfile() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
            user = try await updateProfileUseCase.execute(displayName: trimmedName.isEmpty ? nil : trimmedName)
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearError() {
        errorMessage = nil
    }
}

