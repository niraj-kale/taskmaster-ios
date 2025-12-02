//
//  CategoryListScreen.swift
//  TaskMaster
//
//  Created by Niraj Kale on 02/12/25.
//

import SwiftUI

struct CategoryListScreen: View {
    
    var viewModel: CategoryListViewModel
    var onCategoryTap: ((Category) -> Void)?
    
    var body: some View {
        content
            .navigationTitle("Categories")
            .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("OK") { viewModel.clearError() }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                await viewModel.loadCategories()
            }
            .refreshable {
                await viewModel.loadCategories()
            }
    }
    
    // MARK: - Content
    
    @ViewBuilder
    private var content: some View {
        if viewModel.isLoading && viewModel.categories.isEmpty {
            ProgressView("Loading categories...")
        } else if viewModel.isEmpty {
            emptyState
        } else {
            categoryList
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        ContentUnavailableView(
            "No Categories",
            systemImage: "folder",
            description: Text("Categories will appear here")
        )
    }
    
    // MARK: - Category List
    
    private var categoryList: some View {
        List(viewModel.categories) { category in
            CategoryRow(category: category)
                .contentShape(Rectangle())
                .onTapGesture {
                    onCategoryTap?(category)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        _Concurrency.Task { await viewModel.deleteCategory(category) }
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Category Row

struct CategoryRow: View {
    let category: Category
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(Color(hex: category.color) ?? .accentColor)
                .frame(width: 32)
            
            Text(category.name)
                .font(.body)
            
            Spacer()
        }
        .padding(.vertical, 8)
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
    NavigationStack {
        CategoryListScreen(
            viewModel: CategoryListViewModel(
                getCategoriesUseCase: PreviewGetCategoriesUseCase(),
                deleteCategoryUseCase: PreviewDeleteCategoryUseCase()
            )
        )
    }
}

// MARK: - Preview Helpers

@MainActor
private final class PreviewGetCategoriesUseCase: GetCategoriesUseCaseProtocol {
    func execute() async throws -> [Category] {
        [
            Category(name: "Work", color: "#FF5733", icon: "briefcase", createdAt: Date()),
            Category(name: "Personal", color: "#33A1FF", icon: "person", createdAt: Date()),
            Category(name: "Shopping", color: "#4CAF50", icon: "cart", createdAt: Date())
        ]
    }
}

@MainActor
private final class PreviewDeleteCategoryUseCase: DeleteCategoryUseCaseProtocol {
    func execute(_ category: Category) async throws {}
}
