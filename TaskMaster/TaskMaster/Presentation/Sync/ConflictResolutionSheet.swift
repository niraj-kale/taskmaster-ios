//
//  ConflictResolutionSheet.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct ConflictResolutionSheet: View {
    
    let conflict: TaskConflict
    let onResolve: (ConflictResolution) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                Section("Local Version") {
                    ConflictTaskRow(task: conflict.localVersion)
                }
                
                Section("Remote Version") {
                    ConflictTaskRow(task: conflict.remoteVersion)
                }
                
                Section {
                    Button("Keep Local") {
                        onResolve(.keepLocal)
                        dismiss()
                    }
                    
                    Button("Keep Remote") {
                        onResolve(.keepRemote)
                        dismiss()
                    }
                }
            }
            .navigationTitle("Resolve Conflict")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Reusable Conflict Task Row

private struct ConflictTaskRow: View {
    let task: Task
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(task.title)
                .font(.headline)
            
            if let description = task.description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
            
            HStack {
                Label(task.priority.displayName, systemImage: "flag")
                Spacer()
                Text("Updated: \(task.updatedAt.formatted(.relative(presentation: .named)))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    ConflictResolutionSheet(
        conflict: TaskConflict(
            localVersion: Task(title: "Local Task", description: "Local changes", updatedAt: Date()),
            remoteVersion: Task(title: "Remote Task", description: "Remote changes", updatedAt: Date().addingTimeInterval(-3600))
        ),
        onResolve: { _ in }
    )
}

