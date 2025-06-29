import SwiftUI

struct WelcomeView: View {
    @EnvironmentObject var appState: AppState
    @State private var showTestModeOptions = false
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            // App Icon/Logo
            Image(systemName: "sparkles.rectangle.stack")
                .font(.system(size: 80))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            VStack(spacing: 15) {
                Text("Room Cleaner")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Your ADHD-friendly cleaning companion")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Features list
            VStack(alignment: .leading, spacing: 20) {
                FeatureRow(icon: "camera.fill", text: "Take photos of your messy room")
                FeatureRow(icon: "brain", text: "AI identifies every item")
                FeatureRow(icon: "checklist", text: "Simple, one-task-at-a-time cleaning")
                FeatureRow(icon: "star.fill", text: "Celebrate your progress!")
            }
            .padding(.vertical, 30)
            
            Spacer()
            
            // Main button
            Button(action: { 
                appState.currentPhase = .scanning 
            }) {
                HStack {
                    Image(systemName: "camera.fill")
                    Text("Start Scanning")
                }
                .font(.title3)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(15)
            }
            .padding(.horizontal, 30)
            
            #if DEBUG
            // Test mode button
            Button(action: {
                showTestModeOptions = true
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Use Test Images")
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                .padding(.vertical, 10)
            }
            #endif
            
            Spacer()
                .frame(height: 30)
        }
        .sheet(isPresented: $showTestModeOptions) {
            TestImageSelector()
                .environmentObject(appState)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            Text(text)
                .font(.body)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}

// New view for selecting test images
struct TestImageSelector: View {
    @EnvironmentObject var appState: AppState
    @Environment(\.dismiss) var dismiss
    @State private var selectedImages: Set<String> = []
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select Test Images")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top)
                
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(MockData.testImages, id: \.filename) { testImage in
                            TestImageCard(
                                testImage: testImage,
                                isSelected: selectedImages.contains(testImage.filename),
                                action: {
                                    if selectedImages.contains(testImage.filename) {
                                        selectedImages.remove(testImage.filename)
                                    } else {
                                        selectedImages.insert(testImage.filename)
                                    }
                                }
                            )
                        }
                    }
                    .padding()
                }
                
                // Use selected images button
                Button(action: {
                    // Load selected test images
                    for filename in selectedImages {
                        if let image = MockData.loadTestImage(filename) {
                            let area = appState.roomPhotos.count < RoomScanViewModel().requiredAreas.count 
                                ? RoomScanViewModel().requiredAreas[appState.roomPhotos.count]
                                : "Additional Area"
                            appState.roomPhotos.append(RoomPhoto(image: image, area: area))
                        }
                    }
                    
                    // Go to scanning view
                    appState.currentPhase = .scanning
                    dismiss()
                }) {
                    Text("Use \(selectedImages.count) Images")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                        .background(selectedImages.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(selectedImages.isEmpty)
                .padding()
            }
            .navigationTitle("Test Mode")
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

struct TestImageCard: View {
    let testImage: MockData.TestImage
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 8) {
                // Image preview
                if let image = MockData.loadTestImage(testImage.filename) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 120)
                        .clipped()
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 3)
                        )
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
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
                        .lineLimit(2)
                }
                .padding(.horizontal, 4)
                
                // Selection indicator
                if isSelected {
                    HStack {
                        Spacer()
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.blue)
                            .padding(4)
                    }
                }
            }
            .background(Color(.systemBackground))
        }
        .buttonStyle(PlainButtonStyle())
    }
}