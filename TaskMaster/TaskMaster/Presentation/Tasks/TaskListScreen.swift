//
//  TaskListScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct TaskListScreen: View {
    
    var viewModel: TaskListViewModel
    var onCreateTask: (() -> Void)?
    var onTaskTap: ((Task) -> Void)?
    
    var body: some View {
        content
            .navigationTitle("Tasks")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        onCreateTask?()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadTasks()
            }
            .refreshable {
                await viewModel.loadTasks()
            }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.tasks.isEmpty {
            ProgressView("Loading tasks...")
        } else if viewModel.isEmpty {
            emptyState
        } else {
            taskList
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Tasks",
            systemImage: "checklist",
            description: Text("Tap + to create your first task")
        )
    }
    
    // MARK: - Task List
    
    private var taskList: some View {
        List {
            if !viewModel.pendingTasks.isEmpty {
                Section("To Do") {
                    ForEach(viewModel.pendingTasks) { task in
                        taskRow(task)
                    }
                }
            }
            
            if !viewModel.completedTasks.isEmpty {
                Section("Completed") {
                    ForEach(viewModel.completedTasks) { task in
                        taskRow(task)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Task Row
    
    private func taskRow(_ task: Task) -> some View {
        TaskCard(
            task: task,
            category: viewModel.category(for: task),
            onToggle: {
                _Concurrency.Task { await viewModel.toggleTask(task) }
            },
            onTap: {
                onTaskTap?(task)
            }
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
            Button(role: .destructive) {
                _Concurrency.Task { await viewModel.deleteTask(task) }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TaskListScreen(
            viewModel: TaskListViewModel(
                getTasksUseCase: PreviewGetTasksUseCase(),
                taskRepository: PreviewTaskRepository()
            )
        )
    }
}

// MARK: - Preview Helpers

@MainActor
private final class PreviewGetTasksUseCase: GetTasksUseCaseProtocol {
    func execute() async throws -> [Task] {
        [
            Task(title: "Buy groceries", priority: .high, dueDate: Date()),
            Task(title: "Call mom", priority: .medium),
            Task(title: "Completed task", isCompleted: true)
        ]
    }
}

@MainActor
private final class PreviewTaskRepository: TaskRepositoryProtocol {
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    func updateTask(_ task: Task) async throws -> Task { task }
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}
