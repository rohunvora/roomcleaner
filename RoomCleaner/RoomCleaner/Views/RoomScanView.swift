import SwiftUI

struct RoomScanView: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var scanViewModel = RoomScanViewModel()
    @State private var showingCamera = false
    @State private var showingTestImagePicker = false
    
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
                        #if DEBUG
                        if MockData.testModeEnabled {
                            showingTestImagePicker = true
                        } else {
                            showingCamera = true
                        }
                        #else
                        showingCamera = true
                        #endif
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
        .sheet(isPresented: $showingTestImagePicker) {
            TestImagePickerSheet { selectedImage in
                let area = scanViewModel.getCurrentArea(photoCount: appState.roomPhotos.count)
                appState.roomPhotos.append(RoomPhoto(image: selectedImage, area: area))
                scanViewModel.updateInstructions(photoCount: appState.roomPhotos.count)
            }
        }
    }
}

// Sheet for picking individual test images
struct TestImagePickerSheet: View {
    @Environment(\.dismiss) var dismiss
    let onImageSelected: (UIImage) -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(MockData.testImages, id: \.filename) { testImage in
                        Button(action: {
                            if let image = MockData.loadTestImage(testImage.filename) {
                                onImageSelected(image)
                                dismiss()
                            }
                        }) {
                            VStack(alignment: .leading, spacing: 8) {
                                // Image preview
                                if let image = MockData.loadTestImage(testImage.filename) {
                                    Image(uiImage: image)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(height: 150)
                                        .clipped()
                                        .cornerRadius(8)
                                } else {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(height: 150)
                                        .cornerRadius(8)
                                        .overlay(
                                            Image(systemName: "photo")
                                                .foregroundColor(.gray)
                                        )
                                }
                                
                                // Info
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(testImage.displayName)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                        .foregroundColor(.primary)
                                    
                                    Text(testImage.description)
                                        .font(.caption2)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.horizontal, 4)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding()
            }
            .navigationTitle("Select Test Image")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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