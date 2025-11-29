//
//  ContentView.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

struct ContentView: View {
    @StateObject private var authService = AuthenticationService.shared
    
    var body: some View {
        Group {
            if authService.isAuthenticated {
                TaskListView()
            } else {
                AuthenticationView()
            }
        }
        .animation(.easeInOut, value: authService.isAuthenticated)
    }
}

#Preview {
    ContentView()
}
