//
//  UserDefaultsDataSource.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation

protocol UserDefaultsDataSourceProtocol {
    func getPreferences() -> UserPreferences
    func savePreferences(_ preferences: UserPreferences)
}

final class UserDefaultsDataSource: UserDefaultsDataSourceProtocol {
    
    private let defaults: UserDefaults
    private let key = "user_preferences"
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func getPreferences() -> UserPreferences {
        guard let data = defaults.data(forKey: key),
              let preferences = try? JSONDecoder().decode(UserPreferences.self, from: data) else {
            return .default
        }
        return preferences
    }
    
    func savePreferences(_ preferences: UserPreferences) {
        if let data = try? JSONEncoder().encode(preferences) {
            defaults.set(data, forKey: key)
        }
    }
}

