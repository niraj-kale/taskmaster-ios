//
//  SyncEngine.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class SyncEngine {
    
    static let shared = SyncEngine()
    
    private(set) var status: SyncStatus = .none
    private(set) var lastSyncDate: Date?
    
    private let syncRepository: SyncRepositoryProtocol
    @ObservationIgnored private var syncTask: _Concurrency.Task<Void, Never>?
    
    init(syncRepository: SyncRepositoryProtocol = SyncRepository()) {
        self.syncRepository = syncRepository
    }
    
    // MARK: - Public API
    
    func sync() async {
        guard status != .pending else { return }
        
        status = .pending
        
        do {
            status = try await syncRepository.syncTasks()
            lastSyncDate = Date()
        } catch {
            status = .failed
        }
    }
    
    func startAutoSync(interval: TimeInterval = 300) {
        stopAutoSync()
        
        syncTask = _Concurrency.Task { [weak self] in
            while !_Concurrency.Task.isCancelled {
                await self?.sync()
                try? await _Concurrency.Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
            }
        }
    }
    
    func stopAutoSync() {
        syncTask?.cancel()
        syncTask = nil
    }
}

