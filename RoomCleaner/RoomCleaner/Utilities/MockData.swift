import UIKit
import SwiftUI

struct MockData {
    static let demoMode = true // Set to false for production
    
    static func generateMockRoomImage(for area: String) -> UIImage {
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
}