//
//  RemoteTaskDataSource.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol RemoteTaskDataSourceProtocol {
    func getTasks() async throws -> [Task]
    func getTask(id: UUID) async throws -> Task?
    func createTask(_ task: Task) async throws -> Task
    func updateTask(_ task: Task) async throws -> Task
    func deleteTask(id: UUID) async throws
}

final class RemoteTaskDataSource: RemoteTaskDataSourceProtocol {
    
    private let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var tasksCollection: CollectionReference? {
        guard let userId else { return nil }
        return db.collection("users").document(userId).collection("tasks")
    }
    
    func getTasks() async throws -> [Task] {
        guard let collection = tasksCollection else { return [] }
        
        let snapshot = try await collection.order(by: "createdAt", descending: true).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Task.self) }
    }
    
    func getTask(id: UUID) async throws -> Task? {
        guard let collection = tasksCollection else { return nil }
        
        let doc = try await collection.document(id.uuidString).getDocument()
        return try? doc.data(as: Task.self)
    }
    
    func createTask(_ task: Task) async throws -> Task {
        guard let collection = tasksCollection else {
            throw TaskError.notAuthenticated
        }
        
        try collection.document(task.id.uuidString).setData(from: task)
        return task
    }
    
    func updateTask(_ task: Task) async throws -> Task {
        guard let collection = tasksCollection else {
            throw TaskError.notAuthenticated
        }
        
        var updatedTask = task
        updatedTask.updatedAt = Date()
        try collection.document(task.id.uuidString).setData(from: updatedTask)
        return updatedTask
    }
    
    func deleteTask(id: UUID) async throws {
        guard let collection = tasksCollection else {
            throw TaskError.notAuthenticated
        }
        
        try await collection.document(id.uuidString).delete()
    }
}

// MARK: - Errors

enum TaskError: LocalizedError {
    case notAuthenticated
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Please sign in to manage tasks"
        case .notFound: return "Task not found"
        }
    }
}
