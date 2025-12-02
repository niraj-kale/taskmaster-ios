//
//  AuthScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct AuthScreen: View {
    
    @State private var viewModel: AuthViewModel
    var onSuccess: ((User) -> Void)?
    
    init(viewModel: AuthViewModel, onSuccess: ((User) -> Void)? = nil) {
        _viewModel = State(wrappedValue: viewModel)
        self.onSuccess = onSuccess
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                AppLogo(
                    size: .medium,
                    subtitle: viewModel.isSignUpMode ? "Create your account" : "Welcome back"
                )
                .padding(.top, 40)
                
                emailPasswordForm
                divider
                googleSignInButton
                modeToggle
            }
            .padding(24)
        }
        .disabled(viewModel.isLoading)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.currentUser) { _, user in
            if let user { onSuccess?(user) }
        }
    }
    
    // MARK: - Form
    
    private var emailPasswordForm: some View {
        VStack(spacing: 16) {
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(.roundedBorder)
                .textContentType(.emailAddress)
                .textInputAutocapitalization(.never)
                .keyboardType(.emailAddress)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(.roundedBorder)
                .textContentType(viewModel.isSignUpMode ? .newPassword : .password)
            
            if viewModel.isSignUpMode {
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textFieldStyle(.roundedBorder)
            }
            
            Button {
                _Concurrency.Task { await viewModel.submit() }
            } label: {
                Group {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Text(viewModel.isSignUpMode ? "Sign Up" : "Sign In")
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 44)
            }
            .buttonStyle(.borderedProminent)
            .disabled(!viewModel.isFormValid)
        }
    }
    
    // MARK: - Divider
    
    private var divider: some View {
        HStack {
            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
            Text("or").foregroundStyle(.secondary)
            Rectangle().frame(height: 1).foregroundStyle(.secondary.opacity(0.3))
        }
    }
    
    // MARK: - Google
    
    private var googleSignInButton: some View {
        Button {
            _Concurrency.Task { await viewModel.signInWithGoogle() }
        } label: {
            HStack {
                Image(systemName: "g.circle.fill")
                Text("Continue with Google")
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
        }
        .buttonStyle(.bordered)
    }
    
    // MARK: - Mode Toggle
    
    private var modeToggle: some View {
        HStack(spacing: 4) {
            Text(viewModel.isSignUpMode ? "Already have an account?" : "Don't have an account?")
                .foregroundStyle(.secondary)
            Button(viewModel.isSignUpMode ? "Sign In" : "Sign Up") {
                withAnimation { viewModel.toggleMode() }
            }
            .fontWeight(.semibold)
        }
        .font(.subheadline)
    }
}

#Preview("Sign Up") {
    AuthScreen(viewModel: AuthViewModel(authRepository: PreviewAuthRepository()))
}

#Preview("Sign In") {
    let vm = AuthViewModel(authRepository: PreviewAuthRepository())
    vm.isSignUpMode = false
    return AuthScreen(viewModel: vm)
}

// MARK: - Preview Helper

@MainActor
private final class PreviewAuthRepository: AuthRepositoryProtocol {
    func signIn(email: String, password: String) async throws -> User { User(email: email) }
    func signUp(email: String, password: String) async throws -> User { User(email: email) }
    func signInWithGoogle() async throws -> User { User(email: "test@gmail.com") }
    func signOut() throws {}
    func getCurrentUser() -> User? { nil }
}
