//
//  SyncStatusIndicator.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct SyncStatusIndicator: View {
    
    let status: SyncStatus
    let lastSyncDate: Date?
    var onSync: (() -> Void)?
    
    var body: some View {
        HStack(spacing: 8) {
            statusIcon
            
            VStack(alignment: .leading, spacing: 2) {
                Text(statusText)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let date = lastSyncDate {
                    Text("Last: \(date.formatted(.relative(presentation: .named)))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            if let onSync, status != .pending {
                Button(action: onSync) {
                    Image(systemName: "arrow.clockwise")
                        .font(.body)
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
            }
        }
        .padding(.vertical, 8)
    }
    
    // MARK: - Helpers
    
    private var statusIcon: some View {
        Group {
            switch status {
            case .none:
                Image(systemName: "cloud")
                    .foregroundStyle(.secondary)
            case .synced:
                Image(systemName: "checkmark.icloud")
                    .foregroundStyle(.green)
            case .pending:
                ProgressView()
                    .controlSize(.small)
            case .failed:
                Image(systemName: "exclamationmark.icloud")
                    .foregroundStyle(.red)
            }
        }
        .frame(width: 24)
    }
    
    private var statusText: String {
        switch status {
        case .none: "Not synced"
        case .synced: "Synced"
        case .pending: "Syncing..."
        case .failed: "Sync failed"
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SyncStatusIndicator(status: .none, lastSyncDate: nil, onSync: {})
        SyncStatusIndicator(status: .synced, lastSyncDate: Date(), onSync: {})
        SyncStatusIndicator(status: .pending, lastSyncDate: Date().addingTimeInterval(-300), onSync: nil)
        SyncStatusIndicator(status: .failed, lastSyncDate: Date().addingTimeInterval(-3600), onSync: {})
    }
    .padding()
}

