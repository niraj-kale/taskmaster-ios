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
    
    var body: some View {
        Form {
            titleSection
            detailsSection
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
