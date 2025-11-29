//
//  SettingsViewModel.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var displayName: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showDeleteConfirmation: Bool = false
    
    // MARK: - Properties
    
    private let authService: AuthenticationService
    private let firestoreService: FirestoreServiceProtocol
    
    var currentUser: User? {
        authService.currentUser
    }
    
    var userEmail: String {
        currentUser?.email ?? ""
    }
    
    var userDisplayName: String {
        currentUser?.displayName ?? ""
    }
    
    var memberSince: String {
        guard let createdAt = currentUser?.createdAt else { return "" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: createdAt)
    }
    
    // MARK: - Initialization
    
    init(
        authService: AuthenticationService = .shared,
        firestoreService: FirestoreServiceProtocol = FirestoreService.shared
    ) {
        self.authService = authService
        self.firestoreService = firestoreService
        
        if let name = authService.currentUser?.displayName {
            displayName = name
        }
    }
    
    // MARK: - Actions
    
    func updateProfile() async {
        guard !displayName.isEmpty else {
            errorMessage = "Display name cannot be empty."
            return
        }
        
        isLoading = true
        errorMessage = nil
        successMessage = nil
        
        do {
            _ = try await authService.updateProfile(
                displayName: displayName,
                photoURL: nil
            )
            successMessage = "Profile updated successfully."
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func signOut() {
        do {
            try authService.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func deleteAccount() async {
        isLoading = true
        errorMessage = nil
        
        do {
            try await authService.deleteAccount()
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}
