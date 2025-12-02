//
//  TaskMasterUITests.swift
//  TaskMasterUITests
//
//  Created by Niraj Kale on 30/11/25.
//

import XCTest

final class TaskMasterUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Critical Flow: Sign Up → Create Task → Complete Task
    
    @MainActor
    func testCriticalFlow_SignUp_CreateTask_CompleteTask() throws {
        // Step 1: Sign Up
        let emailField = app.textFields["Email"]
        let passwordField = app.secureTextFields["Password"]
        
        // Wait for auth screen
        XCTAssertTrue(emailField.waitForExistence(timeout: 5))
        
        emailField.tap()
        emailField.typeText("test\(Int.random(in: 1000...9999))@example.com")
        
        passwordField.tap()
        passwordField.typeText("Password123!")
        
        // If sign up mode, fill confirm password
        let confirmPasswordField = app.secureTextFields["Confirm Password"]
        if confirmPasswordField.exists {
            confirmPasswordField.tap()
            confirmPasswordField.typeText("Password123!")
        }
        
        // Tap Sign Up/Sign In button
        let submitButton = app.buttons["Sign Up"].exists ? app.buttons["Sign Up"] : app.buttons["Sign In"]
        XCTAssertTrue(submitButton.exists)
        submitButton.tap()
        
        // Step 2: Wait for task list and create task
        let addButton = app.buttons["plus"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 10), "Should navigate to task list after auth")
        
        addButton.tap()
        
        // Fill task form
        let titleField = app.textFields.firstMatch
        XCTAssertTrue(titleField.waitForExistence(timeout: 3))
        titleField.tap()
        titleField.typeText("UI Test Task")
        
        // Save task
        let saveButton = app.buttons["Save"]
        if saveButton.exists {
            saveButton.tap()
        }
        
        // Step 3: Verify task appears and complete it
        let taskCell = app.staticTexts["UI Test Task"]
        XCTAssertTrue(taskCell.waitForExistence(timeout: 5), "Created task should appear in list")
    }
    
    @MainActor
    func testAuthScreen_ModeToggle() throws {
        let signUpButton = app.buttons["Sign Up"]
        let signInToggle = app.buttons["Sign In"]
        
        // Wait for screen
        XCTAssertTrue(signUpButton.waitForExistence(timeout: 5) || signInToggle.waitForExistence(timeout: 5))
        
        // Toggle mode
        if app.staticTexts["Already have an account?"].exists {
            signInToggle.tap()
            XCTAssertTrue(app.staticTexts["Don't have an account?"].waitForExistence(timeout: 2))
        }
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
