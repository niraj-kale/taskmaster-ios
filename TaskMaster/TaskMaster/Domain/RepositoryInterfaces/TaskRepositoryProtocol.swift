//
//  TaskRepositoryProtocol.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import Foundation

protocol TaskRepositoryProtocol {
    func getTasks() async throws -> [Task]
    func getTask(id: UUID) async throws -> Task?
    func createTask(_ task: Task) async throws -> Task
    func updateTask(_ task: Task) async throws -> Task
    func deleteTask(id: UUID) async throws
    func searchTasks(query: String) async throws -> [Task]
}
