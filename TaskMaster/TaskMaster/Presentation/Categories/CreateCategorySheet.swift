//
//  CreateCategorySheet.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct CreateCategorySheet: View {
    
    @State private var viewModel: CreateCategoryViewModel
    @Environment(\.dismiss) private var dismiss
    var onCategoryCreated: ((Category) -> Void)?
    
    init(viewModel: CreateCategoryViewModel, onCategoryCreated: ((Category) -> Void)? = nil) {
        _viewModel = State(wrappedValue: viewModel)
        self.onCategoryCreated = onCategoryCreated
    }
    
    var body: some View {
        NavigationStack {
            CategoryFormView(
                name: $viewModel.name,
                color: $viewModel.color,
                icon: $viewModel.icon
            )
            .navigationTitle("New Category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    if viewModel.isLoading {
                        ProgressView()
                    } else {
                        Button("Save") {
                            _Concurrency.Task { await viewModel.createCategory() }
                        }
                        .disabled(!viewModel.isFormValid)
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .onChange(of: viewModel.createdCategory) { _, category in
                if let category {
                    onCategoryCreated?(category)
                    dismiss()
                }
            }
        }
    }
}

// MARK: - Category Form View (Reusable)

struct CategoryFormView: View {
    
    @Binding var name: String
    @Binding var color: String
    @Binding var icon: String
    
    private let colors = ["#007AFF", "#FF3B30", "#34C759", "#FF9500", "#AF52DE", "#FF2D55", "#5856D6", "#00C7BE"]
    private let icons = ["folder", "briefcase", "cart", "house", "heart", "star", "book", "gamecontroller"]
    
    var body: some View {
        Form {
            Section("Name") {
                TextField("Category name", text: $name)
            }
            
            Section("Color") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(colors, id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex) ?? .blue)
                            .frame(width: 44, height: 44)
                            .overlay {
                                if color == hex {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                        .font(.headline)
                                }
                            }
                            .onTapGesture { color = hex }
                    }
                }
                .padding(.vertical, 8)
            }
            
            Section("Icon") {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                    ForEach(icons, id: \.self) { iconName in
                        Image(systemName: iconName)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(icon == iconName ? Color(hex: color) ?? .blue : Color.gray.opacity(0.2))
                            .foregroundStyle(icon == iconName ? .white : .primary)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                            .onTapGesture { icon = iconName }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Color Extension

private extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        guard hexSanitized.count == 6,
              let rgb = UInt64(hexSanitized, radix: 16) else { return nil }
        
        self.init(
            red: Double((rgb >> 16) & 0xFF) / 255.0,
            green: Double((rgb >> 8) & 0xFF) / 255.0,
            blue: Double(rgb & 0xFF) / 255.0
        )
    }
}

#Preview {
    CreateCategorySheet(
        viewModel: CreateCategoryViewModel(
            createCategoryUseCase: PreviewCreateCategoryUseCase()
        )
    )
}

// MARK: - Preview Helper

@MainActor
private final class PreviewCreateCategoryUseCase: CreateCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws -> Category { category }
}

