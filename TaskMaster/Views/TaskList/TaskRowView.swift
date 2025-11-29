//
//  TaskRowView.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import SwiftUI

struct TaskRowView: View {
    let task: TaskItem
    let categoryName: String?
    let categoryColor: Color?
    
    var body: some View {
        HStack(spacing: 12) {
            // Status indicator
            statusIndicator
            
            // Task content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .strikethrough(task.status == .completed)
                    .foregroundStyle(task.status == .completed ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    // Priority badge
                    priorityBadge
                    
                    // Category badge
                    if let categoryName = categoryName {
                        categoryBadge(name: categoryName)
                    }
                    
                    // Due date
                    if let dueDate = task.dueDate {
                        dueDateBadge(date: dueDate)
                    }
                }
            }
            
            Spacer()
            
            // Chevron
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Status Indicator
    
    private var statusIndicator: some View {
        Image(systemName: task.status == .completed ? "checkmark.circle.fill" : "circle")
            .font(.title2)
            .foregroundStyle(statusColor)
    }
    
    private var statusColor: Color {
        switch task.status {
        case .completed:
            return .green
        case .inProgress:
            return .blue
        case .pending:
            return .gray
        }
    }
    
    // MARK: - Priority Badge
    
    private var priorityBadge: some View {
        HStack(spacing: 2) {
            Image(systemName: "flag.fill")
                .font(.caption2)
            Text(task.priority.displayName)
                .font(.caption2)
        }
        .foregroundStyle(priorityColor)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(priorityColor.opacity(0.1))
        .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .blue
        }
    }
    
    // MARK: - Category Badge
    
    private func categoryBadge(name: String) -> some View {
        HStack(spacing: 2) {
            Circle()
                .fill(categoryColor ?? .gray)
                .frame(width: 6, height: 6)
            Text(name)
                .font(.caption2)
        }
        .foregroundStyle(.secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(.systemGray5))
        .cornerRadius(4)
    }
    
    // MARK: - Due Date Badge
    
    private func dueDateBadge(date: Date) -> some View {
        let isOverdue = date < Date() && task.status != .completed
        
        return HStack(spacing: 2) {
            Image(systemName: "calendar")
                .font(.caption2)
            Text(formatDate(date))
                .font(.caption2)
        }
        .foregroundStyle(isOverdue ? .red : .secondary)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background((isOverdue ? Color.red : Color(.systemGray5)).opacity(isOverdue ? 0.1 : 1))
        .cornerRadius(4)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInTomorrow(date) {
            return "Tomorrow"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
    }
}

#Preview {
    List {
        TaskRowView(
            task: TaskItem(
                title: "Complete project documentation",
                description: "Write comprehensive documentation for the API",
                priority: .high,
                status: .pending,
                dueDate: Date(),
                userId: "user1"
            ),
            categoryName: "Work",
            categoryColor: .blue
        )
        
        TaskRowView(
            task: TaskItem(
                title: "Buy groceries",
                priority: .medium,
                status: .completed,
                userId: "user1"
            ),
            categoryName: nil,
            categoryColor: nil
        )
    }
}
