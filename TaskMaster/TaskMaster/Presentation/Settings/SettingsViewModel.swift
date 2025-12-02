//
//  SettingsViewModel.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    
    // MARK: - Properties
    
    var isDarkMode: Bool {
        didSet { save() }
    }
    
    var notificationsEnabled: Bool {
        didSet { save() }
    }
    
    // MARK: - Dependencies
    
    private let dataSource: UserDefaultsDataSourceProtocol
    
    // MARK: - Init
    
    init(dataSource: UserDefaultsDataSourceProtocol) {
        self.dataSource = dataSource
        let prefs = dataSource.getPreferences()
        self.isDarkMode = prefs.isDarkMode
        self.notificationsEnabled = prefs.notificationsEnabled
    }
    
    // MARK: - Actions
    
    private func save() {
        let preferences = UserPreferences(
            isDarkMode: isDarkMode,
            notificationsEnabled: notificationsEnabled
        )
        dataSource.savePreferences(preferences)
    }
}

