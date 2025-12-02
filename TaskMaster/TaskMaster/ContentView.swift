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
    
    var body: some View {
        TabView {
            TasksTab()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
            
            CategoriesTab()
                .tabItem {
                    Label("Categories", systemImage: "folder")
                }
            
            ProfileTab(onSignOut: onSignOut)
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

// MARK: - Tasks Tab

private struct TasksTab: View {
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
            .navigationDestination(item: $selectedTask) { task in
                TaskDetailScreen(
                    viewModel: DependencyContainer.shared.makeTaskDetailViewModel(task: task),
                    onTaskUpdated: { updated in
                        if let index = taskListViewModel.tasks.firstIndex(where: { $0.id == updated.id }) {
                            taskListViewModel.tasks[index] = updated
                        }
                    },
                    onTaskDeleted: {
                        selectedTask = nil
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
                        _Concurrency.Task { await taskListViewModel.loadTasks() }
                    }
                )
            }
            .sheet(item: $taskToEdit) { task in
                EditTaskScreen(
                    viewModel: DependencyContainer.shared.makeEditTaskViewModel(task: task),
                    onTaskUpdated: { updated in
                        selectedTask = updated
                        if let index = taskListViewModel.tasks.firstIndex(where: { $0.id == updated.id }) {
                            taskListViewModel.tasks[index] = updated
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Categories Tab

private struct CategoriesTab: View {
    @State private var categoryListViewModel = DependencyContainer.shared.makeCategoryListViewModel()
    @State private var showCreateCategory = false
    
    var body: some View {
        NavigationStack {
            CategoryListScreen(
                viewModel: categoryListViewModel,
                onCategoryTap: nil
            )
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCreateCategory = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showCreateCategory) {
                CreateCategorySheet(
                    viewModel: DependencyContainer.shared.makeCreateCategoryViewModel(),
                    onCategoryCreated: { _ in
                        _Concurrency.Task { await categoryListViewModel.loadCategories() }
                    }
                )
            }
        }
    }
}

// MARK: - Profile Tab

private struct ProfileTab: View {
    let onSignOut: () -> Void
    
    var body: some View {
        NavigationStack {
            ProfileScreen(
                viewModel: DependencyContainer.shared.makeProfileViewModel(),
                onSignOut: onSignOut
            )
        }
    }
}

#Preview {
    ContentView()
}
