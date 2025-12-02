//
//  CreateTaskScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct CreateTaskScreen: View {
    
    @State private var viewModel: CreateTaskViewModel
    @Environment(\.dismiss) private var dismiss
    var onTaskCreated: ((Task) -> Void)?
    
    init(viewModel: CreateTaskViewModel, onTaskCreated: ((Task) -> Void)? = nil) {
        _viewModel = State(wrappedValue: viewModel)
        self.onTaskCreated = onTaskCreated
    }
    
    var body: some View {
        NavigationStack {
            TaskFormView(
                title: $viewModel.title,
                description: $viewModel.description,
                priority: $viewModel.priority,
                dueDate: $viewModel.dueDate,
                hasDueDate: $viewModel.hasDueDate,
                categoryId: $viewModel.categoryId,
                categories: viewModel.categories
            )
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            _Concurrency.Task { await viewModel.createTask() }
                        }
                        .disabled(!viewModel.isFormValid)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.createdTask) { _, task in
                if let task {
                    onTaskCreated?(task)
                    dismiss()
                }
            }
            .task {
                await viewModel.loadCategories()
            }
        }
    }
}

#Preview {
    CreateTaskScreen(
        viewModel: CreateTaskViewModel(
            createTaskUseCase: PreviewCreateTaskUseCase()
        )
    )
}

// MARK: - Preview Helper

@MainActor
private final class PreviewCreateTaskUseCase: CreateTaskUseCaseProtocol {
    func execute(_ task: Task) async throws -> Task { task }
}
