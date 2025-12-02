//
//  ProfileScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct ProfileScreen: View {
    
    @State private var viewModel: ProfileViewModel
    let onSignOut: () -> Void
    
    init(viewModel: ProfileViewModel, onSignOut: @escaping () -> Void) {
        _viewModel = State(wrappedValue: viewModel)
        self.onSignOut = onSignOut
    }
    
    var body: some View {
        Form {
            Section("Account") {
                LabeledContent("Email", value: viewModel.user?.email ?? "-")
                LabeledContent("Member since", value: formattedDate)
            }
            
            Section("Display Name") {
                TextField("Enter your name", text: $viewModel.displayName)
            }
            
            Section {
                Button {
                    _Concurrency.Task { await viewModel.saveProfile() }
                } label: {
                    HStack {
                        Text("Save Changes")
                        Spacer()
                        if viewModel.isLoading {
                            ProgressView()
                        }
                    }
                }
                .disabled(viewModel.isLoading)
            }
            
            Section {
                Button("Sign Out", role: .destructive, action: onSignOut)
            }
        }
        .navigationTitle("Profile")
        .onAppear { viewModel.loadUser() }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .alert("Success", isPresented: $viewModel.isSaved) {
            Button("OK") {}
        } message: {
            Text("Profile updated successfully")
        }
    }
    
    private var formattedDate: String {
        guard let date = viewModel.user?.createdAt else { return "-" }
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}

