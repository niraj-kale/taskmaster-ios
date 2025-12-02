//
//  AppLogo.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI

struct AppLogo: View {
    
    enum Size {
        case small, medium, large
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 40
            case .medium: return 60
            case .large: return 80
            }
        }
        
        var titleFont: Font {
            switch self {
            case .small: return .title3.bold()
            case .medium: return .title.bold()
            case .large: return .largeTitle.bold()
            }
        }
    }
    
    var size: Size = .large
    var color: Color = .blue
    var showTitle: Bool = true
    var subtitle: String? = nil
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: size.iconSize))
                .foregroundStyle(color)
            
            if showTitle {
                Text("TaskMaster")
                    .font(size.titleFont)
            }
            
            if let subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        AppLogo(size: .large)
        AppLogo(size: .medium, subtitle: "Welcome back")
        AppLogo(size: .small, color: .green)
    }
}
