//
//  UserPreferences.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

struct UserPreferences: Equatable, Codable {
    var isDarkMode: Bool
    var notificationsEnabled: Bool
    
    static let `default` = UserPreferences(
        isDarkMode: false,
        notificationsEnabled: true
    )
}

