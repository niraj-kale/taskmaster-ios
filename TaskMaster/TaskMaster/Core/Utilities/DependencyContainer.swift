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
    
    // MARK: - View Models
    
    @MainActor
    func makeAuthViewModel() -> AuthViewModel {
        AuthViewModel(authRepository: authRepository)
    }
    
    @MainActor
    func makeTaskListViewModel() -> TaskListViewModel {
        TaskListViewModel(
            getTasksUseCase: getTasksUseCase,
            taskRepository: taskRepository
        )
    }
    
    @MainActor
    func makeCreateTaskViewModel() -> CreateTaskViewModel {
        CreateTaskViewModel(createTaskUseCase: createTaskUseCase)
    }
    
    @MainActor
    func makeTaskDetailViewModel(task: Task) -> TaskDetailViewModel {
        TaskDetailViewModel(task: task, taskRepository: taskRepository)
    }
    
    @MainActor
    func makeEditTaskViewModel(task: Task) -> EditTaskViewModel {
        EditTaskViewModel(task: task, updateTaskUseCase: updateTaskUseCase)
    }
}
