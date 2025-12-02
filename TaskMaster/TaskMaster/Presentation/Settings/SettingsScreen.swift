//
//  SettingsScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct SettingsScreen: View {
    
    @State private var viewModel: SettingsViewModel
    
    init(viewModel: SettingsViewModel) {
        _viewModel = State(wrappedValue: viewModel)
    }
    
    var body: some View {
        Form {
            Section("Appearance") {
                Toggle("Dark Mode", isOn: $viewModel.isDarkMode)
            }
            
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $viewModel.notificationsEnabled)
            }
        }
        .navigationTitle("Settings")
    }
}

