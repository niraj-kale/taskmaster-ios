//
//  TaskMasterTests.swift
//  TaskMasterTests
//
//  Created for TaskMaster iOS App
//

import XCTest
@testable import TaskMaster

final class TaskMasterTests: XCTestCase {
    
    // MARK: - User Model Tests
    
    func testUserInitialization() {
        let user = User(
            id: "test-id",
            email: "test@example.com",
            displayName: "Test User"
        )
        
        XCTAssertEqual(user.id, "test-id")
        XCTAssertEqual(user.email, "test@example.com")
        XCTAssertEqual(user.displayName, "Test User")
    }
    
    func testUserToDictionary() {
        let user = User(
            id: "test-id",
            email: "test@example.com",
            displayName: "Test User"
        )
        
        let dict = user.toDictionary()
        
        XCTAssertEqual(dict["id"] as? String, "test-id")
        XCTAssertEqual(dict["email"] as? String, "test@example.com")
        XCTAssertEqual(dict["displayName"] as? String, "Test User")
    }
    
    // MARK: - Task Model Tests
    
    func testTaskInitialization() {
        let task = TaskItem(
            title: "Test Task",
            description: "Test Description",
            priority: .high,
            status: .pending,
            userId: "user-1"
        )
        
        XCTAssertEqual(task.title, "Test Task")
        XCTAssertEqual(task.description, "Test Description")
        XCTAssertEqual(task.priority, .high)
        XCTAssertEqual(task.status, .pending)
        XCTAssertEqual(task.userId, "user-1")
        XCTAssertFalse(task.isDeleted)
    }
    
    func testTaskPriorityDisplayName() {
        XCTAssertEqual(TaskPriority.low.displayName, "Low")
        XCTAssertEqual(TaskPriority.medium.displayName, "Medium")
        XCTAssertEqual(TaskPriority.high.displayName, "High")
    }
    
    func testTaskStatusDisplayName() {
        XCTAssertEqual(TaskStatus.pending.displayName, "Pending")
        XCTAssertEqual(TaskStatus.inProgress.displayName, "In Progress")
        XCTAssertEqual(TaskStatus.completed.displayName, "Completed")
    }
    
    func testTaskToDictionary() {
        let task = TaskItem(
            id: "task-1",
            title: "Test Task",
            description: "Description",
            priority: .medium,
            status: .pending,
            userId: "user-1"
        )
        
        let dict = task.toDictionary()
        
        XCTAssertEqual(dict["id"] as? String, "task-1")
        XCTAssertEqual(dict["title"] as? String, "Test Task")
        XCTAssertEqual(dict["priority"] as? String, "medium")
        XCTAssertEqual(dict["status"] as? String, "pending")
        XCTAssertEqual(dict["isDeleted"] as? Bool, false)
    }
    
    // MARK: - TaskCategory Model Tests
    
    func testTaskCategoryInitialization() {
        let category = TaskCategory(
            name: "Work",
            colorHex: "#FF0000",
            iconName: "briefcase.fill",
            userId: "user-1"
        )
        
        XCTAssertEqual(category.name, "Work")
        XCTAssertEqual(category.colorHex, "#FF0000")
        XCTAssertEqual(category.iconName, "briefcase.fill")
        XCTAssertEqual(category.userId, "user-1")
        XCTAssertFalse(category.isDeleted)
    }
    
    func testTaskCategoryToDictionary() {
        let category = TaskCategory(
            id: "cat-1",
            name: "Personal",
            colorHex: "#00FF00",
            iconName: "person.fill",
            userId: "user-1"
        )
        
        let dict = category.toDictionary()
        
        XCTAssertEqual(dict["id"] as? String, "cat-1")
        XCTAssertEqual(dict["name"] as? String, "Personal")
        XCTAssertEqual(dict["colorHex"] as? String, "#00FF00")
        XCTAssertEqual(dict["iconName"] as? String, "person.fill")
    }
    
    // MARK: - Color Extension Tests
    
    func testColorFromHex() {
        let color = Color(hex: "#FF0000")
        XCTAssertNotNil(color)
        
        let colorWithoutHash = Color(hex: "00FF00")
        XCTAssertNotNil(colorWithoutHash)
        
        let invalidColor = Color(hex: "invalid")
        XCTAssertNil(invalidColor)
    }
    
    // MARK: - Date Extension Tests
    
    func testDateIsToday() {
        let today = Date()
        XCTAssertTrue(today.isToday)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(yesterday.isToday)
    }
    
    func testDateIsTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertTrue(tomorrow.isTomorrow)
        
        let today = Date()
        XCTAssertFalse(today.isTomorrow)
    }
    
    func testDateIsPast() {
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertTrue(yesterday.isPast)
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertFalse(tomorrow.isPast)
    }
    
    func testDateIsFuture() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertTrue(tomorrow.isFuture)
        
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: Date())!
        XCTAssertFalse(yesterday.isFuture)
    }
    
    func testDateRelativeFormatted() {
        let today = Date()
        XCTAssertEqual(today.relativeFormatted, "Today")
        
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        XCTAssertEqual(tomorrow.relativeFormatted, "Tomorrow")
    }
}
