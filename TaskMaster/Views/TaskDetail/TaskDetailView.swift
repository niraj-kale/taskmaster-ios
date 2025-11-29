//
//  TaskDetailView.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

struct TaskDetailView: View {
    @StateObject private var viewModel: TaskDetailViewModel
    @Environment(\.dismiss) private var dismiss
    
    let categories: [TaskCategory]
    
    init(task: TaskItem? = nil, categories: [TaskCategory]) {
        self.categories = categories
        _viewModel = StateObject(wrappedValue: TaskDetailViewModel(task: task))
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Title Section
                titleSection
                
                // Details Section
                detailsSection
                
                // Category Section
                categorySection
                
                // Due Date Section
                dueDateSection
                
                // Delete Section (only for editing)
                if viewModel.isEditing {
                    deleteSection
                }
            }
            .navigationTitle(viewModel.isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await viewModel.save()
                        }
                    }
                    .disabled(!viewModel.isFormValid || viewModel.isLoading)
                }
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.isSaved) { _, isSaved in
                if isSaved {
                    dismiss()
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                }
            }
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        Section {
            TextField("Task title", text: $viewModel.title)
                .font(.body)
            
            TextField("Description (optional)", text: $viewModel.description, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Task")
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        Section {
            // Priority Picker
            Picker("Priority", selection: $viewModel.priority) {
                ForEach(TaskPriority.allCases, id: \.self) { priority in
                    HStack {
                        Image(systemName: "flag.fill")
                            .foregroundStyle(priorityColor(for: priority))
                        Text(priority.displayName)
                    }
                    .tag(priority)
                }
            }
            
            // Status Picker
            Picker("Status", selection: $viewModel.status) {
                ForEach(TaskStatus.allCases, id: \.self) { status in
                    Text(status.displayName)
                        .tag(status)
                }
            }
        } header: {
            Text("Details")
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        Section {
            Picker("Category", selection: $viewModel.selectedCategoryId) {
                Text("None")
                    .tag(nil as String?)
                
                ForEach(categories) { category in
                    HStack {
                        Circle()
                            .fill(category.color)
                            .frame(width: 12, height: 12)
                        Text(category.name)
                    }
                    .tag(category.id as String?)
                }
            }
        } header: {
            Text("Category")
        }
    }
    
    // MARK: - Due Date Section
    
    private var dueDateSection: some View {
        Section {
            Toggle("Set Due Date", isOn: $viewModel.hasDueDate)
                .onChange(of: viewModel.hasDueDate) { _, _ in
                    viewModel.toggleDueDate()
                }
            
            if viewModel.hasDueDate {
                DatePicker(
                    "Due Date",
                    selection: Binding(
                        get: { viewModel.dueDate ?? Date() },
                        set: { viewModel.dueDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        } header: {
            Text("Due Date")
        }
    }
    
    // MARK: - Delete Section
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                Task {
                    await viewModel.delete()
                }
            } label: {
                HStack {
                    Spacer()
                    Label("Delete Task", systemImage: "trash")
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func priorityColor(for priority: TaskPriority) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
}

#Preview {
    TaskDetailView(categories: [])
}
