//
//  AuthenticationView.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

struct AuthenticationView: View {
    @StateObject private var viewModel = AuthenticationViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Logo and Title
                    headerView
                    
                    // Auth Form
                    authFormView
                    
                    // Social Sign-In
                    socialSignInView
                    
                    // Toggle Auth Mode
                    toggleModeButton
                }
                .padding()
            }
            .navigationBarHidden(true)
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .sheet(isPresented: $viewModel.showResetPassword) {
                resetPasswordSheet
            }
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.blue)
            
            Text("TaskMaster")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text(viewModel.authMode == .signIn ? "Welcome back!" : "Create an account")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 40)
    }
    
    // MARK: - Auth Form View
    
    private var authFormView: some View {
        VStack(spacing: 16) {
            if viewModel.authMode == .signUp {
                TextField("Display Name", text: $viewModel.displayName)
                    .textFieldStyle(AuthTextFieldStyle())
                    .textContentType(.name)
                    .autocapitalization(.words)
            }
            
            TextField("Email", text: $viewModel.email)
                .textFieldStyle(AuthTextFieldStyle())
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $viewModel.password)
                .textFieldStyle(AuthTextFieldStyle())
                .textContentType(viewModel.authMode == .signIn ? .password : .newPassword)
            
            if viewModel.authMode == .signUp {
                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                    .textFieldStyle(AuthTextFieldStyle())
                    .textContentType(.newPassword)
            }
            
            if viewModel.authMode == .signIn {
                HStack {
                    Spacer()
                    Button("Forgot Password?") {
                        viewModel.resetEmail = viewModel.email
                        viewModel.showResetPassword = true
                    }
                    .font(.footnote)
                    .foregroundStyle(.blue)
                }
            }
            
            Button {
                Task {
                    if viewModel.authMode == .signIn {
                        await viewModel.signIn()
                    } else {
                        await viewModel.signUp()
                    }
                }
            } label: {
                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(viewModel.authMode == .signIn ? "Sign In" : "Sign Up")
                }
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
        }
    }
    
    // MARK: - Social Sign-In View
    
    private var socialSignInView: some View {
        VStack(spacing: 16) {
            HStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                
                Text("or")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
            
            Button {
                Task {
                    await viewModel.signInWithGoogle()
                }
            } label: {
                HStack {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("Continue with Google")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .disabled(viewModel.isLoading)
        }
    }
    
    // MARK: - Toggle Mode Button
    
    private var toggleModeButton: some View {
        HStack {
            Text(viewModel.authMode == .signIn ? "Don't have an account?" : "Already have an account?")
                .foregroundStyle(.secondary)
            
            Button(viewModel.authMode == .signIn ? "Sign Up" : "Sign In") {
                viewModel.toggleAuthMode()
            }
            .fontWeight(.semibold)
            .foregroundStyle(.blue)
        }
        .font(.footnote)
        .padding(.top, 8)
    }
    
    // MARK: - Reset Password Sheet
    
    private var resetPasswordSheet: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("Reset Password")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                
                TextField("Email", text: $viewModel.resetEmail)
                    .textFieldStyle(AuthTextFieldStyle())
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                
                Button {
                    Task {
                        await viewModel.resetPassword()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("Send Reset Link")
                    }
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(viewModel.resetEmail.isEmpty || viewModel.isLoading)
                
                if viewModel.resetPasswordSent {
                    Text("Password reset email sent!")
                        .font(.footnote)
                        .foregroundStyle(.green)
                }
                
                Spacer()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        viewModel.showResetPassword = false
                        viewModel.resetPasswordSent = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }
}

// MARK: - Custom Styles

struct AuthTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray6))
            .foregroundColor(.primary)
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

#Preview {
    AuthenticationView()
}
