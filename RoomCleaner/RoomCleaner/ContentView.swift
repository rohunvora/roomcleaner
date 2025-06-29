import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        ZStack {
            switch appState.currentPhase {
            case .welcome:
                WelcomeView()
            case .scanning:
                RoomScanView()
            case .analyzing:
                AnalyzingView()
            case .labeling:
                // TODO: Add manual item addition view
                CleaningView()
            case .cleaning:
                DelightfulCleaningView()
            case .completed:
                DelightfulCompletedView()
            }
        }
        .animation(.easeInOut, value: appState.currentPhase)
    }
}