//
//  SyncConflict.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

/// Represents a sync conflict between local and remote data
struct SyncConflict<T: Identifiable>: Identifiable {
    let id: T.ID
    let localVersion: T
    let remoteVersion: T
    let detectedAt: Date
    
    init(localVersion: T, remoteVersion: T, detectedAt: Date = Date()) {
        self.id = localVersion.id
        self.localVersion = localVersion
        self.remoteVersion = remoteVersion
        self.detectedAt = detectedAt
    }
}

/// Resolution strategy for sync conflicts
enum ConflictResolution {
    case keepLocal
    case keepRemote
}

/// Type alias for task conflicts
typealias TaskConflict = SyncConflict<Task>

