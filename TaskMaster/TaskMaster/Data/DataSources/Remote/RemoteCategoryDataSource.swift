//
//  RemoteCategoryDataSource.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

protocol RemoteCategoryDataSourceProtocol {
    func getCategories() async throws -> [Category]
    func createCategory(_ category: Category) async throws -> Category
    func updateCategory(_ category: Category) async throws -> Category
    func deleteCategory(id: UUID) async throws
}

final class RemoteCategoryDataSource: RemoteCategoryDataSourceProtocol {
    
    private let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    private var categoriesCollection: CollectionReference? {
        guard let userId else { return nil }
        return db.collection("users").document(userId).collection("categories")
    }
    
    func getCategories() async throws -> [Category] {
        guard let collection = categoriesCollection else { return [] }
        
        let snapshot = try await collection.order(by: "createdAt", descending: true).getDocuments()
        return snapshot.documents.compactMap { try? $0.data(as: Category.self) }
    }
    
    func createCategory(_ category: Category) async throws -> Category {
        guard let collection = categoriesCollection else {
            throw CategoryError.notAuthenticated
        }
        
        try collection.document(category.id.uuidString).setData(from: category)
        return category
    }
    
    func updateCategory(_ category: Category) async throws -> Category {
        guard let collection = categoriesCollection else {
            throw CategoryError.notAuthenticated
        }
        
        try collection.document(category.id.uuidString).setData(from: category)
        return category
    }
    
    func deleteCategory(id: UUID) async throws {
        guard let collection = categoriesCollection else {
            throw CategoryError.notAuthenticated
        }
        
        try await collection.document(id.uuidString).delete()
    }
}

// MARK: - Errors

enum CategoryError: LocalizedError {
    case notAuthenticated
    case notFound
    
    var errorDescription: String? {
        switch self {
        case .notAuthenticated: return "Please sign in to manage categories"
        case .notFound: return "Category not found"
        }
    }
}

