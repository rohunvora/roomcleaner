import Foundation
import UIKit
import SwiftUI

class OpenAIService {
    static let shared = OpenAIService()
    private let session = URLSession.shared
    
    enum APIError: LocalizedError {
        case invalidKey
        case rateLimitExceeded
        case invalidResponse
        case networkError(String)
        case jsonParsingError(String)
        
        var errorDescription: String? {
            switch self {
            case .invalidKey:
                return "Invalid API key. Please check your configuration."
            case .rateLimitExceeded:
                return "Too many requests. Please try again later."
            case .invalidResponse:
                return "Received invalid response from AI service."
            case .networkError(let message):
                return "Network error: \(message)"
            case .jsonParsingError(let message):
                return "Failed to parse response: \(message)"
            }
        }
    }
    
    // Response structures
    struct OpenAIResponse: Codable {
        let choices: [Choice]
        let usage: Usage?
        
        struct Choice: Codable {
            let message: Message
        }
        
        struct Message: Codable {
            let content: String
        }
        
        struct Usage: Codable {
            let totalTokens: Int
            
            enum CodingKeys: String, CodingKey {
                case totalTokens = "total_tokens"
            }
        }
    }
    
    struct DetectionResponse: Codable {
        let items: [DetectedItemResponse]
        let storageAreas: [StorageAreaResponse]
        let roomMessiness: Int?
        
        enum CodingKeys: String, CodingKey {
            case items
            case storageAreas = "storage_areas"
            case roomMessiness = "room_messiness"
        }
    }
    
    struct DetectedItemResponse: Codable {
        let label: String
        let category: String
        let brand: String?
        let confidence: Double
        let location: String?  // e.g., "top-left", "center", "bottom-right"
        let boundingBox: BoundingBox?
        
        enum CodingKeys: String, CodingKey {
            case label, category, brand, confidence, location
            case boundingBox = "bounding_box"
        }
    }
    
    struct BoundingBox: Codable {
        let x: Double      // 0.0 to 1.0 (percentage of image width)
        let y: Double      // 0.0 to 1.0 (percentage of image height)
        let width: Double  // 0.0 to 1.0
        let height: Double // 0.0 to 1.0
    }
    
    struct StorageAreaResponse: Codable {
        let name: String
        let type: String
        let location: String
    }
    
    // Main analysis function
    func analyzeImage(_ image: UIImage, prompt: String) async throws -> (String, UIImage) {
        guard !APIConfiguration.openAIKey.isEmpty else {
            throw APIError.invalidKey
        }
        
        // Add grid overlay to image
        guard let gridImage = GridOverlayService.addGridOverlay(to: image) else {
            throw APIError.networkError("Failed to add grid overlay to image")
        }
        
        // Compress the gridded image
        guard let compressedImage = compressImage(gridImage, maxDimension: 1024) else {
            throw APIError.networkError("Failed to compress image for API")
        }
        
        guard let imageData = compressedImage.jpegData(compressionQuality: 0.7) else {
            throw APIError.networkError("Failed to convert image to JPEG data")
        }
        
        let base64Image = imageData.base64EncodedString()
        
        // Create the request
        var request = URLRequest(url: URL(string: APIConfiguration.apiURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfiguration.openAIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": APIConfiguration.model,
            "messages": [
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
            ],
            "max_tokens": APIConfiguration.maxTokens,
            "temperature": APIConfiguration.temperature
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        // Make the request
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response type")
        }
        
        guard httpResponse.statusCode == 200 else {
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                print("OpenAI API Error: \(errorData)")
            }
            throw APIError.networkError("Status \(httpResponse.statusCode): Invalid response from OpenAI API")
        }
        
        // Parse the response
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw APIError.networkError("Invalid response format")
        }
        
        // Return both the response and the compressed image (which was used for analysis)
        return (content, compressedImage)
    }
    
    private func compressImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage? {
        let size = image.size
        let scale = max(size.width, size.height) / maxDimension
        
        if scale <= 1.0 {
            return image // No need to compress
        }
        
        let newSize = CGSize(
            width: size.width / scale,
            height: size.height / scale
        )
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let compressedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        print("Compressed image from \(size) to \(newSize)")
        
        return compressedImage
    }
}

// Add these model structs to a Models file
struct DetectedItem: Identifiable {
    let id = UUID()
    let label: String
    let category: ItemCategory
    let brand: String?
    var suggestedStorage: String = ""
    let confidence: Double
    let location: String?  // General location like "top-left", "center", etc.
    let boundingBox: CGRect?  // Normalized coordinates (0-1)
    var croppedImage: UIImage?  // Cropped image of just this item
    var photoIndex: Int = 0  // Which photo this item was detected in (0-based)
}

struct StorageArea {
    let id = UUID()
    let name: String
    let type: StorageType
    let location: String
}

enum ItemCategory: String, CaseIterable, Codable {
    case clothing = "clothing"
    case electronics = "electronics"
    case books = "books"
    case papers = "papers"
    case personalCare = "personal_care"
    case food = "food"
    case trash = "trash"
    case bedding = "bedding"
    case furniture = "furniture"
    case decor = "decor"
    case toys = "toys"
    case office = "office_supplies"
    case dishes = "dishes"
    case other = "other"
    
    var displayName: String {
        switch self {
        case .clothing: return "Clothing"
        case .electronics: return "Electronics"
        case .books: return "Books"
        case .papers: return "Papers"
        case .personalCare: return "Personal Care"
        case .food: return "Food & Drink"
        case .trash: return "Trash"
        case .bedding: return "Bedding"
        case .furniture: return "Furniture"
        case .decor: return "Decorations"
        case .toys: return "Toys & Games"
        case .office: return "Office Supplies"
        case .dishes: return "Dishes"
        case .other: return "Miscellaneous"
        }
    }
    
    var emoji: String {
        switch self {
        case .clothing: return "👕"
        case .electronics: return "📱"
        case .books: return "📚"
        case .papers: return "📄"
        case .personalCare: return "🧴"
        case .food: return "🍽"
        case .trash: return "🗑"
        case .bedding: return "🛏"
        case .furniture: return "🪑"
        case .decor: return "🖼"
        case .toys: return "🧸"
        case .office: return "✏️"
        case .dishes: return "🍽"
        case .other: return "📦"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing: return .blue
        case .electronics: return .purple
        case .books: return .orange
        case .papers: return .gray
        case .personalCare: return .pink
        case .food: return .green
        case .trash: return .red
        case .bedding: return .indigo
        case .furniture: return .brown
        case .decor: return .yellow
        case .toys: return .mint
        case .office: return .cyan
        case .dishes: return .teal
        case .other: return .secondary
        }
    }
}

enum StorageType: String, CaseIterable, Codable {
    case closet = "closet"
    case drawer = "drawer"
    case shelf = "shelf"
    case desk = "desk"
    case cabinet = "cabinet"
    case bin = "bin"
    case floor = "floor"
    case other = "other"
}