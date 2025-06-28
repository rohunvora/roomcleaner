import SwiftUI
import UIKit

class AppState: ObservableObject {
    @Published var currentPhase: CleaningPhase = .welcome
    @Published var roomPhotos: [RoomPhoto] = []
    @Published var cleaningPlan: CleaningPlan?
    @Published var currentTaskIndex: Int = 0
    @Published var completedTasks: Set<String> = []
    @Published var detectedObjects: [MultiPassVisionAnalyzer.DetectedObject] = []
    @Published var currentAnalyzingPhoto: RoomPhoto?
    
    enum CleaningPhase {
        case welcome
        case scanning
        case analyzing
        case labeling  // New phase for adding missing items
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
    
    func completeLabelingPhase(with finalObjects: [MultiPassVisionAnalyzer.DetectedObject]) {
        detectedObjects = finalObjects
        // Generate cleaning plan based on detected objects
        generateCleaningPlan()
        currentPhase = .cleaning
    }
    
    private func generateCleaningPlan() {
        // Group objects by category and location
        var tasksByCategory: [String: [MultiPassVisionAnalyzer.DetectedObject]] = [:]
        
        for object in detectedObjects {
            tasksByCategory[object.category, default: []].append(object)
        }
        
        // Create tasks for each category
        var tasks: [CleaningTask] = []
        
        for (category, objects) in tasksByCategory.sorted(by: { $0.value.count > $1.value.count }) {
            let task = CleaningTask(
                title: "Organize \(category)",
                items: objects.map { $0.label },
                category: category.capitalized,
                estimatedMinutes: max(3, objects.count * 2),
                referenceImage: currentAnalyzingPhoto?.image
            )
            tasks.append(task)
        }
        
        cleaningPlan = CleaningPlan(
            tasks: tasks,
            totalItems: detectedObjects.count,
            estimatedTime: tasks.reduce(0) { $0 + $1.estimatedMinutes },
            categories: tasksByCategory.map { ItemCategory(name: $0.key, itemCount: $0.value.count, priority: 1) }
        )
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