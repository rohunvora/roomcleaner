import SwiftUI

struct CompletedView: View {
    @EnvironmentObject var appState: AppState
    @State private var showConfetti = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success Animation
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.1))
                    .frame(width: 150, height: 150)
                    .scaleEffect(showConfetti ? 1.2 : 1.0)
                
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.green)
                    .scaleEffect(showConfetti ? 1.1 : 1.0)
            }
            .animation(.spring(response: 0.6, dampingFraction: 0.6), value: showConfetti)
            
            VStack(spacing: 20) {
                Text("Room Cleaned!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                if let plan = appState.cleaningPlan {
                    VStack(spacing: 10) {
                        StatRow(label: "Items organized", value: "\(plan.totalItems)")
                        StatRow(label: "Tasks completed", value: "\(plan.tasks.count)")
                        StatRow(label: "Time saved", value: "~\(plan.estimatedTime) min")
                    }
                    .padding()
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(15)
                }
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: { /* Show before/after */ }) {
                    Label("View Before & After", systemImage: "photo.on.rectangle")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                Button(action: { resetApp() }) {
                    Text("Start New Session")
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation {
                showConfetti = true
            }
        }
    }
    
    func resetApp() {
        appState.currentPhase = .welcome
        appState.roomPhotos = []
        appState.cleaningPlan = nil
        appState.completedTasks = []
        appState.currentTaskIndex = 0
    }
}

struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}