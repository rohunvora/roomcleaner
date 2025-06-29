import Foundation
import UIKit

@MainActor
class MultiPassVisionAnalyzer: ObservableObject {
    static let shared = MultiPassVisionAnalyzer()
    private let openAIService = OpenAIService.shared
    
    @Published var isAnalyzing = false
    @Published var progress: Double = 0.0
    @Published var currentPass = ""
    @Published var detectionError: Error?
    
    struct DetectionResult {
        let items: [DetectedItem]
        let storageAreas: [StorageArea]
        let organizationSuggestions: [String]
        let confidence: Double
        let totalItemsFound: Int
        let processingTime: TimeInterval
        let compressedPhotos: [UIImage]  // Add compressed photos for UI reference
    }
    
    func analyzePhotos(_ photos: [UIImage]) async throws -> DetectionResult {
        isAnalyzing = true
        progress = 0.0
        detectionError = nil
        defer { isAnalyzing = false }
        
        let startTime = Date()
        var allItems: [DetectedItem] = []
        var allStorage: [StorageArea] = []
        var compressedPhotos: [UIImage] = []  // Collect compressed versions
        let seenItems = NSMutableSet()
        
        // Check for API key
        if APIConfiguration.openAIKey.isEmpty {
            let error = NSError(domain: "RoomCleaner", 
                              code: 401, 
                              userInfo: [NSLocalizedDescriptionKey: "OpenAI API key is missing. Please add your API key to Configuration.xcconfig"])
            detectionError = error
            throw error
        }
        
        // Log that we're using real photos
        if APIConfiguration.logAPIRequests {
            print("🎯 Analyzing \(photos.count) real photos with OpenAI API")
            print("🔑 API Key: \(String(APIConfiguration.openAIKey.prefix(10)))...")
        }
        
        // Process each photo with 2-pass system
        for (index, photo) in photos.enumerated() {
            // Update progress
            progress = Double(index) / Double(photos.count * 2)
            
            // Log original photo dimensions
            print("\n📸 Processing Photo \(index + 1)")
            print("   Original size: \(photo.size.width) x \(photo.size.height)")
            print("   Orientation: \(photo.imageOrientation.rawValue)")
            
            // Pass 1: Comprehensive detection
            currentPass = "Detecting items in photo \(index + 1) of \(photos.count)..."
            
            do {
                let pass1Result = try await detectItemsComprehensive(photo)
                
                // Pass 2: Storage areas and missed items
                currentPass = "Finding storage areas and small items..."
                progress = (Double(index) + 0.5) / Double(photos.count * 2)
                
                let pass2Result = try await detectStorageAndMissedItems(pass1Result.analyzedImage, existingItems: seenItems)
                
                // Merge results with deduplication
                var newItems = deduplicateItems(pass1Result.items + pass2Result.items, seen: seenItems)
                
                // CRITICAL: Add photo index to debug which photo items came from
                print("\n📷 Photo \(index + 1) Analysis:")
                print("   Items before cropping: \(newItems.map { $0.label })")
                print("   Using compressed image size: \(pass1Result.analyzedImage.size.width) x \(pass1Result.analyzedImage.size.height)")
                
                // Create cropped images using the COMPRESSED image that was analyzed
                newItems = createCroppedImages(for: newItems, from: pass1Result.analyzedImage, photoIndex: index)
                
                allItems.append(contentsOf: newItems)
                
                // Add storage areas (no deduplication needed)
                allStorage.append(contentsOf: pass2Result.storage)
                
                // Collect compressed photo from pass 1
                compressedPhotos.append(pass1Result.analyzedImage)
                
                if APIConfiguration.logAPIRequests {
                    print("📸 Photo \(index + 1): Found \(newItems.count) items, \(pass2Result.storage.count) storage areas")
                }
                
            } catch {
                detectionError = error
                print("❌ Detection error for photo \(index + 1): \(error.localizedDescription)")
                // Re-throw the error so the user sees it
                throw error
            }
            
            // Brief pause between photos to avoid rate limits
            if index < photos.count - 1 {
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
            }
        }
        
        // Match items to storage
        currentPass = "Organizing items..."
        progress = 0.9
        
        let matchedItems = matchItemsToStorage(items: allItems, storage: allStorage)
        let suggestions = generateOrganizationSuggestions(items: matchedItems)
        
        progress = 1.0
        let processingTime = Date().timeIntervalSince(startTime)
        
        if APIConfiguration.logAPIRequests {
            print("✅ Analysis complete: \(matchedItems.count) total items in \(String(format: "%.1f", processingTime))s")
        }
        
        return DetectionResult(
            items: matchedItems,
            storageAreas: allStorage,
            organizationSuggestions: suggestions,
            confidence: calculateOverallConfidence(matchedItems),
            totalItemsFound: matchedItems.count,
            processingTime: processingTime,
            compressedPhotos: compressedPhotos
        )
    }
    
    private func detectItemsComprehensive(_ image: UIImage) async throws -> (items: [DetectedItem], storage: [StorageArea], analyzedImage: UIImage) {
        let prompt = """
        You are helping someone with ADHD organize their messy room. Detect EVERY visible item.
        
        BE EXHAUSTIVE - examine the entire image systematically. Include:
        - Each piece of clothing separately (shirts, pants, socks - count each item)
        - All electronics and cables
        - Books, papers (count each)
        - Personal items
        - Trash items (wrappers, tissues, bottles)
        - Bedding items (pillows, blankets, sheets - these are NOT clothing)
        - Any other visible objects
        
        Also identify storage furniture:
        - Closets, dressers, drawers
        - Desks, shelves, cabinets
        - Any place where items could be stored
        
        For each item provide:
        - label: Specific description with color/brand when visible (e.g., "red Nike shoe", "white iPhone cable")
        - category: You MUST use EXACTLY one of these category values (no other values allowed):
          * "clothing" - wearable items only (shirts, pants, shoes, accessories)
          * "electronics" - devices, cables, chargers, electronic items
          * "books" - books, magazines, notebooks
          * "papers" - loose papers, documents, homework, notes
          * "personal_care" - hygiene items, cosmetics, toiletries
          * "food" - food items, drinks, snacks
          * "trash" - garbage, wrappers, disposable items, empty containers
          * "bedding" - pillows, blankets, sheets, quilts, comforters
          * "furniture" - chairs, tables, lamps, nightstands, furniture pieces
          * "decor" - decorations, posters, plants, candles, art, photos
          * "toys" - toys, games, stuffed animals, puzzles
          * "office_supplies" - pens, pencils, staplers, paper clips, stationery
          * "dishes" - plates, cups, bowls, utensils, mugs
          * "other" - ONLY use if item truly doesn't fit ANY category above
        
        IMPORTANT: For items like coins/money use "other", for jewelry use "clothing", for cables use "electronics"
        - brand: If recognizable (Nike, Apple, etc.) or null
        - confidence: 0.0-1.0
        - location: Item's general location using ONLY these values: "top-left", "top-center", "top-right", "center-left", "center", "center-right", "bottom-left", "bottom-center", "bottom-right"
        - bounding_box: CRITICAL - Please provide accurate bounding box for EVERY item to help users identify them visually. Use normalized coordinates (0.0-1.0):
          * x: left edge position (0=left edge of image, 1=right edge)
          * y: top edge position (0=top edge of image, 1=bottom edge)  
          * width: item width as percentage of image (0-1)
          * height: item height as percentage of image (0-1)
          Example: An item in the center taking up 20% of image would be: {"x": 0.4, "y": 0.4, "width": 0.2, "height": 0.2}
        
        For storage areas:
        - name: What it is (closet, drawer, shelf)
        - type: Use ONLY: "closet", "drawer", "shelf", "desk", "cabinet", "bin", "floor", "other"
        - location: Where in room (left wall, by window)
        
        Return JSON:
        {
          "items": [
            {
              "label": "red Nike shoe", 
              "category": "clothing", 
              "brand": "Nike", 
              "confidence": 0.9,
              "location": "bottom-left",
              "bounding_box": {"x": 0.1, "y": 0.7, "width": 0.15, "height": 0.2}
            }
          ],
          "storage_areas": [
            {"name": "wooden dresser", "type": "drawer", "location": "left wall"}
          ],
          "room_messiness": 7
        }
        """
        
        let result = try await openAIService.analyzeImage(image, prompt: prompt)
        return (items: result.items, storage: result.storage, analyzedImage: image)
    }
    
    private func detectStorageAndMissedItems(_ image: UIImage, existingItems: NSMutableSet) async throws -> (items: [DetectedItem], storage: [StorageArea], analyzedImage: UIImage) {
        let itemsList = existingItems.allObjects.compactMap { $0 as? String }.joined(separator: ", ")
        
        let prompt = """
        Second pass - focus on items that might have been missed:
        1. Small items (pens, cables, coins, jewelry)
        2. Items in piles or stacks (count each item)
        3. Partially hidden items
        4. Items in shadows or corners
        5. Additional storage areas not previously identified
        
        Previous items found (DO NOT repeat these): \(itemsList)
        
        For each item provide the SAME detailed information as before:
        - label: Specific description
        - category: Use ONLY the allowed categories from the first pass
        - brand: If recognizable or null
        - confidence: 0.0-1.0
        - location: CRITICAL - Use ONLY: "top-left", "top-center", "top-right", "center-left", "center", "center-right", "bottom-left", "bottom-center", "bottom-right"
        - bounding_box: CRITICAL - Normalized coordinates (0.0-1.0) with x, y, width, height
        
        Return JSON in this exact format:
        {
          "items": [
            {
              "label": "...", 
              "category": "...", 
              "brand": "...", 
              "confidence": 0.9,
              "location": "bottom-left",
              "bounding_box": {"x": 0.1, "y": 0.7, "width": 0.15, "height": 0.2}
            }
          ],
          "storage_areas": [
            {"name": "...", "type": "...", "location": "..."}
          ]
        }
        
        Only include NEW items and storage areas not already found.
        """
        
        let result = try await openAIService.analyzeImage(image, prompt: prompt)
        return (items: result.items, storage: result.storage, analyzedImage: result.analyzedImage)
    }
    
    private func deduplicateItems(_ items: [DetectedItem], seen: NSMutableSet) -> [DetectedItem] {
        var uniqueItems: [DetectedItem] = []
        
        for item in items {
            let normalizedLabel = item.label.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
            
            if !seen.contains(normalizedLabel) {
                seen.add(normalizedLabel)
                uniqueItems.append(item)
            }
        }
        
        return uniqueItems
    }
    
    private func matchItemsToStorage(items: [DetectedItem], storage: [StorageArea]) -> [DetectedItem] {
        return items.map { item in
            var updatedItem = item
            
            // Smart matching based on category
            switch item.category {
            case .clothing:
                if let closet = storage.first(where: { $0.type == .closet }) {
                    updatedItem.suggestedStorage = "\(closet.name) (\(closet.location))"
                } else if let drawer = storage.first(where: { $0.type == .drawer && $0.name.lowercased().contains("dress") }) {
                    updatedItem.suggestedStorage = "\(drawer.name) (\(drawer.location))"
                } else {
                    updatedItem.suggestedStorage = "Closet or dresser"
                }
                
            case .books:
                if let shelf = storage.first(where: { $0.type == .shelf }) {
                    updatedItem.suggestedStorage = "\(shelf.name) (\(shelf.location))"
                } else {
                    updatedItem.suggestedStorage = "Bookshelf or desk"
                }
                
            case .papers:
                if let desk = storage.first(where: { $0.type == .desk }) {
                    updatedItem.suggestedStorage = "\(desk.name) area"
                } else {
                    updatedItem.suggestedStorage = "Desk or file organizer"
                }
                
            case .electronics:
                if let desk = storage.first(where: { $0.type == .desk }) {
                    updatedItem.suggestedStorage = "\(desk.name) area"
                } else {
                    updatedItem.suggestedStorage = "Desk or charging station"
                }
                
            case .trash:
                updatedItem.suggestedStorage = "Trash bin"
                
            case .personalCare:
                if let drawer = storage.first(where: { $0.type == .drawer && $0.location.lowercased().contains("bath") }) {
                    updatedItem.suggestedStorage = "\(drawer.name)"
                } else {
                    updatedItem.suggestedStorage = "Bathroom or dresser drawer"
                }
                
            case .bedding:
                if let closet = storage.first(where: { $0.type == .closet && $0.name.lowercased().contains("linen") }) {
                    updatedItem.suggestedStorage = "\(closet.name)"
                } else {
                    updatedItem.suggestedStorage = "Linen closet or clean bed"
                }
                
            case .furniture:
                updatedItem.suggestedStorage = "Leave in place or rearrange for better flow"
                
            case .decor:
                if let shelf = storage.first(where: { $0.type == .shelf }) {
                    updatedItem.suggestedStorage = "\(shelf.name) or wall display"
                } else {
                    updatedItem.suggestedStorage = "Shelf, wall, or display area"
                }
                
            case .toys:
                if let bin = storage.first(where: { $0.type == .bin }) {
                    updatedItem.suggestedStorage = "\(bin.name)"
                } else {
                    updatedItem.suggestedStorage = "Toy box or storage bin"
                }
                
            case .office:
                if let desk = storage.first(where: { $0.type == .desk }) {
                    updatedItem.suggestedStorage = "\(desk.name) drawer or organizer"
                } else {
                    updatedItem.suggestedStorage = "Desk drawer or pencil holder"
                }
                
            case .dishes:
                updatedItem.suggestedStorage = "Kitchen (take immediately)"
                
            case .food:
                updatedItem.suggestedStorage = "Kitchen or trash (check expiration)"
                
            default:
                updatedItem.suggestedStorage = "Appropriate storage area"
            }
            
            return updatedItem
        }
    }
    
    private func generateOrganizationSuggestions(items: [DetectedItem]) -> [String] {
        var suggestions: [String] = []
        
        // Count items by category
        let categoryCounts = Dictionary(grouping: items, by: { $0.category })
            .mapValues { $0.count }
        
        // Generate category-specific suggestions
        if let clothingCount = categoryCounts[.clothing], clothingCount > 5 {
            suggestions.append("Start with clothing - gather all \(clothingCount) pieces and sort by type")
        }
        
        if let trashCount = categoryCounts[.trash], trashCount > 0 {
            suggestions.append("Quick win: Collect all \(trashCount) trash items first")
        }
        
        if let electronicsCount = categoryCounts[.electronics], electronicsCount > 3 {
            suggestions.append("Create a charging station for your \(electronicsCount) electronic items")
        }
        
        // Add general suggestions
        suggestions.append("Work on one category at a time to avoid overwhelm")
        suggestions.append("Take a 5-minute break after every 10 items")
        
        return suggestions
    }
    
    private func calculateOverallConfidence(_ items: [DetectedItem]) -> Double {
        guard !items.isEmpty else { return 0.0 }
        
        let totalConfidence = items.reduce(0.0) { $0 + $1.confidence }
        return totalConfidence / Double(items.count)
    }
    
    private func createCroppedImages(for items: [DetectedItem], from image: UIImage, photoIndex: Int) -> [DetectedItem] {
        var croppedCount = 0
        var fallbackCount = 0
        var noCropCount = 0
        
        // Create debug visualization if enabled
        var cropRectangles: [(rect: CGRect, label: String, isAccurate: Bool)] = []
        
        let updatedItems = items.map { item in
            var updatedItem = item
            
            // CRITICAL: Set the photo index so we know which photo this item belongs to
            updatedItem.photoIndex = photoIndex
            
            // Debug logging
            print("🔍 Processing crop for: \(item.label) from photo \(photoIndex + 1)")
            print("   Location: \(item.location ?? "nil")")
            print("   Bounding box: \(item.boundingBox != nil ? "Present" : "nil")")
            
            // Try to create cropped image based on bounding box or location
            if let boundingBox = item.boundingBox {
                // Use precise bounding box if available
                print("   Using bounding box: x=\(boundingBox.origin.x), y=\(boundingBox.origin.y), w=\(boundingBox.width), h=\(boundingBox.height)")
                updatedItem.croppedImage = cropImage(image, to: boundingBox)
                cropRectangles.append((rect: boundingBox, label: item.label, isAccurate: true))
                if updatedItem.croppedImage != nil {
                    croppedCount += 1
                    print("   ✅ Created precise crop")
                } else {
                    print("   ❌ Failed to create precise crop")
                }
            } else if let location = item.location {
                // Use approximate location-based crop
                let approximateBox = getApproximateBoundingBox(for: location)
                print("   Using fallback grid crop for '\(location)': x=\(approximateBox.origin.x), y=\(approximateBox.origin.y), w=\(approximateBox.width), h=\(approximateBox.height)")
                updatedItem.croppedImage = cropImage(image, to: approximateBox)
                cropRectangles.append((rect: approximateBox, label: "\(item.label) [\(location)]", isAccurate: false))
                if updatedItem.croppedImage != nil {
                    fallbackCount += 1
                    print("   ✅ Created fallback crop")
                } else {
                    print("   ❌ Failed to create fallback crop")
                }
            } else {
                noCropCount += 1
                print("   ⚠️ No location or bounding box available")
            }
            
            return updatedItem
        }
        
        // Save debug visualization if in debug mode
        #if DEBUG
        if APIConfiguration.logAPIRequests && !cropRectangles.isEmpty {
            saveDebugVisualization(image: image, cropRectangles: cropRectangles, photoIndex: photoIndex)
            
            // Also save a test crop to verify coordinates
            if let firstItem = items.first, let firstRect = cropRectangles.first {
                saveTestCrop(image: image, item: firstItem, rect: firstRect.rect, photoIndex: photoIndex)
            }
        }
        #endif
        
        if APIConfiguration.logAPIRequests {
            print("📸 Crop Summary: \(croppedCount) precise, \(fallbackCount) fallback, \(noCropCount) no crop out of \(items.count) items")
        }
        
        return updatedItems
    }
    
    private func normalizeImageOrientation(_ image: UIImage) -> UIImage? {
        guard image.imageOrientation != .up else { return image }
        
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: image.size))
        let normalizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return normalizedImage
    }
    
    private func cropImage(_ image: UIImage, to normalizedRect: CGRect) -> UIImage? {
        // First normalize the image orientation
        guard let normalizedImage = normalizeImageOrientation(image) else {
            print("❌ Failed to normalize image orientation")
            return nil
        }
        
        guard let cgImage = normalizedImage.cgImage else { 
            print("❌ Failed to get CGImage from UIImage")
            return nil 
        }
        
        // Convert normalized coordinates to pixel coordinates
        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        
        print("📐 Image dimensions: \(imageWidth) x \(imageHeight)")
        print("📐 Normalized rect: \(normalizedRect)")
        
        let cropRect = CGRect(
            x: normalizedRect.origin.x * imageWidth,
            y: normalizedRect.origin.y * imageHeight,
            width: normalizedRect.width * imageWidth,
            height: normalizedRect.height * imageHeight
        )
        
        print("📐 Pixel crop rect: \(cropRect)")
        
        // Ensure the crop rect is within bounds
        let boundedRect = cropRect.intersection(CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        
        print("📐 Bounded rect: \(boundedRect)")
        
        // Skip if the crop rect is too small or invalid
        guard boundedRect.width > 10 && boundedRect.height > 10 else { 
            print("❌ Crop rect too small: \(boundedRect.width) x \(boundedRect.height)")
            return nil 
        }
        
        guard let croppedCGImage = cgImage.cropping(to: boundedRect) else { 
            print("❌ CGImage cropping failed")
            return nil 
        }
        
        // Create UIImage from cropped CGImage (orientation already normalized)
        let croppedImage = UIImage(cgImage: croppedCGImage)
        
        print("✅ Created cropped image")
        
        // Resize to thumbnail size for memory efficiency (UI shows 50x50)
        let thumbnailSize = CGSize(width: 150, height: 150)  // 3x for retina
        
        UIGraphicsBeginImageContextWithOptions(thumbnailSize, false, 0.0)
        croppedImage.draw(in: CGRect(origin: .zero, size: thumbnailSize))
        let thumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return thumbnail
    }
    
    private func getApproximateBoundingBox(for location: String) -> CGRect {
        // Create approximate bounding boxes based on location strings
        // Reduced size for more focused crops
        let size: CGFloat = 0.12  // 12% of image dimension (was 20%)
        let margin: CGFloat = 0.08  // 8% margin from edges (was 5%)
        
        // Calculate position based on grid location
        // Using a more precise positioning system
        switch location {
        case "top-left":
            return CGRect(x: margin, y: margin, width: size, height: size)
        case "top-center":
            return CGRect(x: 0.5 - size/2, y: margin, width: size, height: size)
        case "top-right":
            return CGRect(x: 1.0 - size - margin, y: margin, width: size, height: size)
        case "center-left":
            return CGRect(x: margin, y: 0.5 - size/2, width: size, height: size)
        case "center":
            return CGRect(x: 0.5 - size/2, y: 0.5 - size/2, width: size, height: size)
        case "center-right":
            return CGRect(x: 1.0 - size - margin, y: 0.5 - size/2, width: size, height: size)
        case "bottom-left":
            return CGRect(x: margin, y: 1.0 - size - margin, width: size, height: size)
        case "bottom-center":
            return CGRect(x: 0.5 - size/2, y: 1.0 - size - margin, width: size, height: size)
        case "bottom-right":
            return CGRect(x: 1.0 - size - margin, y: 1.0 - size - margin, width: size, height: size)
        default:
            // Default to center if location is unknown
            return CGRect(x: 0.5 - size/2, y: 0.5 - size/2, width: size, height: size)
        }
    }
    
    #if DEBUG
    private func saveDebugVisualization(image: UIImage, cropRectangles: [(rect: CGRect, label: String, isAccurate: Bool)], photoIndex: Int) {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        // Draw the original image
        image.draw(at: .zero)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        // Draw crop rectangles
        for (index, cropInfo) in cropRectangles.enumerated() {
            let rect = cropInfo.rect
            let label = cropInfo.label
            let isAccurate = cropInfo.isAccurate
            
            // Convert normalized coordinates to image coordinates
            let imageRect = CGRect(
                x: rect.origin.x * image.size.width,
                y: rect.origin.y * image.size.height,
                width: rect.width * image.size.width,
                height: rect.height * image.size.height
            )
            
            // Set color based on accuracy
            context.setStrokeColor(isAccurate ? UIColor.green.cgColor : UIColor.orange.cgColor)
            context.setLineWidth(3.0)
            context.stroke(imageRect)
            
            // Draw label
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.boldSystemFont(ofSize: 16),
                .foregroundColor: UIColor.white,
                .backgroundColor: isAccurate ? UIColor.green : UIColor.orange
            ]
            
            let labelSize = label.size(withAttributes: attributes)
            let labelRect = CGRect(
                x: imageRect.minX,
                y: imageRect.minY - labelSize.height - 2,
                width: labelSize.width + 8,
                height: labelSize.height + 4
            )
            
            // Draw label background
            context.setFillColor(isAccurate ? UIColor.green.cgColor : UIColor.orange.cgColor)
            context.fill(labelRect)
            
            // Draw label text
            label.draw(in: CGRect(x: labelRect.minX + 4, y: labelRect.minY + 2, width: labelRect.width - 8, height: labelRect.height - 4), withAttributes: attributes)
        }
        
        // Get the annotated image
        let annotatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save to documents directory
        if let annotatedImage = annotatedImage,
           let data = annotatedImage.jpegData(compressionQuality: 0.8) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "debug_crops_\(Date().timeIntervalSince1970)_photo\(photoIndex + 1).jpg"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("🎨 Debug visualization saved to: \(fileURL.path)")
            } catch {
                print("❌ Failed to save debug visualization: \(error)")
            }
        }
    }
    
    private func saveTestCrop(image: UIImage, item: DetectedItem, rect: CGRect, photoIndex: Int) {
        // Create a test visualization showing the original image with the crop area highlighted
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        
        // Draw the original image
        image.draw(at: .zero)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return
        }
        
        // Draw a semi-transparent overlay
        context.setFillColor(UIColor.black.withAlphaComponent(0.5).cgColor)
        context.fill(CGRect(origin: .zero, size: image.size))
        
        // Clear the crop area to show it clearly
        let cropRect = CGRect(
            x: rect.origin.x * image.size.width,
            y: rect.origin.y * image.size.height,
            width: rect.width * image.size.width,
            height: rect.height * image.size.height
        )
        
        context.setBlendMode(.clear)
        context.fill(cropRect)
        context.setBlendMode(.normal)
        
        // Draw a bright border around the crop area
        context.setStrokeColor(UIColor.yellow.cgColor)
        context.setLineWidth(5.0)
        context.stroke(cropRect)
        
        // Add label
        let label = "\(item.label) - \(item.location ?? "no location")"
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 40),
            .foregroundColor: UIColor.yellow,
            .backgroundColor: UIColor.black
        ]
        
        label.draw(at: CGPoint(x: 20, y: 20), withAttributes: attributes)
        
        // Get the test image
        let testImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Save it
        if let testImage = testImage,
           let data = testImage.jpegData(compressionQuality: 0.8) {
            let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileName = "test_crop_photo\(photoIndex + 1)_\(Date().timeIntervalSince1970).jpg"
            let fileURL = documentsPath.appendingPathComponent(fileName)
            
            do {
                try data.write(to: fileURL)
                print("🎯 Test crop visualization saved to: \(fileURL.path)")
            } catch {
                print("❌ Failed to save test crop: \(error)")
            }
        }
    }
    #endif
    
    // MARK: - Prompts
    private func generatePrompt(for pass: Int, previousItems: [DetectedItem] = []) -> String {
        switch pass {
        case 1:
            return """
            Analyze this room image and identify EVERY item that needs to be cleaned up or organized.
            
            The image has a 5x5 grid overlay with cells labeled A1-E5.
            
            For each item, provide:
            1. Item name/description
            2. Category (clothing, electronics, books, papers, dishes, toys, bedding, office_supplies, furniture, personal_items, decor, other)
            3. Grid cell location (e.g., "B3" for single cell, or "B2-C3" for items spanning multiple cells)
            4. Confidence (0.0-1.0)
            
            Focus on:
            - Items that are out of place
            - Things on the floor, bed, desk, or other surfaces
            - Objects that need to be put away
            
            Return ONLY a JSON array with this EXACT format:
            ```json
            {
                "items": [
                    {
                        "label": "Red backpack",
                        "category": "personal_items",
                        "grid_cells": "C3",
                        "confidence": 0.95
                    }
                ]
            }
            ```
            
            Be thorough - detect ALL items, even partially visible ones.
            """
            
        case 2:
            let previousLabels = previousItems.map { $0.label }.joined(separator: ", ")
            return """
            Look for ADDITIONAL items not found in the first pass.
            Already found: \(previousLabels)
            
            The image has a 5x5 grid overlay with cells labeled A1-E5.
            
            Search specifically for:
            - Small items (pens, cables, jewelry, coins)
            - Items in cluttered areas
            - Things partially hidden by other objects
            - Items in shadows or poor lighting
            
            For each NEW item found, provide the same format with grid cell locations.
            
            Return ONLY a JSON array:
            ```json
            {
                "items": [
                    {
                        "label": "Phone charger cable",
                        "category": "electronics",
                        "grid_cells": "D4-D5",
                        "confidence": 0.85
                    }
                ]
            }
            ```
            """
            
        default:
            return ""
        }
    }
    
    // Update the processDetectionResponse method
    private func processDetectionResponse(_ response: String, photoIndex: Int, photo: UIImage, compressedPhoto: UIImage) -> [DetectedItem] {
        // Extract JSON from response
        let jsonString: String
        if let jsonStart = response.range(of: "```json")?.upperBound,
           let jsonEnd = response.range(of: "```", options: .backwards, range: jsonStart..<response.endIndex)?.lowerBound {
            jsonString = String(response[jsonStart..<jsonEnd]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if let jsonStart = response.firstIndex(of: "{"),
                  let jsonEnd = response.lastIndex(of: "}") {
            jsonString = String(response[jsonStart...jsonEnd])
        } else {
            print("MultiPassVisionAnalyzer: No JSON found in response")
            return []
        }
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("MultiPassVisionAnalyzer: Failed to convert JSON string to data")
            return []
        }
        
        do {
            let decoder = JSONDecoder()
            let detectionResult = try decoder.decode(GridDetectionResponse.self, from: jsonData)
            
            return detectionResult.items.compactMap { item in
                // Convert grid cells to bounding box
                let gridRects = GridOverlayService.parseCellRange(
                    item.gridCells,
                    imageSize: compressedPhoto.size
                )
                
                guard let boundingBox = gridRects.first else {
                    print("MultiPassVisionAnalyzer: Failed to parse grid cells: \(item.gridCells)")
                    return nil
                }
                
                // Create cropped image from the compressed photo using grid coordinates
                let croppedImage = cropImage(compressedPhoto, boundingBox: boundingBox)
                
                // Map category string to enum
                let category = ItemCategory(rawValue: item.category) ?? .other
                
                return DetectedItem(
                    label: item.label,
                    category: category,
                    brand: nil,
                    suggestedStorage: "",
                    confidence: item.confidence,
                    location: "Grid \(item.gridCells)",
                    boundingBox: boundingBox,
                    croppedImage: croppedImage,
                    photoIndex: photoIndex
                )
            }
        } catch {
            print("MultiPassVisionAnalyzer: Failed to parse detection response: \(error)")
            print("Response was: \(jsonString)")
            return []
        }
    }
    
    // Add new response structure for grid-based detection
    private struct GridDetectionResponse: Codable {
        let items: [GridDetectedItem]
    }
    
    private struct GridDetectedItem: Codable {
        let label: String
        let category: String
        let gridCells: String
        let confidence: Float
        
        enum CodingKeys: String, CodingKey {
            case label
            case category
            case gridCells = "grid_cells"
            case confidence
        }
    }
}

// Using OpenAIResponse from OpenAIService