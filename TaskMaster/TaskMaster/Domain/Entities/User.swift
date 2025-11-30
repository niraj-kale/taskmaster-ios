//
//  User.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

public struct User: Codable, Equatable, Identifiable {
    public let id: String
    public let email: String
    public let displayName: String?
    public let photoURL: URL?
    public let createdAt: Date
    
    public init(
        id: String = UUID().uuidString,
        email: String,
        displayName: String? = nil,
        photoURL: URL? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.photoURL = photoURL
        self.createdAt = createdAt
    }
}
