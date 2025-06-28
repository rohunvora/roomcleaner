import SwiftUI

struct DetectionOverlayView: View {
    let image: UIImage
    let detectedObjects: [MultiPassVisionAnalyzer.DetectedObject]
    @State private var selectedObject: MultiPassVisionAnalyzer.DetectedObject?
    @State private var showingQuickAdd = false
    @State private var quickAddLocation: CGPoint = .zero
    @State private var manuallyAddedObjects: [MultiPassVisionAnalyzer.DetectedObject] = []
    @Binding var allObjects: [MultiPassVisionAnalyzer.DetectedObject]
    
    // Quick category buttons for fast labeling
    let quickCategories = [
        ("clothes", "tshirt.fill", Color.blue),
        ("electronics", "tv.fill", Color.orange),
        ("papers", "doc.fill", Color.gray),
        ("trash", "trash.fill", Color.red),
        ("misc", "questionmark.circle.fill", Color.purple)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Base image
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .onTapGesture { location in
                        // Quick tap to add missing item
                        quickAddLocation = location
                        showingQuickAdd = true
                    }
                
                // Detected object overlays
                ForEach(detectedObjects, id: \.id) { object in
                    BoundingBoxView(
                        object: object,
                        imageSize: image.size,
                        viewSize: geometry.size,
                        isSelected: selectedObject?.id == object.id
                    )
                    .onTapGesture {
                        selectedObject = object
                    }
                }
                
                // Manually added object overlays
                ForEach(manuallyAddedObjects, id: \.id) { object in
                    BoundingBoxView(
                        object: object,
                        imageSize: image.size,
                        viewSize: geometry.size,
                        isSelected: false,
                        isManual: true
                    )
                }
                
                // Quick add interface
                if showingQuickAdd {
                    QuickAddOverlay(
                        location: quickAddLocation,
                        imageSize: image.size,
                        viewSize: geometry.size,
                        onAdd: { label, category in
                            addManualObject(label: label, category: category, at: quickAddLocation, in: geometry.size)
                            showingQuickAdd = false
                        },
                        onCancel: {
                            showingQuickAdd = false
                        }
                    )
                }
            }
        }
        .overlay(alignment: .bottom) {
            // Status bar
            HStack {
                Label("\(detectedObjects.count + manuallyAddedObjects.count) items", systemImage: "checkmark.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)
                
                Spacer()
                
                if !manuallyAddedObjects.isEmpty {
                    Text("+\(manuallyAddedObjects.count) added")
                        .font(.subheadline)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(15)
                }
            }
            .padding()
        }
    }
    
    private func addManualObject(label: String, category: String, at location: CGPoint, in viewSize: CGSize) {
        // Convert tap location to percentage bounds
        let xPercent = Int((location.x / viewSize.width) * 100)
        let yPercent = Int((location.y / viewSize.height) * 100)
        
        let newObject = MultiPassVisionAnalyzer.DetectedObject(
            id: UUID().uuidString,
            label: label,
            confidence: 1.0, // Manual additions have full confidence
            boundingBox: MultiPassVisionAnalyzer.BoundingBox(
                x: max(0, xPercent - 5),
                y: max(0, yPercent - 5),
                width: 10,
                height: 10
            ),
            category: category,
            detectionPass: 99 // Special pass number for manual
        )
        
        manuallyAddedObjects.append(newObject)
        allObjects.append(newObject)
        
        // Save to training data
        saveTrainingData(object: newObject, image: image)
    }
    
    private func saveTrainingData(object: MultiPassVisionAnalyzer.DetectedObject, image: UIImage) {
        // TODO: Implement training data collection
        // This would save the image region and label for future model improvement
        print("Training data: \(object.label) at \(object.boundingBox)")
    }
}

struct BoundingBoxView: View {
    let object: MultiPassVisionAnalyzer.DetectedObject
    let imageSize: CGSize
    let viewSize: CGSize
    let isSelected: Bool
    var isManual: Bool = false
    
    private var boxFrame: CGRect {
        let scaleX = viewSize.width / imageSize.width
        let scaleY = viewSize.height / imageSize.height
        let scale = min(scaleX, scaleY)
        
        let scaledImageWidth = imageSize.width * scale
        let scaledImageHeight = imageSize.height * scale
        
        let offsetX = (viewSize.width - scaledImageWidth) / 2
        let offsetY = (viewSize.height - scaledImageHeight) / 2
        
        let x = offsetX + (CGFloat(object.boundingBox.x) / 100) * scaledImageWidth
        let y = offsetY + (CGFloat(object.boundingBox.y) / 100) * scaledImageHeight
        let width = (CGFloat(object.boundingBox.width) / 100) * scaledImageWidth
        let height = (CGFloat(object.boundingBox.height) / 100) * scaledImageHeight
        
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    var body: some View {
        Rectangle()
            .stroke(lineWidth: 2)
            .foregroundColor(boxColor)
            .frame(width: boxFrame.width, height: boxFrame.height)
            .position(x: boxFrame.midX, y: boxFrame.midY)
            .overlay(
                Text(object.label)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 2)
                    .background(boxColor.opacity(0.9))
                    .foregroundColor(.white)
                    .cornerRadius(4)
                    .position(x: boxFrame.midX, y: boxFrame.minY - 10)
            )
    }
    
    private var boxColor: Color {
        if isManual { return .green }
        if isSelected { return .yellow }
        
        switch object.detectionPass {
        case 1: return .blue
        case 2: return .orange
        case 3: return .purple
        case 4: return .pink
        default: return .gray
        }
    }
}

struct QuickAddOverlay: View {
    let location: CGPoint
    let imageSize: CGSize
    let viewSize: CGSize
    let onAdd: (String, String) -> Void
    let onCancel: () -> Void
    
    @State private var selectedCategory = "misc"
    @State private var customLabel = ""
    @FocusState private var isTextFieldFocused: Bool
    
    // Common items for quick selection
    let quickItems = [
        "shirt", "pants", "sock", "shoe",
        "phone", "charger", "cable", "headphones",
        "paper", "notebook", "pen", "book",
        "bottle", "wrapper", "bag", "tissue"
    ]
    
    var body: some View {
        VStack(spacing: 12) {
            // Quick item grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 4), spacing: 8) {
                ForEach(quickItems, id: \.self) { item in
                    Button(action: {
                        onAdd(item, selectedCategory)
                    }) {
                        Text(item)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 6)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
            }
            
            Divider()
            
            // Custom input
            HStack {
                TextField("Custom item", text: $customLabel)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isTextFieldFocused)
                    .onSubmit {
                        if !customLabel.isEmpty {
                            onAdd(customLabel, selectedCategory)
                        }
                    }
                
                Button("Add") {
                    if !customLabel.isEmpty {
                        onAdd(customLabel, selectedCategory)
                    }
                }
                .disabled(customLabel.isEmpty)
            }
            
            // Category selection
            HStack(spacing: 8) {
                ForEach(quickCategories, id: \.0) { category, icon, color in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Image(systemName: icon)
                            .foregroundColor(selectedCategory == category ? .white : color)
                            .padding(8)
                            .background(selectedCategory == category ? color : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(color, lineWidth: 2)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            
            // Cancel button
            Button("Cancel") {
                onCancel()
            }
            .foregroundColor(.red)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 10)
        .frame(width: 300)
        .position(x: min(max(150, location.x), viewSize.width - 150),
                  y: min(max(200, location.y), viewSize.height - 200))
        .onAppear {
            isTextFieldFocused = true
        }
    }
}

// Preview helpers
#if DEBUG
struct DetectionOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        DetectionOverlayView(
            image: UIImage(systemName: "photo")!,
            detectedObjects: [],
            allObjects: .constant([])
        )
    }
}
#endif