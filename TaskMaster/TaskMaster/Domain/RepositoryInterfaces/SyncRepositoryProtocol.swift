//
//  SyncRepositoryProtocol.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

protocol SyncRepositoryProtocol {
    func syncTasks() async throws -> SyncStatus
    func getSyncStatus() async -> SyncStatus
}
