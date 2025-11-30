//
//  ContentView.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct ContentView: View {
    
    @State private var currentUser: User?
    
    var body: some View {
        Group {
            if let user = currentUser {
                // Logged in state
                VStack(spacing: 20) {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.green)
                    
                    Text("Welcome!")
                        .font(.title.bold())
                    
                    Text(user.displayName ?? user.email)
                        .foregroundStyle(.secondary)
                    
                    Button("Sign Out") {
                        try? DependencyContainer.shared.authRepository.signOut()
                        currentUser = nil
                    }
                    .buttonStyle(.bordered)
                }
            } else {
                // Auth screen (Sign Up / Sign In)
                AuthScreen(
                    viewModel: DependencyContainer.shared.makeAuthViewModel(),
                    onSuccess: { user in
                        currentUser = user
                    }
                )
            }
        }
        .onAppear {
            currentUser = DependencyContainer.shared.authRepository.getCurrentUser()
        }
    }
}

#Preview {
    ContentView()
}
