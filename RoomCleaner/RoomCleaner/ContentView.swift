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
            case .cleaning:
                CleaningView()
            case .completed:
                CompletedView()
            }
        }
        .animation(.easeInOut, value: appState.currentPhase)
    }
}