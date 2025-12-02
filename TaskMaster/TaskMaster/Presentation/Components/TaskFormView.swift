//
//  TaskFormView.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

/// Reusable form view for creating/editing tasks
struct TaskFormView: View {
    
    @Binding var title: String
    @Binding var description: String
    @Binding var priority: Priority
    @Binding var dueDate: Date?
    @Binding var hasDueDate: Bool
    @Binding var categoryId: UUID?
    
    var categories: [Category] = []
    
    var body: some View {
        Form {
            titleSection
            detailsSection
            categorySection
            prioritySection
            dueDateSection
        }
    }
    
    // MARK: - Title Section
    
    private var titleSection: some View {
        Section {
            TextField("Task title", text: $title)
        }
    }
    
    // MARK: - Details Section
    
    private var detailsSection: some View {
        Section("Details") {
            TextField("Description (optional)", text: $description, axis: .vertical)
                .lineLimit(3...6)
        }
    }
    
    // MARK: - Category Section
    
    private var categorySection: some View {
        Section("Category") {
            Picker("Category", selection: validatedCategoryBinding) {
                Text("None").tag(nil as UUID?)
                ForEach(categories) { category in
                    Label(category.name, systemImage: category.icon)
                        .tag(category.id as UUID?)
                }
            }
        }
    }
    
    /// Binding that validates categoryId against available categories
    private var validatedCategoryBinding: Binding<UUID?> {
        Binding(
            get: {
                // Return nil if selected category doesn't exist in the list
                guard let id = categoryId else { return nil }
                return categories.contains { $0.id == id } ? id : nil
            },
            set: { categoryId = $0 }
        )
    }
    
    // MARK: - Priority Section
    
    private var prioritySection: some View {
        Section("Priority") {
            Picker("Priority", selection: $priority) {
                ForEach(Priority.allCases, id: \.self) { p in
                    Text(p.displayName).tag(p)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Due Date Section
    
    private var dueDateSection: some View {
        Section {
            Toggle("Set due date", isOn: $hasDueDate.animation())
            
            if hasDueDate {
                DatePicker(
                    "Due date",
                    selection: Binding(
                        get: { dueDate ?? Date() },
                        set: { dueDate = $0 }
                    ),
                    displayedComponents: [.date, .hourAndMinute]
                )
            }
        }
    }
}
