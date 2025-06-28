import SwiftUI

struct RoomScanView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var scanViewModel = RoomScanViewModel()
    @State private var showingCamera = false
    @State private var showingDemoAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 10) {
                Text("Scan Your Room")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text(scanViewModel.currentInstruction)
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Progress
                ProgressView(value: Double(appState.roomPhotos.count), total: Double(scanViewModel.requiredAreas.count))
                    .padding(.horizontal, 40)
                    .padding(.top, 10)
            }
            .padding(.vertical, 30)
            .background(Color(.systemBackground))
            
            // Photos Grid
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(appState.roomPhotos) { photo in
                        PhotoThumbnail(photo: photo)
                    }
                    
                    // Add Photo Button
                    Button(action: { 
                        if MockData.demoMode {
                            showingDemoAlert = true
                        } else {
                            showingCamera = true
                        }
                    }) {
                        VStack(spacing: 10) {
                            Image(systemName: "camera.fill")
                                .font(.system(size: 40))
                            Text("Add Photo")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(height: 150)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(style: StrokeStyle(lineWidth: 2, dash: [5]))
                                .foregroundColor(.gray.opacity(0.3))
                        )
                    }
                }
                .padding()
            }
            
            // Continue Button
            if appState.roomPhotos.count >= scanViewModel.minimumPhotos {
                Button(action: { 
                    appState.completeScanning()
                    scanViewModel.analyzeRoom(photos: appState.roomPhotos, appState: appState)
                }) {
                    Text("Analyze My Room")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(15)
                }
                .padding(.horizontal, 30)
                .padding(.bottom, 30)
            }
        }
        .sheet(isPresented: $showingCamera) {
            CameraView { image in
                let area = scanViewModel.getCurrentArea(photoCount: appState.roomPhotos.count)
                appState.roomPhotos.append(RoomPhoto(image: image, area: area))
                scanViewModel.updateInstructions(photoCount: appState.roomPhotos.count)
            }
        }
        .alert("Demo Mode", isPresented: $showingDemoAlert) {
            Button("Use Mock Image") {
                let area = scanViewModel.getCurrentArea(photoCount: appState.roomPhotos.count)
                let mockImage = MockData.generateMockRoomImage(for: area)
                appState.roomPhotos.append(RoomPhoto(image: mockImage, area: area))
                scanViewModel.updateInstructions(photoCount: appState.roomPhotos.count)
            }
            Button("Select from Library") {
                showingCamera = true
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You're in demo mode. Choose how to add photos.")
        }
    }
}

struct PhotoThumbnail: View {
    let photo: RoomPhoto
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Image(uiImage: photo.image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .clipped()
                .cornerRadius(12)
            
            Text(photo.area)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 5)
        }
    }
}