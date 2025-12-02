//
//  EditTaskScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct EditTaskScreen: View {
    
    @State private var viewModel: EditTaskViewModel
    @Environment(\.dismiss) private var dismiss
    var onTaskUpdated: ((Task) -> Void)?
    
    init(viewModel: EditTaskViewModel, onTaskUpdated: ((Task) -> Void)? = nil) {
        _viewModel = State(wrappedValue: viewModel)
        self.onTaskUpdated = onTaskUpdated
    }
    
    var body: some View {
        NavigationStack {
            TaskFormView(
                title: $viewModel.title,
                description: $viewModel.description,
                priority: $viewModel.priority,
                dueDate: $viewModel.dueDate,
                hasDueDate: $viewModel.hasDueDate
            )
            .navigationTitle("Edit Task")
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
                            _Concurrency.Task { await viewModel.updateTask() }
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
            .onChange(of: viewModel.updatedTask) { _, task in
                if let task {
                    onTaskUpdated?(task)
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    EditTaskScreen(
        viewModel: EditTaskViewModel(
            task: Task(title: "Sample Task", description: "Description", priority: .high),
            updateTaskUseCase: PreviewUpdateTaskUseCase()
        )
    )
}

// MARK: - Preview Helper

@MainActor
private final class PreviewUpdateTaskUseCase: UpdateTaskUseCaseProtocol {
    func execute(_ task: Task) async throws -> Task { task }
}
