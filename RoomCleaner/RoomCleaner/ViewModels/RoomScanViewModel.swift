import SwiftUI
import UIKit

class RoomScanViewModel: ObservableObject {
    @Published var currentInstruction = "Let's start with an overview of your room"
    
    let requiredAreas = [
        "Room Overview",
        "Desk/Work Area",
        "Bed Area",
        "Floor",
        "Closet/Wardrobe",
        "Drawers/Storage"
    ]
    
    let minimumPhotos = 1
    
    private let instructions = [
        "Let's start with an overview of your room",
        "Now show me your desk or work area",
        "Take a photo of your bed area",
        "Show me the floor and any items on it",
        "Open your closet and take a photo",
        "Show me any drawers or storage areas",
        "Great! Take any additional photos of problem areas"
    ]
    
    func getCurrentArea(photoCount: Int) -> String {
        if photoCount < requiredAreas.count {
            return requiredAreas[photoCount]
        }
        return "Additional Area"
    }
    
    func updateInstructions(photoCount: Int) {
        if photoCount < instructions.count {
            currentInstruction = instructions[photoCount]
        } else {
            currentInstruction = "Great! Take any additional photos of problem areas"
        }
    }
    
    func analyzeRoom(photos: [RoomPhoto], appState: AppState) {
        // This is now handled by AnalyzingView which uses MultiPassVisionAnalyzer
        // Just transition to the analyzing phase
        appState.currentPhase = .analyzing
    }
}