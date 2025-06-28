import Foundation
import UIKit

// Object detection focused analyzer
class VisionAnalyzer {
    static let shared = VisionAnalyzer()
    private let apiKey = "YOUR_OPENAI_API_KEY" // Replace with your API key
    private let apiURL = "https://api.openai.com/v1/chat/completions"
    
    struct DetectedObject: Codable {
        let label: String
        let confidence: Float
        let boundingBox: BoundingBox
        let category: String?
    }
    
    struct BoundingBox: Codable {
        let x: Int
        let y: Int
        let width: Int
        let height: Int
    }
    
    struct DetectionResult: Codable {
        let objects: [DetectedObject]
        let imageWidth: Int
        let imageHeight: Int
        let totalObjectCount: Int
    }
    
    func detectObjects(in image: UIImage) async throws -> DetectionResult {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw VisionError.imageProcessingFailed
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Optimized prompt for object detection
        let prompt = """
        You are an expert object detection system. Analyze this image of a messy room and identify ALL visible objects.
        
        For EACH distinct object you can see, provide:
        1. A clear, specific label (e.g., "blue t-shirt", "iPhone charger", "water bottle")
        2. Confidence score (0.0-1.0)
        3. Bounding box coordinates (x, y, width, height) as percentages of image dimensions
        4. Category (clothes, electronics, papers, books, trash, toiletries, food, furniture, misc)
        
        Rules:
        - Detect EVERY visible object, even partially visible ones
        - Be specific with labels (not just "item" or "object")
        - Include items on surfaces, floor, furniture, in piles
        - Distinguish between similar items (e.g., multiple shirts)
        - Include small items like pens, cables, wrappers
        
        Return ONLY a JSON object with this exact structure:
        {
          "objects": [
            {
              "label": "string",
              "confidence": 0.0-1.0,
              "boundingBox": {"x": 0-100, "y": 0-100, "width": 0-100, "height": 0-100},
              "category": "string"
            }
          ],
          "imageWidth": 1000,
          "imageHeight": 1000,
          "totalObjectCount": number
        }
        """
        
        let messages = [
            [
                "role": "user",
                "content": [
                    [
                        "type": "text",
                        "text": prompt
                    ],
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
        
        guard let content = response.choices.first?.message.content else {
            throw VisionError.noResponse
        }
        
        // Extract JSON from response
        let result = try parseDetectionResult(from: content)
        return result
    }
    
    private func parseDetectionResult(from content: String) throws -> DetectionResult {
        // Find JSON in the response
        guard let jsonStart = content.firstIndex(of: "{"),
              let jsonEnd = content.lastIndex(of: "}") else {
            throw VisionError.invalidJSON
        }
        
        let jsonString = String(content[jsonStart...jsonEnd])
        guard let jsonData = jsonString.data(using: .utf8) else {
            throw VisionError.invalidJSON
        }
        
        return try JSONDecoder().decode(DetectionResult.self, from: jsonData)
    }
}

enum VisionError: Error {
    case imageProcessingFailed
    case noResponse
    case invalidJSON
    case apiError(String)
}

// Reuse the OpenAI response structure
struct OpenAIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}