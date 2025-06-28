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
                MultiPassAnalyzingView()
            case .labeling:
                if let photo = appState.roomPhotos.first {
                    DetectionOverlayView(
                        image: photo.image,
                        detectedObjects: appState.detectedObjects,
                        allObjects: $appState.detectedObjects
                    )
                    .overlay(alignment: .topTrailing) {
                        Button("Done Adding") {
                            appState.completeLabelingPhase(with: appState.detectedObjects)
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding()
                    }
                }
            case .cleaning:
                CleaningView()
            case .completed:
                CompletedView()
            }
        }
        .animation(.easeInOut, value: appState.currentPhase)
    }
}