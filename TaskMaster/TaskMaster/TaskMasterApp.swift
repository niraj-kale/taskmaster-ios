//
//  TaskMasterApp.swift
//  TaskMaster
//
//  Created by Niraj Kale on 30/11/25.
//

import SwiftUI
import FirebaseCore

class TaskMasterAppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct TaskMasterApp: App {
    
    // register app delegate
    @UIApplicationDelegateAdaptor(TaskMasterAppDelegate.self) var appDelegate: TaskMasterAppDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
