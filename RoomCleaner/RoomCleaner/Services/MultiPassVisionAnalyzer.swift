import Foundation
import UIKit

// Multi-pass detection for comprehensive room analysis
class MultiPassVisionAnalyzer {
    static let shared = MultiPassVisionAnalyzer()
    private let apiKey = "YOUR_OPENAI_API_KEY" // Replace with your API key
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    struct DetectedObject: Codable, Hashable {
        let id: String
        let label: String
        let confidence: Float
        let boundingBox: BoundingBox
        let category: String
        let detectionPass: Int
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
        
        static func == (lhs: DetectedObject, rhs: DetectedObject) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    struct BoundingBox: Codable {
        let x: Int
        let y: Int
        let width: Int
        let height: Int
        
        // Check if two boxes overlap significantly
        func overlaps(with other: BoundingBox, threshold: Float = 0.5) -> Bool {
            let x1 = max(x, other.x)
            let y1 = max(y, other.y)
            let x2 = min(x + width, other.x + other.width)
            let y2 = min(y + height, other.y + other.height)
            
            guard x2 > x1 && y2 > y1 else { return false }
            
            let intersectionArea = Float((x2 - x1) * (y2 - y1))
            let area1 = Float(width * height)
            let area2 = Float(other.width * other.height)
            let minArea = min(area1, area2)
            
            return intersectionArea / minArea > threshold
        }
    }
    
    struct ComprehensiveResult {
        let allObjects: [DetectedObject]
        let passResults: [Int: [DetectedObject]]
        let totalProcessingTime: TimeInterval
        let imageSize: CGSize
    }
    
    // Multi-pass prompts for different detection focuses
    private let detectionPasses = [
        // Pass 1: General overview
        """
        Detect ALL visible objects in this messy room image. Focus on large and obvious items.
        Include furniture, electronics, clothing piles, and any prominent objects.
        """,
        
        // Pass 2: Floor and ground-level items
        """
        Focus ONLY on items on the floor or ground level. Look for:
        - Items scattered on the floor
        - Objects under furniture
        - Things in corners
        - Small items like coins, pens, cables
        - Trash and wrappers on the ground
        """,
        
        // Pass 3: Surfaces and stacks
        """
        Focus ONLY on items on surfaces (desks, tables, shelves, bed). Look for:
        - Items in stacks or piles
        - Objects on top of other objects
        - Things on windowsills, nightstands
        - Papers, books, dishes on surfaces
        Identify EACH item in a stack separately.
        """,
        
        // Pass 4: Small and partially visible items
        """
        Focus on SMALL and PARTIALLY VISIBLE items that might have been missed:
        - Cables and chargers
        - Pens, pencils, markers
        - Small personal items
        - Items partially hidden by other objects
        - Things in shadows or poor lighting
        """
    ]
    
    func performComprehensiveDetection(on image: UIImage) async throws -> ComprehensiveResult {
        let startTime = Date()
        var allDetectedObjects = Set<DetectedObject>()
        var passResults: [Int: [DetectedObject]] = [:]
        
        // Run each detection pass
        for (passIndex, prompt) in detectionPasses.enumerated() {
            do {
                let passObjects = try await performSinglePass(
                    image: image,
                    prompt: prompt,
                    passNumber: passIndex + 1
                )
                
                // Store pass results
                passResults[passIndex + 1] = passObjects
                
                // Merge with deduplication
                for object in passObjects {
                    if !isDuplicate(object, in: allDetectedObjects) {
                        allDetectedObjects.insert(object)
                    }
                }
                
                // Rate limiting between passes
                try await Task.sleep(nanoseconds: 1_000_000_000)
                
            } catch {
                print("Pass \(passIndex + 1) failed: \(error)")
            }
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        return ComprehensiveResult(
            allObjects: Array(allDetectedObjects).sorted { $0.confidence > $1.confidence },
            passResults: passResults,
            totalProcessingTime: processingTime,
            imageSize: image.size
        )
    }
    
    private func performSinglePass(image: UIImage, prompt: String, passNumber: Int) async throws -> [DetectedObject] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw VisionError.imageProcessingFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        
        let fullPrompt = """
        \(prompt)
        
        Return a JSON array of detected objects with this structure:
        {
          "objects": [
            {
              "label": "specific descriptive name",
              "confidence": 0.0-1.0,
              "boundingBox": {"x": 0-100, "y": 0-100, "width": 0-100, "height": 0-100},
              "category": "clothes|electronics|papers|books|trash|toiletries|food|furniture|misc"
            }
          ]
        }
        
        Be exhaustive and detect EVERY item you can see in your focus area.
        """
        
        let messages = [
            [
                "role": "user",
                "content": [
                    ["type": "text", "text": fullPrompt],
                    [
                        "type": "image_url",
                        "image_url": [
                            "url": "data:image/jpeg;base64,\(base64Image)",
                            "detail": "high"
                        ]
                    ]
                ]
            ]
        ]
        
        let requestBody: [String: Any] = [
            "model": "gpt-4-vision-preview",
            "messages": messages,
            "max_tokens": 4096,
            "temperature": 0.1
        ]
        
        var request = URLRequest(url: URL(string: apiURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let response = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        
        guard let content = response.choices.first?.message.content,
              let objects = parseObjects(from: content, passNumber: passNumber) else {
            return []
        }
        
        return objects
    }
    
    private func parseObjects(from content: String, passNumber: Int) -> [DetectedObject]? {
        guard let jsonStart = content.firstIndex(of: "{"),
              let jsonEnd = content.lastIndex(of: "}") else {
            return nil
        }
        
        let jsonString = String(content[jsonStart...jsonEnd])
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let objectsArray = json["objects"] as? [[String: Any]] else {
            return nil
        }
        
        return objectsArray.compactMap { dict in
            guard let label = dict["label"] as? String,
                  let confidence = dict["confidence"] as? Double,
                  let boxDict = dict["boundingBox"] as? [String: Any],
                  let x = boxDict["x"] as? Int,
                  let y = boxDict["y"] as? Int,
                  let width = boxDict["width"] as? Int,
                  let height = boxDict["height"] as? Int else {
                return nil
            }
            
            return DetectedObject(
                id: UUID().uuidString,
                label: label,
                confidence: Float(confidence),
                boundingBox: BoundingBox(x: x, y: y, width: width, height: height),
                category: dict["category"] as? String ?? "misc",
                detectionPass: passNumber
            )
        }
    }
    
    private func isDuplicate(_ object: DetectedObject, in existing: Set<DetectedObject>) -> Bool {
        for existingObject in existing {
            // Check if bounding boxes overlap significantly
            if object.boundingBox.overlaps(with: existingObject.boundingBox, threshold: 0.6) {
                // If labels are similar, consider it a duplicate
                if areLabelsSimilar(object.label, existingObject.label) {
                    return true
                }
            }
        }
        return false
    }
    
    private func areLabelsSimilar(_ label1: String, _ label2: String) -> Bool {
        let l1 = label1.lowercased()
        let l2 = label2.lowercased()
        
        // Exact match
        if l1 == l2 { return true }
        
        // One contains the other
        if l1.contains(l2) || l2.contains(l1) { return true }
        
        // Common variations
        let commonWords = ["item", "object", "thing", "stuff"]
        for word in commonWords {
            if (l1.contains(word) && l2.contains(word)) { return true }
        }
        
        return false
    }
}

// Reuse existing error enum
enum VisionError: Error {
    case imageProcessingFailed
    case noResponse
    case invalidJSON
    case apiError(String)
}