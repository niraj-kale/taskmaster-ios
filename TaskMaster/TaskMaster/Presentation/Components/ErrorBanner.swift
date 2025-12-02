//
//  ErrorBanner.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct ErrorBanner: View {
    
    let message: String
    var onDismiss: (() -> Void)?
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Spacer()
            
            if let onDismiss {
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .foregroundStyle(.white)
                }
                .accessibilityLabel("Dismiss error")
            }
        }
        .padding()
        .background(Color.red, in: RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Error: \(message)")
    }
}

// MARK: - View Modifier

struct ErrorBannerModifier: ViewModifier {
    
    @Binding var error: String?
    
    func body(content: Content) -> some View {
        content.overlay(alignment: .top) {
            if let error {
                ErrorBanner(message: error) {
                    withAnimation { self.error = nil }
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .padding(.top, 8)
            }
        }
        .animation(.spring, value: error)
    }
}

extension View {
    func errorBanner(_ error: Binding<String?>) -> some View {
        modifier(ErrorBannerModifier(error: error))
    }
}

