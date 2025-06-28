import SwiftUI
import UIKit

class AppState: ObservableObject {
    @Published var currentPhase: CleaningPhase = .welcome
    @Published var roomPhotos: [RoomPhoto] = []
    @Published var cleaningPlan: CleaningPlan?
    @Published var currentTaskIndex: Int = 0
    @Published var completedTasks: Set<String> = []
    
    enum CleaningPhase {
        case welcome
        case scanning
        case analyzing
        case cleaning
        case completed
    }
    
    func startScanning() {
        currentPhase = .scanning
        roomPhotos = []
    }
    
    func completeScanning() {
        currentPhase = .analyzing
    }
    
    func startCleaning(with plan: CleaningPlan) {
        cleaningPlan = plan
        currentPhase = .cleaning
        currentTaskIndex = 0
        completedTasks = []
    }
    
    func completeCurrentTask() {
        guard let plan = cleaningPlan else { return }
        if currentTaskIndex < plan.tasks.count {
            completedTasks.insert(plan.tasks[currentTaskIndex].id)
            
            if currentTaskIndex < plan.tasks.count - 1 {
                currentTaskIndex += 1
            } else {
                currentPhase = .completed
            }
        }
    }
    
    var progress: Double {
        guard let plan = cleaningPlan else { return 0 }
        return Double(completedTasks.count) / Double(plan.tasks.count)
    }
}

struct RoomPhoto: Identifiable {
    let id = UUID()
    let image: UIImage
    let area: String
    let timestamp = Date()
}

struct CleaningPlan {
    let tasks: [CleaningTask]
    let totalItems: Int
    let estimatedTime: Int
    let categories: [ItemCategory]
}

struct CleaningTask: Identifiable {
    let id = UUID().uuidString
    let title: String
    let items: [String]
    let category: String
    let estimatedMinutes: Int
    let referenceImage: UIImage?
}

struct ItemCategory {
    let name: String
    let itemCount: Int
    let priority: Int
}