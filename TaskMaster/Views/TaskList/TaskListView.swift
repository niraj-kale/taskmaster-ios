//
//  TaskListView.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

struct TaskListView: View {
    @StateObject private var viewModel = TaskListViewModel()
    @State private var showingAddTask = false
    @State private var showingFilters = false
    @State private var selectedTask: TaskItem?
    
    var body: some View {
        NavigationStack {
            ZStack {
                if viewModel.isLoading && viewModel.tasks.isEmpty {
                    ProgressView("Loading tasks...")
                } else if viewModel.filteredTasks.isEmpty {
                    emptyStateView
                } else {
                    taskListContent
                }
            }
            .navigationTitle("Tasks")
            .searchable(text: $viewModel.searchText, prompt: "Search tasks")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingFilters.toggle()
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle")
                            .symbolVariant(hasActiveFilters ? .fill : .none)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                TaskDetailView(categories: viewModel.categories)
            }
            .sheet(item: $selectedTask) { task in
                TaskDetailView(task: task, categories: viewModel.categories)
            }
            .sheet(isPresented: $showingFilters) {
                filterSheet
            }
            .overlay(alignment: .bottomTrailing) {
                addTaskButton
            }
            .alert("Error", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.clearError() } }
            )) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .onAppear {
            viewModel.startObserving()
        }
        .onDisappear {
            viewModel.stopObserving()
        }
    }
    
    // MARK: - Computed Properties
    
    private var hasActiveFilters: Bool {
        viewModel.selectedFilter != .all || viewModel.selectedCategoryId != nil
    }
    
    // MARK: - Task List Content
    
    private var taskListContent: some View {
        List {
            // Stats Section
            statsSection
            
            // Tasks Section
            ForEach(viewModel.filteredTasks) { task in
                TaskRowView(
                    task: task,
                    categoryName: viewModel.getCategoryName(for: task.categoryId),
                    categoryColor: viewModel.getCategory(for: task.categoryId)?.color
                )
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedTask = task
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteTask(task)
                        }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    Button {
                        Task {
                            await viewModel.toggleTaskCompletion(task)
                        }
                    } label: {
                        Label(
                            task.status == .completed ? "Reopen" : "Complete",
                            systemImage: task.status == .completed ? "arrow.uturn.left" : "checkmark"
                        )
                    }
                    .tint(task.status == .completed ? .orange : .green)
                }
            }
        }
        .listStyle(.insetGrouped)
        .refreshable {
            await viewModel.loadTasks()
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        Section {
            HStack(spacing: 20) {
                StatCard(
                    title: "Pending",
                    count: viewModel.pendingTasksCount,
                    color: .orange
                )
                
                StatCard(
                    title: "Completed",
                    count: viewModel.completedTasksCount,
                    color: .green
                )
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets())
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checklist")
                .resizable()
                .scaledToFit()
                .frame(width: 80, height: 80)
                .foregroundStyle(.secondary)
            
            Text("No tasks yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Tap the + button to create your first task")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Add Task Button
    
    private var addTaskButton: some View {
        Button {
            showingAddTask = true
        } label: {
            Image(systemName: "plus")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .frame(width: 56, height: 56)
                .background(Color.blue)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
        .padding()
    }
    
    // MARK: - Filter Sheet
    
    private var filterSheet: some View {
        NavigationStack {
            Form {
                Section("Status Filter") {
                    ForEach(TaskFilter.allCases, id: \.self) { filter in
                        Button {
                            viewModel.selectedFilter = filter
                        } label: {
                            HStack {
                                Text(filter.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedFilter == filter {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Category Filter") {
                    Button {
                        viewModel.selectedCategoryId = nil
                    } label: {
                        HStack {
                            Text("All Categories")
                                .foregroundColor(.primary)
                            Spacer()
                            if viewModel.selectedCategoryId == nil {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    ForEach(viewModel.categories) { category in
                        Button {
                            viewModel.selectedCategoryId = category.id
                        } label: {
                            HStack {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 12, height: 12)
                                Text(category.name)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.selectedCategoryId == category.id {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                
                Section("Sort By") {
                    ForEach(TaskSortOption.allCases, id: \.self) { option in
                        Button {
                            viewModel.sortOption = option
                        } label: {
                            HStack {
                                Text(option.rawValue)
                                    .foregroundColor(.primary)
                                Spacer()
                                if viewModel.sortOption == option {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    Toggle("Ascending Order", isOn: $viewModel.sortAscending)
                }
                
                Section {
                    Button("Reset Filters") {
                        viewModel.selectedFilter = .all
                        viewModel.selectedCategoryId = nil
                        viewModel.sortOption = .dateCreated
                        viewModel.sortAscending = false
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showingFilters = false
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let title: String
    let count: Int
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(count)")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    TaskListView()
}
