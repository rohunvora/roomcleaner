import UIKit
import SwiftUI

struct MockData {
    #if DEBUG
    static let testModeEnabled = true // Enable test mode in debug builds
    #else
    static let testModeEnabled = false
    #endif
    
    static let demoMode = false // Deprecated - use testModeEnabled instead
    
    // Test images available in the project
    struct TestImage {
        let filename: String
        let displayName: String
        let description: String
    }
    
    static let testImages: [TestImage] = [
        TestImage(
            filename: "bebop38veub21",
            displayName: "Messy Bedroom 1",
            description: "Bedroom with clothes on floor"
        ),
        TestImage(
            filename: "iesll09jp2o21",
            displayName: "Messy Bedroom 2",
            description: "Room with scattered items"
        ),
        TestImage(
            filename: "who-am-i-based-on-my-relatively-messy-room-v0-3uxt3508qnvc1",
            displayName: "Student Room 1",
            description: "Dorm room with desk area"
        ),
        TestImage(
            filename: "who-am-i-based-on-my-relatively-messy-room-v0-jth3v408qnvc1",
            displayName: "Student Room 2",
            description: "Room with gaming setup"
        ),
        TestImage(
            filename: "who-am-i-based-on-my-relatively-messy-room-v0-kny4g508qnvc1",
            displayName: "Student Room 3",
            description: "Room with study materials"
        ),
        TestImage(
            filename: "wonderlane-6jA6eVsRJ6Q-unsplash",
            displayName: "Cluttered Room",
            description: "Room with various items"
        )
    ]
    
    static func loadTestImage(_ filename: String) -> UIImage? {
        // In debug mode, try to load from the Resources folder
        #if DEBUG
        // Try different file extensions
        let extensions = ["webp", "jpg", "jpeg", "png"]
        
        for ext in extensions {
            let fullFilename = filename.contains(".") ? filename : "\(filename).\(ext)"
            
            // Try from bundle first
            if let path = Bundle.main.path(forResource: fullFilename, ofType: nil) {
                if let image = UIImage(contentsOfFile: path) {
                    print("✅ Loaded test image from bundle: \(fullFilename)")
                    return image
                }
            }
            
            // Try from Resources/TestImages in bundle
            if let path = Bundle.main.path(forResource: "Resources/TestImages/\(fullFilename)", ofType: nil) {
                if let image = UIImage(contentsOfFile: path) {
                    print("✅ Loaded test image from Resources: \(fullFilename)")
                    return image
                }
            }
            
            // For development, try absolute path
            let devPath = "/Users/satoshi/roomcleaner/RoomCleaner/RoomCleaner/Resources/TestImages/\(fullFilename)"
            if let image = UIImage(contentsOfFile: devPath) {
                print("✅ Loaded test image from dev path: \(fullFilename)")
                return image
            }
        }
        
        print("⚠️ Could not load test image: \(filename)")
        print("📁 Creating placeholder image instead")
        
        // Create a colored placeholder
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
        return renderer.image { context in
            // Random color based on filename
            let hue = CGFloat(filename.hash % 360) / 360.0
            UIColor(hue: hue, saturation: 0.7, brightness: 0.8, alpha: 1.0).setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
            
            // Add filename text
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 16, weight: .medium),
                .foregroundColor: UIColor.white
            ]
            let text = "Test: \(filename)"
            text.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        }
        #else
        // In release mode, only try from bundle
        if let image = UIImage(named: filename) {
            return image
        }
        return nil
        #endif
    }
    
    static func generateMockRoomImage(for area: String) -> UIImage {
        // If we have test images loaded, use a random one
        if testModeEnabled, let randomTestImage = testImages.randomElement(),
           let image = loadTestImage(randomTestImage.filename) {
            return image
        }
        
        // Otherwise fall back to generated mock
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: 400, height: 300))
        
        return renderer.image { context in
            // Background
            UIColor.systemGray6.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 400, height: 300))
            
            // Draw area-specific mock content
            switch area {
            case "Room Overview":
                drawRoomOverview(in: context.cgContext)
            case "Desk/Work Area":
                drawDeskArea(in: context.cgContext)
            case "Bed Area":
                drawBedArea(in: context.cgContext)
            case "Floor":
                drawFloorArea(in: context.cgContext)
            default:
                drawGenericArea(in: context.cgContext)
            }
            
            // Add label
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 20, weight: .bold),
                .foregroundColor: UIColor.label
            ]
            let text = "Mock: \(area)"
            text.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        }
    }
    
    static func drawRoomOverview(in context: CGContext) {
        // Messy room elements
        UIColor.systemBrown.setFill()
        context.fill(CGRect(x: 50, y: 100, width: 80, height: 60)) // Desk
        
        UIColor.systemBlue.setFill()
        context.fill(CGRect(x: 250, y: 150, width: 120, height: 80)) // Bed
        
        // Scattered items
        UIColor.systemRed.setFill()
        for _ in 0..<5 {
            let x = CGFloat.random(in: 50...350)
            let y = CGFloat.random(in: 100...250)
            context.fillEllipse(in: CGRect(x: x, y: y, width: 20, height: 20))
        }
    }
    
    static func drawDeskArea(in context: CGContext) {
        // Desk surface
        UIColor.systemBrown.setFill()
        context.fill(CGRect(x: 50, y: 150, width: 300, height: 100))
        
        // Papers scattered
        UIColor.white.setFill()
        for i in 0..<4 {
            context.fill(CGRect(x: 70 + i * 30, y: 160 + i * 10, width: 40, height: 50))
        }
        
        // Electronics
        UIColor.black.setFill()
        context.fill(CGRect(x: 200, y: 170, width: 60, height: 40)) // Laptop
        context.fill(CGRect(x: 280, y: 180, width: 30, height: 20)) // Phone
    }
    
    static func drawBedArea(in context: CGContext) {
        // Bed
        UIColor.systemBlue.setFill()
        context.fill(CGRect(x: 50, y: 100, width: 300, height: 150))
        
        // Unmade sheets
        UIColor.systemGray3.setFill()
        context.fill(CGRect(x: 70, y: 120, width: 260, height: 110))
        
        // Clothes on bed
        UIColor.systemPurple.setFill()
        context.fill(CGRect(x: 150, y: 140, width: 50, height: 60))
        UIColor.systemGreen.setFill()
        context.fill(CGRect(x: 220, y: 130, width: 40, height: 50))
    }
    
    static func drawFloorArea(in context: CGContext) {
        // Floor
        UIColor.systemGray5.setFill()
        context.fill(CGRect(x: 0, y: 200, width: 400, height: 100))
        
        // Scattered items
        let colors = [UIColor.systemRed, UIColor.systemBlue, UIColor.systemGreen, UIColor.systemPurple]
        for i in 0..<8 {
            colors[i % colors.count].setFill()
            let x = CGFloat.random(in: 20...380)
            let y = CGFloat.random(in: 210...280)
            context.fill(CGRect(x: x, y: y, width: 30, height: 25))
        }
    }
    
    static func drawGenericArea(in context: CGContext) {
        UIColor.systemGray4.setFill()
        context.fill(CGRect(x: 50, y: 100, width: 300, height: 150))
        
        UIColor.systemOrange.setFill()
        for _ in 0..<3 {
            let x = CGFloat.random(in: 60...340)
            let y = CGFloat.random(in: 110...240)
            context.fill(CGRect(x: x, y: y, width: 40, height: 30))
        }
    }
    
    static func generateMockDetection() -> (items: [DetectedItem], storage: [StorageArea]) {
        let items = [
            DetectedItem(label: "Blue Nike running shoes", category: .clothing, brand: "Nike", confidence: 0.95, location: "bottom-left", boundingBox: CGRect(x: 0.1, y: 0.7, width: 0.15, height: 0.1), croppedImage: nil),
            DetectedItem(label: "White cotton t-shirt", category: .clothing, brand: nil, confidence: 0.90, location: "center", boundingBox: CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2), croppedImage: nil),
            DetectedItem(label: "MacBook Pro laptop", category: .electronics, brand: "Apple", confidence: 0.98, location: "top-center", boundingBox: CGRect(x: 0.35, y: 0.1, width: 0.3, height: 0.2), croppedImage: nil),
            DetectedItem(label: "iPhone charging cable", category: .electronics, brand: "Apple", confidence: 0.85, location: "center-right", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Psychology textbook", category: .books, brand: nil, confidence: 0.92, location: "top-left", boundingBox: CGRect(x: 0.05, y: 0.05, width: 0.2, height: 0.15), croppedImage: nil),
            DetectedItem(label: "Scattered homework papers", category: .papers, brand: nil, confidence: 0.88, location: "center-left", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Empty water bottle", category: .trash, brand: nil, confidence: 0.91, location: "bottom-right", boundingBox: CGRect(x: 0.8, y: 0.8, width: 0.1, height: 0.15), croppedImage: nil),
            DetectedItem(label: "Black backpack", category: .other, brand: nil, confidence: 0.93, location: "bottom-center", boundingBox: CGRect(x: 0.4, y: 0.75, width: 0.2, height: 0.2), croppedImage: nil),
            DetectedItem(label: "Red hoodie", category: .clothing, brand: nil, confidence: 0.89, location: "center", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Crumpled tissues", category: .trash, brand: nil, confidence: 0.87, location: "top-right", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Gray sweatpants", category: .clothing, brand: nil, confidence: 0.86, location: "center-left", boundingBox: CGRect(x: 0.15, y: 0.45, width: 0.15, height: 0.2), croppedImage: nil),
            DetectedItem(label: "Wireless mouse", category: .electronics, brand: "Logitech", confidence: 0.91, location: "top-center", boundingBox: CGRect(x: 0.45, y: 0.15, width: 0.1, height: 0.08), croppedImage: nil),
            DetectedItem(label: "Coffee mug", category: .dishes, brand: nil, confidence: 0.88, location: "center-right", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Notebook with pen", category: .papers, brand: nil, confidence: 0.90, location: "center", boundingBox: CGRect(x: 0.35, y: 0.35, width: 0.3, height: 0.2), croppedImage: nil),
            DetectedItem(label: "Sneakers (left foot)", category: .clothing, brand: "Adidas", confidence: 0.93, location: "bottom-left", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Headphones", category: .electronics, brand: "Sony", confidence: 0.94, location: "top-right", boundingBox: CGRect(x: 0.7, y: 0.1, width: 0.15, height: 0.15), croppedImage: nil),
            DetectedItem(label: "Empty chip bag", category: .trash, brand: "Lay's", confidence: 0.85, location: "bottom-center", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Jacket on chair", category: .clothing, brand: nil, confidence: 0.92, location: "center-right", boundingBox: CGRect(x: 0.65, y: 0.4, width: 0.25, height: 0.3), croppedImage: nil),
            DetectedItem(label: "Stack of books", category: .books, brand: nil, confidence: 0.89, location: "top-left", boundingBox: nil, croppedImage: nil),
            DetectedItem(label: "Phone charger", category: .electronics, brand: nil, confidence: 0.87, location: "center", boundingBox: nil, croppedImage: nil)
        ]
        
        let storage = [
            StorageArea(name: "Closet", type: .closet, location: "Left wall"),
            StorageArea(name: "Desk", type: .desk, location: "By window"),
            StorageArea(name: "Bookshelf", type: .shelf, location: "Right wall"),
            StorageArea(name: "Dresser", type: .drawer, location: "Next to bed"),
            StorageArea(name: "Under bed storage", type: .bin, location: "Under bed"),
            StorageArea(name: "Nightstand drawer", type: .drawer, location: "Beside bed")
        ]
        
        return (items, storage)
    }
}