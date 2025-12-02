//
//  ContentView.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct ContentView: View {
    
    enum AuthState {
        case loading
        case authenticated(User)
        case unauthenticated
    }
    
    @State private var authState: AuthState = .loading
    
    private let getCurrentUser = DependencyContainer.shared.getCurrentUserUseCase
    private let signOut = DependencyContainer.shared.signOutUseCase
    
    var body: some View {
        Group {
            switch authState {
            case .loading:
                SplashScreen()
                
            case .authenticated:
                MainTabView(onSignOut: {
                    try? signOut.execute()
                    authState = .unauthenticated
                })
                
            case .unauthenticated:
                AuthScreen(
                    viewModel: DependencyContainer.shared.makeAuthViewModel(),
                    onSuccess: { user in
                        authState = .authenticated(user)
                    }
                )
            }
        }
        .task {
            if let user = getCurrentUser.execute() {
                authState = .authenticated(user)
            } else {
                authState = .unauthenticated
            }
        }
    }
}

// MARK: - Main Tab View

private struct MainTabView: View {
    let onSignOut: () -> Void
    
    @State private var taskListViewModel = DependencyContainer.shared.makeTaskListViewModel()
    @State private var showCreateTask = false
    @State private var selectedTask: Task?
    @State private var taskToEdit: Task?
    
    var body: some View {
        NavigationStack {
            TaskListScreen(
                viewModel: taskListViewModel,
                onCreateTask: { showCreateTask = true },
                onTaskTap: { selectedTask = $0 }
            )
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Sign Out", role: .destructive, action: onSignOut)
                        .font(.subheadline)
                }
            }
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailScreen(
                    viewModel: DependencyContainer.shared.makeTaskDetailViewModel(task: task),
                    onTaskUpdated: { updated in
                        // Update task in list
                        if let index = taskListViewModel.tasks.firstIndex(where: { $0.id == updated.id }) {
                            taskListViewModel.tasks[index] = updated
                        }
                    },
                    onTaskDeleted: {
                        selectedTask = nil
                        // Reload list after deletion
                        _Concurrency.Task { await taskListViewModel.loadTasks() }
                    }
                )
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button("Edit") { taskToEdit = task }
                    }
                }
            }
            .sheet(isPresented: $showCreateTask) {
                CreateTaskScreen(
                    viewModel: DependencyContainer.shared.makeCreateTaskViewModel(),
                    onTaskCreated: { _ in
                        // Reload list after creation
                        _Concurrency.Task { await taskListViewModel.loadTasks() }
                    }
                )
            }
            .sheet(item: $taskToEdit) { task in
                EditTaskScreen(
                    viewModel: DependencyContainer.shared.makeEditTaskViewModel(task: task),
                    onTaskUpdated: { updated in
                        selectedTask = updated
                        // Update task in list
                        if let index = taskListViewModel.tasks.firstIndex(where: { $0.id == updated.id }) {
                            taskListViewModel.tasks[index] = updated
                        }
                    }
                )
            }
        }
    }
}

#Preview {
    ContentView()
}
