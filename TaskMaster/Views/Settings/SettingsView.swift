//
//  SettingsView.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Form {
            // Profile Section
            profileSection
            
            // Account Section
            accountSection
            
            // App Info Section
            appInfoSection
            
            // Sign Out Section
            signOutSection
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Delete Account", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteAccount()
                }
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone.")
        }
        .alert("Error", isPresented: .init(
            get: { viewModel.errorMessage != nil },
            set: { if !$0 { viewModel.clearMessages() } }
        )) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Success", isPresented: .init(
            get: { viewModel.successMessage != nil },
            set: { if !$0 { viewModel.clearMessages() } }
        )) {
            Button("OK") { viewModel.clearMessages() }
        } message: {
            Text(viewModel.successMessage ?? "")
        }
        .disabled(viewModel.isLoading)
        .overlay {
            if viewModel.isLoading {
                ProgressView()
            }
        }
    }
    
    // MARK: - Profile Section
    
    private var profileSection: some View {
        Section {
            HStack(spacing: 16) {
                // Avatar
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text(avatarInitials)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundStyle(.blue)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.userDisplayName.isEmpty ? "User" : viewModel.userDisplayName)
                        .font(.headline)
                    
                    Text(viewModel.userEmail)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Profile")
        }
    }
    
    // MARK: - Account Section
    
    private var accountSection: some View {
        Section {
            HStack {
                Text("Display Name")
                Spacer()
                TextField("Name", text: $viewModel.displayName)
                    .multilineTextAlignment(.trailing)
                    .foregroundStyle(.secondary)
            }
            
            Button("Update Profile") {
                Task {
                    await viewModel.updateProfile()
                }
            }
            .disabled(viewModel.displayName.isEmpty)
            
            HStack {
                Text("Member Since")
                Spacer()
                Text(viewModel.memberSince)
                    .foregroundStyle(.secondary)
            }
        } header: {
            Text("Account")
        }
    }
    
    // MARK: - App Info Section
    
    private var appInfoSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }
            
            Link(destination: URL(string: "https://github.com/niraj-kale/taskmaster-ios")!) {
                HStack {
                    Text("GitHub Repository")
                    Spacer()
                    Image(systemName: "arrow.up.right.square")
                        .foregroundStyle(.secondary)
                }
            }
        } header: {
            Text("About")
        }
    }
    
    // MARK: - Sign Out Section
    
    private var signOutSection: some View {
        Section {
            Button("Sign Out") {
                viewModel.signOut()
            }
            .foregroundStyle(.blue)
            
            Button("Delete Account") {
                viewModel.showDeleteConfirmation = true
            }
            .foregroundStyle(.red)
        }
    }
    
    // MARK: - Computed Properties
    
    private var avatarInitials: String {
        let name = viewModel.userDisplayName.isEmpty ? viewModel.userEmail : viewModel.userDisplayName
        let components = name.split(separator: " ")
        
        if components.count >= 2 {
            return String(components[0].prefix(1) + components[1].prefix(1)).uppercased()
        } else if let first = components.first {
            return String(first.prefix(2)).uppercased()
        }
        
        return "U"
    }
    
    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
