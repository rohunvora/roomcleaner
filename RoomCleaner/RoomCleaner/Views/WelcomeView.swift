import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "sparkles")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                Text("Room Cleaner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Transform your messy room\ninto an organized space")
                    .font(.title3)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(spacing: 15) {
                Button(action: { appState.startScanning() }) {
                    Label("Start Cleaning", systemImage: "camera.fill")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                
                Text("Takes about 10-15 minutes")
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 30)
            .padding(.bottom, 50)
        }
    }
}