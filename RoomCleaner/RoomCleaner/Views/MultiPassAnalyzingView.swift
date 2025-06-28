import SwiftUI

struct MultiPassAnalyzingView: View {
    @EnvironmentObject var appState: AppState
    @State private var currentPass = 1
    @State private var passStatus: [Int: PassStatus] = [:]
    @State private var totalObjectsFound = 0
    @State private var isComplete = false
    
    struct PassStatus {
        let name: String
        let status: Status
        let objectCount: Int
        
        enum Status {
            case pending, running, complete, failed
        }
    }
    
    let passes = [
        "Scanning large items",
        "Checking floor areas",
        "Analyzing surfaces",
        "Finding small details"
    ]
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // Progress indicator
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: CGFloat(currentPass - 1) / 4.0)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: currentPass)
                
                VStack(spacing: 4) {
                    Text("\(totalObjectsFound)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    Text("items found")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Pass status list
            VStack(spacing: 16) {
                ForEach(1...4, id: \.self) { passNum in
                    PassStatusRow(
                        passNumber: passNum,
                        title: passes[passNum - 1],
                        status: passStatus[passNum] ?? PassStatus(
                            name: passes[passNum - 1],
                            status: passNum < currentPass ? .complete : (passNum == currentPass ? .running : .pending),
                            objectCount: 0
                        )
                    )
                }
            }
            .padding(.horizontal, 40)
            
            Spacer()
            
            if isComplete {
                Button(action: {
                    appState.currentPhase = .labeling
                }) {
                    Label("Review & Add Missing Items", systemImage: "plus.circle.fill")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(.vertical, 30)
        .onAppear {
            startMultiPassAnalysis()
        }
    }
    
    private func startMultiPassAnalysis() {
        Task {
            // Initialize pass status
            for i in 1...4 {
                passStatus[i] = PassStatus(
                    name: passes[i - 1],
                    status: .pending,
                    objectCount: 0
                )
            }
            
            // Simulate multi-pass detection
            for pass in 1...4 {
                await MainActor.run {
                    currentPass = pass
                    passStatus[pass] = PassStatus(
                        name: passes[pass - 1],
                        status: .running,
                        objectCount: 0
                    )
                }
                
                // Simulate API call delay
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                
                // Simulate objects found
                let objectsInPass = Int.random(in: 8...20)
                
                await MainActor.run {
                    totalObjectsFound += objectsInPass
                    passStatus[pass] = PassStatus(
                        name: passes[pass - 1],
                        status: .complete,
                        objectCount: objectsInPass
                    )
                }
            }
            
            await MainActor.run {
                withAnimation {
                    isComplete = true
                }
            }
        }
    }
}

struct PassStatusRow: View {
    let passNumber: Int
    let title: String
    let status: MultiPassAnalyzingView.PassStatus
    
    var body: some View {
        HStack(spacing: 16) {
            // Status icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 32, height: 32)
                
                if status.status == .running {
                    ProgressView()
                        .scaleEffect(0.6)
                } else {
                    Image(systemName: iconName)
                        .foregroundColor(iconColor)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            
            // Pass info
            VStack(alignment: .leading, spacing: 2) {
                Text("Pass \(passNumber): \(title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(textColor)
                
                if status.objectCount > 0 {
                    Text("\(status.objectCount) items detected")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
    }
    
    private var iconName: String {
        switch status.status {
        case .pending: return "circle"
        case .running: return ""
        case .complete: return "checkmark"
        case .failed: return "xmark"
        }
    }
    
    private var iconColor: Color {
        switch status.status {
        case .pending: return .gray
        case .running: return .blue
        case .complete: return .green
        case .failed: return .red
        }
    }
    
    private var iconBackgroundColor: Color {
        switch status.status {
        case .pending: return .gray.opacity(0.1)
        case .running: return .blue.opacity(0.1)
        case .complete: return .green.opacity(0.1)
        case .failed: return .red.opacity(0.1)
        }
    }
    
    private var textColor: Color {
        switch status.status {
        case .pending: return .secondary
        case .running, .complete, .failed: return .primary
        }
    }
}