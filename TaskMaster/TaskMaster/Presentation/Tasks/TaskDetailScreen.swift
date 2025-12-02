//
//  TaskDetailScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct TaskDetailScreen: View {
    
    @State private var viewModel: TaskDetailViewModel
    @Environment(\.dismiss) private var dismiss
    var onTaskUpdated: ((Task) -> Void)?
    var onTaskDeleted: (() -> Void)?
    
    init(
        viewModel: TaskDetailViewModel,
        onTaskUpdated: ((Task) -> Void)? = nil,
        onTaskDeleted: (() -> Void)? = nil
    ) {
        _viewModel = State(wrappedValue: viewModel)
        self.onTaskUpdated = onTaskUpdated
        self.onTaskDeleted = onTaskDeleted
    }
    
    var body: some View {
        List {
            statusSection
            detailsSection
            metadataSection
            deleteSection
        }
        .navigationTitle("Task Details")
        .navigationBarTitleDisplayMode(.inline)
        .disabled(viewModel.isLoading)
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.clearError() }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .onChange(of: viewModel.task) { _, task in
            onTaskUpdated?(task)
        }
        .onChange(of: viewModel.isDeleted) { _, deleted in
            if deleted {
                onTaskDeleted?()
                dismiss()
            }
        }
        .task {
            await viewModel.loadCategory()
        }
    }
    
    // MARK: - Status Section
    
    private var statusSection: some View {
        Section {
            HStack {
                Text(viewModel.task.title)
                    .font(.headline)
                    .strikethrough(viewModel.task.isCompleted)
                
                Spacer()
                
                Button {
                    _Concurrency.Task { await viewModel.toggleCompletion() }
                } label: {
                    Image(systemName: viewModel.task.isCompleted ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundStyle(viewModel.task.isCompleted ? .green : .secondary)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        Section("Details") {
            if let description = viewModel.task.description, !description.isEmpty {
                Text(description)
                    .foregroundStyle(.secondary)
            } else {
                Text("No description")
                    .foregroundStyle(.tertiary)
                    .italic()
            }
            
            LabeledContent("Priority") {
                PriorityBadge(priority: viewModel.task.priority)
            }
            
            if let category = viewModel.category {
                LabeledContent("Category") {
                    CategoryBadge(category: category)
                }
            }
            
            if let dueDate = viewModel.task.dueDate {
                LabeledContent("Due Date") {
                    Text(dueDate, style: .date)
                        .foregroundStyle(dueDate < Date() && !viewModel.task.isCompleted ? .red : .secondary)
                }
            }
        }
    }
    
    // MARK: - Metadata Section
    
    private var metadataSection: some View {
        Section("Info") {
            LabeledContent("Created") {
                Text(viewModel.task.createdAt, style: .date)
            }
            LabeledContent("Updated") {
                Text(viewModel.task.updatedAt, style: .relative)
            }
        }
    }
    
    // MARK: - Delete Section
    
    private var deleteSection: some View {
        Section {
            Button(role: .destructive) {
                _Concurrency.Task { await viewModel.deleteTask() }
            } label: {
                HStack {
                    Spacer()
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Label("Delete Task", systemImage: "trash")
                    }
                    Spacer()
                }
            }
        }
    }
}

// MARK: - Priority Badge (Reusable)

struct PriorityBadge: View {
    let priority: Priority
    
    var body: some View {
        Text(priority.displayName)
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
    
    private var color: Color {
        switch priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Category Badge (Reusable)

struct CategoryBadge: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: category.icon)
            Text(category.name)
        }
        .font(.caption)
        .fontWeight(.medium)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
    
    private var color: Color {
        Color(hex: category.color) ?? .gray
    }
}

// MARK: - Color Extension

private extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else { return nil }
        
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    NavigationStack {
        TaskDetailScreen(
            viewModel: TaskDetailViewModel(
                task: Task(
                    title: "Sample Task",
                    description: "This is a sample task description",
                    priority: .high,
                    dueDate: Date()
                ),
                taskRepository: PreviewTaskRepository()
            )
        )
    }
}

// MARK: - Preview Helper

@MainActor
private final class PreviewTaskRepository: TaskRepositoryProtocol {
    func getTasks() async throws -> [Task] { [] }
    func getTask(id: UUID) async throws -> Task? { nil }
    func createTask(_ task: Task) async throws -> Task { task }
    func updateTask(_ task: Task) async throws -> Task { task }
    func deleteTask(id: UUID) async throws {}
    func searchTasks(query: String) async throws -> [Task] { [] }
}
