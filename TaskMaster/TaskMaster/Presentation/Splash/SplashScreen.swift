//
//  SplashScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct SplashScreen: View {
    var body: some View {
        VStack(spacing: 24) {
            AppLogo(size: .large)
            ProgressView()
        }
    }
}

#Preview {
    SplashScreen()
}
