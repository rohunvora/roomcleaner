import SwiftUI

struct AnalyzingView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var analyzer = MultiPassVisionAnalyzer.shared
    @State private var dots = ""
    @State private var hasStartedAnalysis = false
    @State private var detectionResult: MultiPassVisionAnalyzer.DetectionResult?
    @State private var showError = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(animationScale(for: index))
                        .opacity(animationOpacity(for: index))
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever()
                            .delay(Double(index) * 0.3),
                            value: dots
                        )
                }
                
                Image(systemName: "brain")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 20) {
                Text("AI is analyzing your room\(dots)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if !analyzer.currentPass.isEmpty {
                    Text(analyzer.currentPass)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Progress bar
                ProgressView(value: analyzer.progress)
                    .frame(width: 200)
                    .tint(.blue)
                
                VStack(spacing: 10) {
                    AnalysisStep(text: "Identifying items", isActive: analyzer.progress > 0)
                    AnalysisStep(text: "Finding storage areas", isActive: analyzer.progress > 0.3)
                    AnalysisStep(text: "Creating organization plan", isActive: analyzer.progress > 0.7)
                }
                .padding(.top, 20)
            }
            
            Spacer()
            
            if let error = analyzer.detectionError {
                VStack(spacing: 10) {
                    Text("Detection Issue")
                        .font(.headline)
                    Text(error.localizedDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Button("Continue Anyway") {
                        // Move to manual addition
                        appState.currentPhase = .cleaning
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.orange.opacity(0.1))
                .cornerRadius(10)
                .padding(.horizontal)
            }

            Text("Preparing images...")
                .font(.headline)
                .foregroundColor(.white)
            
            Text("Adding grid overlay for precise detection")
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .padding(.top, 4)
        }
        .onAppear {
            animateDots()
            if !hasStartedAnalysis {
                startAnalysis()
            }
        }
    }
    
    func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { timer in
            if dots.count < 3 {
                dots += "."
            } else {
                dots = ""
            }
            
            // Stop timer when analysis is complete
            if analyzer.progress >= 1.0 {
                timer.invalidate()
            }
        }
    }
    
    func startAnalysis() {
        hasStartedAnalysis = true
        
        Task {
            do {
                // Convert UIImage array to the format needed
                let photos = appState.roomPhotos.map { $0.image }
                
                let result = try await analyzer.analyzePhotos(photos)
                
                await MainActor.run {
                    detectionResult = result
                    
                    // Update app state with results
                    appState.detectedObjects = result.items
                    appState.compressedPhotos = result.compressedPhotos  // Store compressed versions
                    
                    // Generate cleaning plan
                    generateCleaningPlan(from: result)
                    
                    // Move to next phase
                    appState.currentPhase = .cleaning
                }
            } catch {
                await MainActor.run {
                    analyzer.detectionError = error
                    showError = true
                }
            }
        }
    }
    
    func generateCleaningPlan(from result: MultiPassVisionAnalyzer.DetectionResult) {
        // Check if we have any items
        if result.items.isEmpty {
            print("⚠️ No items detected, creating default plan")
            
            // Create a minimal plan with guidance
            let plan = CleaningPlan(
                tasks: [
                    CleaningTask(
                        title: "Manual Room Check",
                        items: ["Look around for items to organize", "Check surfaces for clutter", "Identify things out of place"],
                        detectedItems: [],  // No detected items in manual mode
                        category: "General",
                        estimatedMinutes: 10,
                        referenceImage: appState.roomPhotos.first?.image
                    )
                ],
                totalItems: 0,
                estimatedTime: 10,
                categories: [CategoryCount(name: "General", itemCount: 0, priority: 1)]
            )
            
            appState.startCleaning(with: plan)
            return
        }
        
        // Group items by category
        let groupedItems = Dictionary(grouping: result.items) { $0.category }
        
        // Create tasks
        var tasks: [CleaningTask] = []
        
        for (category, items) in groupedItems.sorted(by: { $0.value.count > $1.value.count }) {
            let task = CleaningTask(
                title: "Organize \(category.displayName)",
                items: items.map { $0.label },
                detectedItems: items,
                category: category.displayName,
                estimatedMinutes: max(3, items.count * 2),
                referenceImage: appState.roomPhotos.first?.image
            )
            tasks.append(task)
        }
        
        // Create cleaning plan
        let plan = CleaningPlan(
            tasks: tasks,
            totalItems: result.totalItemsFound,
            estimatedTime: tasks.reduce(0) { $0 + $1.estimatedMinutes },
            categories: groupedItems.map { 
                CategoryCount(name: $0.key.displayName, itemCount: $0.value.count, priority: 1)
            }
        )
        
        appState.startCleaning(with: plan)
    }
    
    func animationScale(for index: Int) -> CGFloat {
        return dots.isEmpty ? 1.0 : 2.0
    }
    
    func animationOpacity(for index: Int) -> Double {
        return dots.isEmpty ? 1.0 : 0.0
    }
}

struct AnalysisStep: View {
    let text: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            if isActive {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            Text(text)
                .foregroundColor(isActive ? .primary : .secondary)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}