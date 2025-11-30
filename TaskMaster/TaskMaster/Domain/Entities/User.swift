//
//  User.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

public struct User: Codable {
    let id: UUID
    let email: String
    let displayName: String
    let photoURL: URL?
    let createdAt: Date
    
    init(
        id: UUID = UUID(),
        email: String,
        displayName: String,
        photoURL: URL?,
        createdAt: Date) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
    }
}
