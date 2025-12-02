//
//  DependencyContainer.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

final class DependencyContainer {
    
    static let shared = DependencyContainer()
    
    private init() {}
    
    // MARK: - Repositories
    
    lazy var authRepository: AuthRepositoryProtocol = AuthRepository()
    lazy var taskRepository: TaskRepositoryProtocol = TaskRepository()
    lazy var categoryRepository: CategoryRepositoryProtocol = CategoryRepository()
    
    // MARK: - Use Cases (Auth)
    
    lazy var getCurrentUserUseCase: GetCurrentUserUseCaseProtocol = {
        GetCurrentUserUseCase(authRepository: authRepository)
    }()
    
    lazy var signOutUseCase: SignOutUseCaseProtocol = {
        SignOutUseCase(authRepository: authRepository)
    }()
    
    // MARK: - Use Cases (Tasks)
    
    lazy var getTasksUseCase: GetTasksUseCaseProtocol = {
        GetTasksUseCase(taskRepository: taskRepository)
    }()
    
    lazy var createTaskUseCase: CreateTaskUseCaseProtocol = {
        CreateTaskUseCase(taskRepository: taskRepository)
    }()
    
    lazy var getTaskByIdUseCase: GetTaskByIdUseCaseProtocol = {
        GetTaskByIdUseCase(taskRepository: taskRepository)
    }()
    
    lazy var updateTaskUseCase: UpdateTaskUseCaseProtocol = {
        UpdateTaskUseCase(taskRepository: taskRepository)
    }()
    
    lazy var deleteTaskUseCase: DeleteTaskUseCaseProtocol = {
        DeleteTaskUseCase(taskRepository: taskRepository)
    }()
    
    lazy var toggleTaskCompletionUseCase: ToggleTaskCompletionUseCaseProtocol = {
        ToggleTaskCompletionUseCase(taskRepository: taskRepository)
    }()
    
    // MARK: - Use Cases (Categories)
    
    lazy var getCategoriesUseCase: GetCategoriesUseCaseProtocol = {
        GetCategoriesUseCase(categoryRepository: categoryRepository)
    }()
    
    lazy var createCategoryUseCase: CreateCategoryUseCaseProtocol = {
        CreateCategoryUseCase(categoryRepository: categoryRepository)
    }()
    
    lazy var deleteCategoryUseCase: DeleteCategoryUseCaseProtocol = {
        DeleteCategoryUseCase(categoryRepository: categoryRepository)
    }()
    
    // MARK: - View Models
    
    @MainActor
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authRepository: authRepository)
    }
    
    @MainActor
    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            getTasksUseCase: getTasksUseCase,
            taskRepository: taskRepository,
            getCategoriesUseCase: getCategoriesUseCase
        )
    }
    
    @MainActor
    func makeCreateTaskViewModel() -> CreateTaskViewModel {
        CreateTaskViewModel(
            createTaskUseCase: createTaskUseCase,
            getCategoriesUseCase: getCategoriesUseCase
        )
    }
    
    @MainActor
    func makeTaskDetailViewModel(task: Task) -> TaskDetailViewModel {
        TaskDetailViewModel(
            task: task,
            taskRepository: taskRepository,
            getCategoriesUseCase: getCategoriesUseCase
        )
    }
    
    @MainActor
    func makeEditTaskViewModel(task: Task) -> EditTaskViewModel {
        EditTaskViewModel(
            task: task,
            updateTaskUseCase: updateTaskUseCase,
            getCategoriesUseCase: getCategoriesUseCase
        )
    }
    
    @MainActor
    func makeCategoryListViewModel() -> CategoryListViewModel {
        CategoryListViewModel(
            getCategoriesUseCase: getCategoriesUseCase,
            deleteCategoryUseCase: deleteCategoryUseCase
        )
    }
    
    @MainActor
    func makeCreateCategoryViewModel() -> CreateCategoryViewModel {
        CreateCategoryViewModel(createCategoryUseCase: createCategoryUseCase)
    }
}
