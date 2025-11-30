//
//  Category.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

struct Category: Identifiable, Equatable, Codable {
    let id: UUID
    var name: String
    var color: String
    var icon: String
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        name: String,
        color: String,
        icon: String,
        createdAt: Date
    ) {
        self.id = id
        self.name = name
        self.color = color
        self.icon = icon
        self.createdAt = createdAt
    }
}
