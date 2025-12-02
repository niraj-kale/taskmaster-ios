//
//  SyncStatusViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class SyncStatusViewModel {
    
    // MARK: - Properties
    
    var status: SyncStatus = .none
    var lastSyncDate: Date?
    var errorMessage: String?
    
    var isSyncing: Bool { status == .pending }
    
    // MARK: - Dependencies
    
    private let syncDataUseCase: SyncDataUseCaseProtocol
    
    // MARK: - Init
    
    init(syncDataUseCase: SyncDataUseCaseProtocol) {
        self.syncDataUseCase = syncDataUseCase
    }
    
    // MARK: - Actions
    
    func sync() async {
        guard !isSyncing else { return }
        
        status = .pending
        errorMessage = nil
        
        do {
            status = try await syncDataUseCase.execute()
            lastSyncDate = Date()
        } catch {
            status = .failed
            errorMessage = error.localizedDescription
        }
    }
    
    func loadStatus() async {
        status = await syncDataUseCase.getStatus()
    }
}

