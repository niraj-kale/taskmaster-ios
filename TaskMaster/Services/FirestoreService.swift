//
//  FirestoreService.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation
import FirebaseFirestore

/// Firestore errors
enum FirestoreError: LocalizedError {
    case notAuthenticated
    case documentNotFound
    case invalidData
    case networkError
    case permissionDenied
    case unknown(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated:
            return "You must be signed in to perform this action."
        case .documentNotFound:
            return "The requested item was not found."
        case .invalidData:
            return "Invalid data format."
        case .networkError:
            return "Network error. Please check your connection."
        case .permissionDenied:
            return "You don't have permission to perform this action."
        case .unknown(let message):
            return message
        }
    }
}

/// Protocol for Firestore service
protocol FirestoreServiceProtocol {
    // Task operations
    func createTask(_ task: TaskItem) async throws
    func updateTask(_ task: TaskItem) async throws
    func deleteTask(_ taskId: String) async throws
    func getTask(_ taskId: String, userId: String) async throws -> TaskItem?
    func getTasks(for userId: String) async throws -> [TaskItem]
    func observeTasks(for userId: String, onChange: @escaping ([TaskItem]) -> Void) -> ListenerRegistration
    
    // Category operations
    func createCategory(_ category: TaskCategory) async throws
    func updateCategory(_ category: TaskCategory) async throws
    func deleteCategory(_ categoryId: String) async throws
    func getCategories(for userId: String) async throws -> [TaskCategory]
    func observeCategories(for userId: String, onChange: @escaping ([TaskCategory]) -> Void) -> ListenerRegistration
    
    // User operations
    func saveUser(_ user: User) async throws
    func getUser(_ userId: String) async throws -> User?
}

/// Firebase Firestore Service implementation
final class FirestoreService: FirestoreServiceProtocol {
    static let shared = FirestoreService()
    
    private let db = Firestore.firestore()
    
    private let tasksCollection = "tasks"
    private let categoriesCollection = "categories"
    private let usersCollection = "users"
    
    private init() {
        // Enable offline persistence
        let settings = FirestoreSettings()
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
    
    // MARK: - Task Operations
    
    func createTask(_ task: TaskItem) async throws {
        do {
            try await db.collection(tasksCollection)
                .document(task.id)
                .setData(task.toDictionary())
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func updateTask(_ task: TaskItem) async throws {
        var updatedTask = task
        updatedTask.updatedAt = Date()
        
        do {
            try await db.collection(tasksCollection)
                .document(task.id)
                .setData(updatedTask.toDictionary(), merge: true)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func deleteTask(_ taskId: String) async throws {
        do {
            // Soft delete - mark as deleted
            try await db.collection(tasksCollection)
                .document(taskId)
                .updateData([
                    "isDeleted": true,
                    "updatedAt": Date()
                ])
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func getTask(_ taskId: String, userId: String) async throws -> TaskItem? {
        do {
            let document = try await db.collection(tasksCollection)
                .document(taskId)
                .getDocument()
            
            guard let data = document.data() else {
                return nil
            }
            
            return TaskItem.fromDictionary(data, id: document.documentID)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func getTasks(for userId: String) async throws -> [TaskItem] {
        do {
            let snapshot = try await db.collection(tasksCollection)
                .whereField("userId", isEqualTo: userId)
                .whereField("isDeleted", isEqualTo: false)
                .order(by: "updatedAt", descending: true)
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                TaskItem.fromDictionary(doc.data(), id: doc.documentID)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func observeTasks(for userId: String, onChange: @escaping ([TaskItem]) -> Void) -> ListenerRegistration {
        return db.collection(tasksCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "updatedAt", descending: true)
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    onChange([])
                    return
                }
                
                let tasks = documents.compactMap { doc in
                    TaskItem.fromDictionary(doc.data(), id: doc.documentID)
                }
                onChange(tasks)
            }
    }
    
    // MARK: - Category Operations
    
    func createCategory(_ category: TaskCategory) async throws {
        do {
            try await db.collection(categoriesCollection)
                .document(category.id)
                .setData(category.toDictionary())
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func updateCategory(_ category: TaskCategory) async throws {
        var updatedCategory = category
        updatedCategory.updatedAt = Date()
        
        do {
            try await db.collection(categoriesCollection)
                .document(category.id)
                .setData(updatedCategory.toDictionary(), merge: true)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func deleteCategory(_ categoryId: String) async throws {
        do {
            // Soft delete - mark as deleted
            try await db.collection(categoriesCollection)
                .document(categoryId)
                .updateData([
                    "isDeleted": true,
                    "updatedAt": Date()
                ])
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func getCategories(for userId: String) async throws -> [TaskCategory] {
        do {
            let snapshot = try await db.collection(categoriesCollection)
                .whereField("userId", isEqualTo: userId)
                .whereField("isDeleted", isEqualTo: false)
                .order(by: "name")
                .getDocuments()
            
            return snapshot.documents.compactMap { doc in
                TaskCategory.fromDictionary(doc.data(), id: doc.documentID)
            }
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func observeCategories(for userId: String, onChange: @escaping ([TaskCategory]) -> Void) -> ListenerRegistration {
        return db.collection(categoriesCollection)
            .whereField("userId", isEqualTo: userId)
            .whereField("isDeleted", isEqualTo: false)
            .order(by: "name")
            .addSnapshotListener { snapshot, error in
                guard let documents = snapshot?.documents else {
                    onChange([])
                    return
                }
                
                let categories = documents.compactMap { doc in
                    TaskCategory.fromDictionary(doc.data(), id: doc.documentID)
                }
                onChange(categories)
            }
    }
    
    // MARK: - User Operations
    
    func saveUser(_ user: User) async throws {
        do {
            try await db.collection(usersCollection)
                .document(user.id)
                .setData(user.toDictionary(), merge: true)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    func getUser(_ userId: String) async throws -> User? {
        do {
            let document = try await db.collection(usersCollection)
                .document(userId)
                .getDocument()
            
            guard let data = document.data() else {
                return nil
            }
            
            return User.fromDictionary(data, id: document.documentID)
        } catch {
            throw mapFirestoreError(error)
        }
    }
    
    // MARK: - Helper Methods
    
    private func mapFirestoreError(_ error: Error) -> FirestoreError {
        let nsError = error as NSError
        
        guard nsError.domain == FirestoreErrorDomain else {
            return .unknown(error.localizedDescription)
        }
        
        let errorCode = FirestoreErrorCode(rawValue: nsError.code)
        
        switch errorCode {
        case .notFound:
            return .documentNotFound
        case .permissionDenied:
            return .permissionDenied
        case .unavailable:
            return .networkError
        case .invalidArgument:
            return .invalidData
        default:
            return .unknown(error.localizedDescription)
        }
    }
}
