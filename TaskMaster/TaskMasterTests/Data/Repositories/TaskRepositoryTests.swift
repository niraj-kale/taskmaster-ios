//
//  TaskRepositoryTests.swift
//  TaskMasterTests
//
//  Created by Niraj Kale on 02/12/25.
//

import Testing
@testable import TaskMaster

struct TaskRepositoryTests {
    
    // MARK: - getTasks
    
    @Test func getTasks_remoteSuccess_cachesLocally() async throws {
        let local = MockLocalTaskDataSource()
        let remote = MockRemoteTaskDataSource()
        remote.tasks = [Task(title: "Remote Task")]
        
        let repo = TaskRepository(local: local, remote: remote)
        let tasks = try await repo.getTasks()
        
        #expect(tasks.count == 1)
        #expect(tasks[0].title == "Remote Task")
        #expect(local.savedTasks.count == 1)
    }
    
    @Test func getTasks_remoteFails_returnsCached() async throws {
        let local = MockLocalTaskDataSource()
        local.tasks = [Task(title: "Cached Task")]
        let remote = MockRemoteTaskDataSource()
        remote.shouldFail = true
        
        let repo = TaskRepository(local: local, remote: remote)
        let tasks = try await repo.getTasks()
        
        #expect(tasks.count == 1)
        #expect(tasks[0].title == "Cached Task")
    }
    
    @Test func getTasks_remoteFails_noCached_throws() async {
        let local = MockLocalTaskDataSource()
        let remote = MockRemoteTaskDataSource()
        remote.shouldFail = true
        
        let repo = TaskRepository(local: local, remote: remote)
        
        await #expect(throws: Error.self) {
            try await repo.getTasks()
        }
    }
    
    // MARK: - createTask
    
    @Test func createTask_savesToBothSources() async throws {
        let local = MockLocalTaskDataSource()
        let remote = MockRemoteTaskDataSource()
        
        let repo = TaskRepository(local: local, remote: remote)
        let task = try await repo.createTask(Task(title: "New Task"))
        
        #expect(task.title == "New Task")
        #expect(remote.createCalled)
        #expect(local.savedTasks.contains { $0.title == "New Task" })
    }
    
    // MARK: - deleteTask
    
    @Test func deleteTask_deletesFromBothSources() async throws {
        let taskId = UUID()
        let local = MockLocalTaskDataSource()
        let remote = MockRemoteTaskDataSource()
        
        let repo = TaskRepository(local: local, remote: remote)
        try await repo.deleteTask(id: taskId)
        
        #expect(remote.deletedId == taskId)
        #expect(local.deletedId == taskId)
    }
}

// MARK: - Mocks

private final class MockLocalTaskDataSource: LocalTaskDataSourceProtocol {
    var tasks: [Task] = []
    var savedTasks: [Task] = []
    var deletedId: UUID?
    
    func getTasks() -> [Task] { tasks }
    func getTask(id: UUID) -> Task? { tasks.first { $0.id == id } }
    func saveTask(_ task: Task) { savedTasks.append(task) }
    func saveTasks(_ tasks: [Task]) { savedTasks.append(contentsOf: tasks) }
    func deleteTask(id: UUID) { deletedId = id }
    func clear() { tasks.removeAll() }
}

private final class MockRemoteTaskDataSource: RemoteTaskDataSourceProtocol {
    var tasks: [Task] = []
    var shouldFail = false
    var createCalled = false
    var deletedId: UUID?
    
    func getTasks() async throws -> [Task] {
        if shouldFail { throw NSError(domain: "Test", code: 1) }
        return tasks
    }
    
    func getTask(id: UUID) async throws -> Task? {
        tasks.first { $0.id == id }
    }
    
    func createTask(_ task: Task) async throws -> Task {
        createCalled = true
        return task
    }
    
    func updateTask(_ task: Task) async throws -> Task { task }
    
    func deleteTask(id: UUID) async throws {
        deletedId = id
    }
}

