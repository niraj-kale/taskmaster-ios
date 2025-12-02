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
    
    // Keys match @AppStorage keys in TaskMasterApp
    private enum Keys {
        static let darkMode = "user_preferences_dark_mode"
        static let notifications = "user_preferences_notifications"
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    func getPreferences() -> UserPreferences {
        UserPreferences(
            isDarkMode: defaults.bool(forKey: Keys.darkMode),
            notificationsEnabled: defaults.object(forKey: Keys.notifications) as? Bool ?? true
        )
    }
    
    func savePreferences(_ preferences: UserPreferences) {
        defaults.set(preferences.isDarkMode, forKey: Keys.darkMode)
        defaults.set(preferences.notificationsEnabled, forKey: Keys.notifications)
    }
}

