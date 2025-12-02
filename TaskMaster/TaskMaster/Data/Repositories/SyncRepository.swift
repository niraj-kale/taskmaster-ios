//
//  SyncRepository.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

final class SyncRepository: SyncRepositoryProtocol {
    
    private let localTaskDataSource: LocalTaskDataSourceProtocol
    private let remoteTaskDataSource: RemoteTaskDataSourceProtocol
    private let localCategoryDataSource: LocalCategoryDataSourceProtocol
    private let remoteCategoryDataSource: RemoteCategoryDataSourceProtocol
    
    private var currentStatus: SyncStatus = .none
    
    init(
        localTaskDataSource: LocalTaskDataSourceProtocol = LocalTaskDataSource(),
        remoteTaskDataSource: RemoteTaskDataSourceProtocol = RemoteTaskDataSource(),
        localCategoryDataSource: LocalCategoryDataSourceProtocol = LocalCategoryDataSource(),
        remoteCategoryDataSource: RemoteCategoryDataSourceProtocol = RemoteCategoryDataSource()
    ) {
        self.localTaskDataSource = localTaskDataSource
        self.remoteTaskDataSource = remoteTaskDataSource
        self.localCategoryDataSource = localCategoryDataSource
        self.remoteCategoryDataSource = remoteCategoryDataSource
    }
    
    func syncTasks() async throws -> SyncStatus {
        currentStatus = .pending
        
        do {
            // Fetch remote data
            let remoteTasks = try await remoteTaskDataSource.getTasks()
            let remoteCategories = try await remoteCategoryDataSource.getCategories()
            
            // Update local cache
            localTaskDataSource.saveTasks(remoteTasks)
            localCategoryDataSource.saveCategories(remoteCategories)
            
            currentStatus = .synced
            return currentStatus
        } catch {
            currentStatus = .failed
            throw error
        }
    }
    
    func getSyncStatus() async -> SyncStatus {
        return currentStatus
    }
}

