import UIKit
import Foundation

// Test script to evaluate GridGPT approach
class TestGridDetection {
    
    static func runTest() {
        print("🧪 Testing GridGPT Detection System\n")
        
        // Test 1: Grid overlay on sample image
        if let testImage = UIImage(named: "bebop38veub21") {
            print("✅ Test image loaded: \(testImage.size)")
            
            // Add grid overlay
            let gridImage = GridOverlayService.addGridOverlay(to: testImage)
            
            // Save for visual inspection
            if let data = gridImage.jpegData(compressionQuality: 0.8) {
                print("✅ Grid overlay added successfully")
                // In a real app, we'd save this to disk or display it
            }
            
            // Test prompt generation
            let testPrompt = """
            Analyze this room image and identify EVERY item that needs to be cleaned up or organized.
            
            The image has a 5x5 grid overlay with cells labeled A1-E5.
            
            For each item, provide:
            1. Item name/description
            2. Category (clothing, electronics, books, papers, dishes, toys, bedding, office_supplies, furniture, personal_items, decor, other)
            3. Grid cell location (e.g., "B3" for single cell, or "B2-C3" for items spanning multiple cells)
            4. Confidence (0.0-1.0)
            
            Format your response as JSON:
            {
              "items": [
                {
                  "name": "red shirt",
                  "category": "clothing",
                  "grid_location": "B3",
                  "confidence": 0.9
                }
              ]
            }
            """
            
            print("\n📝 Generated prompt for GPT-4 Vision:")
            print(testPrompt)
            
            // Test grid coordinate conversion
            testGridCoordinateConversion()
        } else {
            print("❌ Failed to load test image")
        }
    }
    
    static func testGridCoordinateConversion() {
        print("\n🔄 Testing coordinate conversion:")
        
        // Test converting grid cells to normalized coordinates
        let testCases = [
            ("A1", CGRect(x: 0.0, y: 0.0, width: 0.2, height: 0.2)),
            ("C3", CGRect(x: 0.4, y: 0.4, width: 0.2, height: 0.2)),
            ("E5", CGRect(x: 0.8, y: 0.8, width: 0.2, height: 0.2))
        ]
        
        for (gridCell, expectedRect) in testCases {
            let rect = GridOverlayService.gridCellToRect(gridCell)
            print("  \(gridCell) → \(rect)")
            assert(rect == expectedRect, "Conversion failed for \(gridCell)")
        }
        
        print("✅ All coordinate conversions passed")
    }
}

// Extension to help with grid cell to coordinate conversion
extension GridOverlayService {
    static func gridCellToRect(_ cell: String) -> CGRect {
        guard cell.count == 2,
              let col = cell.first,
              let row = cell.last,
              let colIndex = "ABCDE".firstIndex(of: col),
              let rowIndex = Int(String(row)) else {
            return .zero
        }
        
        let x = CGFloat("ABCDE".distance(from: "ABCDE".startIndex, to: colIndex)) * 0.2
        let y = CGFloat(rowIndex - 1) * 0.2
        
        return CGRect(x: x, y: y, width: 0.2, height: 0.2)
    }
    
    static func rectToGridCell(rect: CGRect) -> String {
        let colIndex = Int(rect.midX * 5)
        let rowIndex = Int(rect.midY * 5) + 1
        
        let col = String("ABCDE"["ABCDE".index("ABCDE".startIndex, offsetBy: min(colIndex, 4))])
        let row = String(min(rowIndex, 5))
        
        return col + row
    }
} 