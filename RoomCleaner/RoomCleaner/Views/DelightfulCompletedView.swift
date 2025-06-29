import SwiftUI

struct DelightfulCompletedView: View {
    @EnvironmentObject var appState: AppState
    @State private var showConfetti = false
    @State private var shareSheet = false
    
    var totalItems: Int {
        appState.detectedObjects.count
    }
    
    var body: some View {
        VStack(spacing: 30) {
            // Celebration Header
            VStack(spacing: 20) {
                ZStack {
                    // Animated circles
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 150 + CGFloat(index * 50), 
                                   height: 150 + CGFloat(index * 50))
                            .scaleEffect(showConfetti ? 1.1 : 0.9)
                            .animation(
                                .easeInOut(duration: 2)
                                .repeatForever(autoreverses: true)
                                .delay(Double(index) * 0.2),
                                value: showConfetti
                            )
                    }
                    
                    Image(systemName: "star.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.yellow)
                        .rotationEffect(.degrees(showConfetti ? 10 : -10))
                        .animation(
                            .easeInOut(duration: 0.5)
                            .repeatForever(autoreverses: true),
                            value: showConfetti
                        )
                }
                .frame(height: 200)
                
                Text("Room Complete! 🎉")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("You did an amazing job!")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            
            // Stats Card
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading) {
                        Text("\(totalItems)")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.blue)
                        Text("items organized")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text("100%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundColor(.green)
                        Text("complete")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Category breakdown
                VStack(spacing: 12) {
                    Text("What you organized:")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    let categoryCounts = Dictionary(grouping: appState.detectedObjects) { $0.category }
                        .mapValues { $0.count }
                        .sorted { $0.value > $1.value }
                    
                    ForEach(categoryCounts, id: \.key) { category, count in
                        HStack {
                            Text(category.emoji)
                            Text(category.displayName)
                                .font(.subheadline)
                            Spacer()
                            Text("\(count) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(20)
            .shadow(radius: 10)
            .padding(.horizontal)
            
            Spacer()
            
            // Action Buttons
            VStack(spacing: 12) {
                Button(action: { shareSheet = true }) {
                    Label("Share Achievement", systemImage: "square.and.arrow.up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                
                Button(action: startNewSession) {
                    Label("Clean Another Room", systemImage: "arrow.clockwise")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            showConfetti = true
        }
        .sheet(isPresented: $shareSheet) {
            ShareSheet(text: "I just organized \(totalItems) items in my room using Room Cleaner! 🎉")
        }
    }
    
    private func startNewSession() {
        // Reset app state
        appState.currentPhase = .welcome
        appState.roomPhotos = []
        appState.detectedObjects = []
        appState.cleaningPlan = nil
        appState.currentTaskIndex = 0
        appState.completedTasks = []
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let text: String
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
} 