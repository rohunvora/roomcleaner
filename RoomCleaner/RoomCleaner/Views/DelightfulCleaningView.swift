import SwiftUI

struct DelightfulCleaningView: View {
    @EnvironmentObject var appState: AppState
    @State private var selectedCategory: ItemCategory?
    @State private var completedItems: Set<UUID> = []
    @State private var showCelebration = false
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var showBreakReminder = false
    @State private var streak = 0
    @State private var pointsEarned = 0
    
    var categorizedItems: [ItemCategory: [DetectedItem]] {
        Dictionary(grouping: appState.detectedObjects) { $0.category }
    }
    
    var currentCategoryItems: [DetectedItem] {
        guard let category = selectedCategory else { return [] }
        return categorizedItems[category] ?? []
    }
    
    var totalProgress: Double {
        guard !appState.detectedObjects.isEmpty else { return 0 }
        return Double(completedItems.count) / Double(appState.detectedObjects.count)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Fun Header with Progress
            VStack(spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Let's Clean! 🎯")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text(motivationalMessage())
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("\(Int(totalProgress * 100))%")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("\(streak)")
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                    }
                }
                
                // Animated Progress Bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 20)
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(LinearGradient(
                            colors: [Color.green, Color.blue],
                            startPoint: .leading,
                            endPoint: .trailing
                        ))
                        .frame(width: max(0, totalProgress * UIScreen.main.bounds.width - 40), height: 20)
                        .animation(.spring(), value: totalProgress)
                }
                
                // Timer and Stats
                HStack {
                    Label(formatTime(elapsedTime), systemImage: "timer")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Label("\(completedItems.count)/\(appState.detectedObjects.count) items", 
                          systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .shadow(radius: 2)
            
            // Category Selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(categorizedItems.keys.sorted(by: { 
                        categorizedItems[$0]!.count > categorizedItems[$1]!.count 
                    }), id: \.self) { category in
                        CategoryButton(
                            category: category,
                            count: categorizedItems[category]!.count,
                            completedCount: categorizedItems[category]!.filter { 
                                completedItems.contains($0.id) 
                            }.count,
                            isSelected: selectedCategory == category,
                            action: { 
                                withAnimation(.spring()) {
                                    selectedCategory = category
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            
            // Content Area
            if let category = selectedCategory {
                ScrollView {
                    VStack(spacing: 16) {
                        // Category Header
                        HStack {
                            Text("\(category.emoji) \(category.displayName)")
                                .font(.title3)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            Text("\(currentCategoryItems.filter { completedItems.contains($0.id) }.count)/\(currentCategoryItems.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        // Visual Reference Image with highlighted areas
                        if !currentCategoryItems.isEmpty {
                            // Group items by photo to show the correct reference
                            let itemsByPhoto = Dictionary(grouping: currentCategoryItems) { $0.photoIndex }
                            
                            ForEach(itemsByPhoto.keys.sorted(), id: \.self) { photoIndex in
                                if photoIndex < appState.compressedPhotos.count {
                                    let compressedPhoto = appState.compressedPhotos[photoIndex]
                                    let originalPhoto = photoIndex < appState.roomPhotos.count ? appState.roomPhotos[photoIndex] : nil
                                    let itemsInThisPhoto = itemsByPhoto[photoIndex] ?? []
                                    
                                    VStack(alignment: .leading, spacing: 8) {
                                        Text("Photo \(photoIndex + 1) - \(originalPhoto?.area ?? "Unknown")")
                                            .font(.headline)
                                            .padding(.horizontal)
                                        
                                        ZStack {
                                            Image(uiImage: compressedPhoto)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .cornerRadius(12)
                                            
                                            // Overlay showing item locations for this specific photo
                                            ItemLocationsOverlay(
                                                items: itemsInThisPhoto.filter { !completedItems.contains($0.id) },
                                                imageSize: compressedPhoto.size
                                            )
                                        }
                                        .frame(maxHeight: 250)
                                        .padding(.horizontal)
                                    }
                                }
                            }
                        }
                        
                        // Items List
                        VStack(spacing: 12) {
                            ForEach(currentCategoryItems) { item in
                                ItemCard(
                                    item: item,
                                    isCompleted: completedItems.contains(item.id),
                                    onToggle: { toggleItem(item) }
                                )
                            }
                        }
                        .padding(.horizontal)
                        
                        // Action Buttons
                        HStack(spacing: 12) {
                            Button(action: completeAllInCategory) {
                                Label("Complete All", systemImage: "checkmark.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                            
                            Button(action: { showBreakReminder = true }) {
                                Label("Take Break", systemImage: "pause.circle.fill")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.orange)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                    }
                }
            } else {
                // Welcome View
                VStack(spacing: 20) {
                    Spacer()
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Choose a category to start!")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    Text("Tap on any category above to begin")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("💡 Tip: Start with the smallest category for a quick win!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .sheet(isPresented: $showCelebration) {
            CelebrationView(
                itemsCompleted: completedItems.count,
                totalItems: appState.detectedObjects.count,
                onContinue: {
                    showCelebration = false
                    if totalProgress >= 1.0 {
                        appState.currentPhase = .completed
                    }
                }
            )
        }
        .sheet(isPresented: $showBreakReminder) {
            BreakReminderView()
        }
    }
    
    private func toggleItem(_ item: DetectedItem) {
        withAnimation(.spring()) {
            if completedItems.contains(item.id) {
                completedItems.remove(item.id)
                streak = max(0, streak - 1)
            } else {
                completedItems.insert(item.id)
                streak += 1
                
                // Check for milestones
                if completedItems.count % 5 == 0 && completedItems.count > 0 {
                    showCelebration = true
                }
            }
        }
    }
    
    private func completeAllInCategory() {
        withAnimation(.spring()) {
            for item in currentCategoryItems {
                completedItems.insert(item.id)
            }
            streak += currentCategoryItems.filter { !completedItems.contains($0.id) }.count
            showCelebration = true
        }
    }
    
    private func motivationalMessage() -> String {
        switch completedItems.count {
        case 0:
            return "Ready to make your space amazing?"
        case 1...5:
            return "Great start! Keep going!"
        case 6...10:
            return "You're on fire! 🔥"
        case 11...20:
            return "Incredible progress!"
        case 21...30:
            return "You're crushing it!"
        default:
            return "Almost there, champion!"
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            elapsedTime += 1
            
            // Break reminder every 15 minutes
            if elapsedTime.truncatingRemainder(dividingBy: 900) == 0 && elapsedTime > 0 {
                showBreakReminder = true
            }
        }
    }
}

// Category Button
struct CategoryButton: View {
    let category: ItemCategory
    let count: Int
    let completedCount: Int
    let isSelected: Bool
    let action: () -> Void
    
    var progress: Double {
        guard count > 0 else { return 0 }
        return Double(completedCount) / Double(count)
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(category.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(category.color, lineWidth: 3)
                        .frame(width: 60, height: 60)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut, value: progress)
                    
                    Text(category.emoji)
                        .font(.title2)
                }
                
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("\(completedCount)/\(count)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 4)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? category.color.opacity(0.1) : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Item Card
struct ItemCard: View {
    let item: DetectedItem
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 16) {
                // Checkbox
                ZStack {
                    Circle()
                        .stroke(isCompleted ? Color.green : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 28, height: 28)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.green)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .animation(.spring(), value: isCompleted)
                
                // Item thumbnail if available
                if let croppedImage = item.croppedImage {
                    Image(uiImage: croppedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50, height: 50)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(item.label)
                            .font(.body)
                            .fontWeight(.medium)
                            .strikethrough(isCompleted, color: .gray)
                            .foregroundColor(isCompleted ? .gray : .primary)
                        
                        if let location = item.location {
                            Text("(\(formatLocation(location)))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    if !item.suggestedStorage.isEmpty {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.caption2)
                                .foregroundColor(.blue)
                            
                            Text(item.suggestedStorage)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                Spacer()
                
                // Confidence dots
                if !isCompleted && item.confidence > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(index < Int(item.confidence * 3) ? Color.green : Color.gray.opacity(0.2))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isCompleted ? Color.green.opacity(0.05) : Color.gray.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isCompleted ? Color.green.opacity(0.3) : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    func formatLocation(_ location: String) -> String {
        // Make location strings more user-friendly
        switch location {
        case "top-left": return "top left"
        case "top-center": return "top"
        case "top-right": return "top right"
        case "center-left": return "left"
        case "center": return "center"
        case "center-right": return "right"
        case "bottom-left": return "bottom left"
        case "bottom-center": return "bottom"
        case "bottom-right": return "bottom right"
        default: return location
        }
    }
}

// Celebration View
struct CelebrationView: View {
    let itemsCompleted: Int
    let totalItems: Int
    let onContinue: () -> Void
    
    @State private var showAnimation = false
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "star.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
                .scaleEffect(showAnimation ? 1.2 : 1.0)
                .animation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever(autoreverses: true), value: showAnimation)
            
            Text("Awesome Progress!")
                .font(.title)
                .fontWeight(.bold)
            
            Text("You've completed \(itemsCompleted) of \(totalItems) items!")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Keep Going!") {
                onContinue()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue)
            .cornerRadius(12)
            .padding(.horizontal)
        }
        .padding()
        .onAppear {
            showAnimation = true
        }
        .presentationDetents([.medium])
    }
}

// Break Reminder
struct BreakReminderView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "pause.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.orange)
            
            Text("Time for a break!")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("💧")
                    Text("Drink some water")
                }
                HStack {
                    Text("🚶")
                    Text("Take a 5-minute walk")
                }
                HStack {
                    Text("🎵")
                    Text("Listen to your favorite song")
                }
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            
            Button("I'm refreshed!") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.orange)
            .cornerRadius(12)
        }
        .padding()
        .presentationDetents([.medium])
    }
}

// Item Locations Overlay
struct ItemLocationsOverlay: View {
    let items: [DetectedItem]
    let imageSize: CGSize
    
    var body: some View {
        GeometryReader { geometry in
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if let location = item.location {
                    ItemMarker(
                        number: index + 1,
                        location: location,
                        boundingBox: item.boundingBox,
                        viewSize: geometry.size
                    )
                }
            }
        }
    }
}

// Item Marker
struct ItemMarker: View {
    let number: Int
    let location: String
    let boundingBox: CGRect?
    let viewSize: CGSize
    
    var markerPosition: CGPoint {
        if let box = boundingBox {
            // Use center of bounding box
            return CGPoint(
                x: (box.origin.x + box.width / 2) * viewSize.width,
                y: (box.origin.y + box.height / 2) * viewSize.height
            )
        } else {
            // Use approximate position based on location string
            return getPositionForLocation(location, in: viewSize)
        }
    }
    
    var body: some View {
        ZStack {
            // Highlight area if bounding box available
            if let box = boundingBox {
                Rectangle()
                    .stroke(Color.blue, lineWidth: 2)
                    .background(Color.blue.opacity(0.1))
                    .frame(
                        width: box.width * viewSize.width,
                        height: box.height * viewSize.height
                    )
                    .position(
                        x: box.origin.x * viewSize.width + (box.width * viewSize.width) / 2,
                        y: box.origin.y * viewSize.height + (box.height * viewSize.height) / 2
                    )
            }
            
            // Number marker
            Circle()
                .fill(Color.blue)
                .frame(width: 30, height: 30)
                .overlay(
                    Text("\(number)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                )
                .shadow(radius: 2)
                .position(markerPosition)
        }
    }
    
    func getPositionForLocation(_ location: String, in size: CGSize) -> CGPoint {
        let insetPercent: CGFloat = 0.15
        
        switch location {
        case "top-left":
            return CGPoint(x: size.width * insetPercent, y: size.height * insetPercent)
        case "top-center":
            return CGPoint(x: size.width * 0.5, y: size.height * insetPercent)
        case "top-right":
            return CGPoint(x: size.width * (1 - insetPercent), y: size.height * insetPercent)
        case "center-left":
            return CGPoint(x: size.width * insetPercent, y: size.height * 0.5)
        case "center":
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        case "center-right":
            return CGPoint(x: size.width * (1 - insetPercent), y: size.height * 0.5)
        case "bottom-left":
            return CGPoint(x: size.width * insetPercent, y: size.height * (1 - insetPercent))
        case "bottom-center":
            return CGPoint(x: size.width * 0.5, y: size.height * (1 - insetPercent))
        case "bottom-right":
            return CGPoint(x: size.width * (1 - insetPercent), y: size.height * (1 - insetPercent))
        default:
            return CGPoint(x: size.width * 0.5, y: size.height * 0.5)
        }
    }
}
