//
//  TaskCard.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct TaskCard: View {
    
    let task: Task
    var category: Category?
    var onToggle: (() -> Void)?
    var onTap: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 12) {
            // Completion toggle
            Button {
                onToggle?()
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(task.title)
                    .font(.body)
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                HStack(spacing: 8) {
                    priorityBadge
                    
                    if let category {
                        categoryBadge(category)
                    }
                    
                    if let dueDate = task.dueDate {
                        dueDateLabel(dueDate)
                    }
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
        .contentShape(Rectangle())
        .onTapGesture { onTap?() }
    }
    
    // MARK: - Priority Badge
    
    private var priorityBadge: some View {
        Text(task.priority.displayName)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.15))
            .foregroundStyle(priorityColor)
            .clipShape(Capsule())
    }
    
    private var priorityColor: Color {
        switch task.priority {
        case .low: return .blue
        case .medium: return .orange
        case .high: return .red
        }
    }
    
    // MARK: - Category Badge
    
    private func categoryBadge(_ category: Category) -> some View {
        HStack(spacing: 2) {
            Image(systemName: category.icon)
            Text(category.name)
        }
        .font(.caption2)
        .padding(.horizontal, 6)
        .padding(.vertical, 2)
        .background(Color(hex: category.color)?.opacity(0.15) ?? Color.gray.opacity(0.15))
        .foregroundStyle(Color(hex: category.color) ?? .gray)
        .clipShape(Capsule())
    }
    
    // MARK: - Due Date
    
    private func dueDateLabel(_ date: Date) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "calendar")
            Text(date, style: .date)
        }
        .font(.caption2)
        .foregroundStyle(date < Date() && !task.isCompleted ? .red : .secondary)
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
    VStack(spacing: 12) {
        TaskCard(
            task: Task(title: "Buy groceries", priority: .high, dueDate: Date()),
            category: Category(name: "Shopping", color: "#4CAF50", icon: "cart", createdAt: Date()),
            onToggle: {},
            onTap: {}
        )
        
        TaskCard(
            task: Task(title: "Completed task", isCompleted: true),
            onToggle: {},
            onTap: {}
        )
        
        TaskCard(
            task: Task(title: "Low priority item", priority: .low),
            category: Category(name: "Work", color: "#007AFF", icon: "briefcase", createdAt: Date()),
            onToggle: {},
            onTap: {}
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
