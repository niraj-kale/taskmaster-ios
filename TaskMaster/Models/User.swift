//
//  User.swift
//  TaskMaster
//
//  Created for TaskMaster iOS App
//

import Foundation

/// Represents a user in the TaskMaster app
struct User: Codable, Identifiable, Equatable {
    let id: String
    var email: String
    var displayName: String?
    var photoURL: String?
    var createdAt: Date
    var lastLoginAt: Date
    
    init(
        id: String,
        email: String,
        displayName: String? = nil,
        photoURL: String? = nil,
        createdAt: Date = Date(),
        lastLoginAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
        self.lastLoginAt = lastLoginAt
    }
}

extension User {
    /// Creates a dictionary representation for Firestore
    func toDictionary() -> [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "email": email,
            "createdAt": createdAt,
            "lastLoginAt": lastLoginAt
        ]
        if let displayName = displayName {
            dict["displayName"] = displayName
        }
        if let photoURL = photoURL {
            dict["photoURL"] = photoURL
        }
        return dict
    }
    
    /// Creates a User from a Firestore dictionary
    static func fromDictionary(_ dict: [String: Any], id: String) -> User? {
        guard let email = dict["email"] as? String else { return nil }
        
        return User(
            id: id,
            email: email,
            displayName: dict["displayName"] as? String,
            photoURL: dict["photoURL"] as? String,
            createdAt: (dict["createdAt"] as? Date) ?? Date(),
            lastLoginAt: (dict["lastLoginAt"] as? Date) ?? Date()
        )
    }
}
