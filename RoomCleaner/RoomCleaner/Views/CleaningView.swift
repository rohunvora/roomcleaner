import SwiftUI

struct CleaningView: View {
    @EnvironmentObject var appState: AppState
    
    var currentTask: CleaningTask? {
        guard let plan = appState.cleaningPlan,
              appState.currentTaskIndex < plan.tasks.count else { return nil }
        return plan.tasks[appState.currentTaskIndex]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress Header
            VStack(spacing: 15) {
                HStack {
                    Text("Cleaning Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(Int(appState.progress * 100))%")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                }
                
                ProgressView(value: appState.progress)
                    .tint(.green)
                    .scaleEffect(y: 2)
            }
            .padding()
            .background(Color(.systemBackground))
            
            if let task = currentTask {
                ScrollView {
                    VStack(spacing: 25) {
                        // Task Card
                        VStack(alignment: .leading, spacing: 20) {
                            HStack {
                                Label(task.category, systemImage: categoryIcon(for: task.category))
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(20)
                                
                                Spacer()
                                
                                Text("\(task.estimatedMinutes) min")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(task.title)
                                .font(.title)
                                .fontWeight(.bold)
                            
                            // Items checklist
                            VStack(alignment: .leading, spacing: 12) {
                                ForEach(task.items, id: \.self) { item in
                                    HStack(spacing: 12) {
                                        Image(systemName: "circle")
                                            .font(.title3)
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        Text(item)
                                            .font(.body)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.05))
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(20)
                        .shadow(color: .black.opacity(0.1), radius: 10)
                        
                        // Reference Photo if available
                        if let image = task.referenceImage {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Reference")
                                    .font(.headline)
                                
                                Image(uiImage: image)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .cornerRadius(12)
                            }
                        }
                        
                        // Complete Button
                        Button(action: { appState.completeCurrentTask() }) {
                            Label("Task Complete", systemImage: "checkmark.circle.fill")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 20)
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                        }
                        .padding(.top, 10)
                    }
                    .padding()
                }
            }
        }
    }
    
    func categoryIcon(for category: String) -> String {
        switch category.lowercased() {
        case "clothes": return "tshirt.fill"
        case "electronics": return "laptopcomputer"
        case "books": return "book.fill"
        case "papers": return "doc.fill"
        case "trash": return "trash.fill"
        default: return "shippingbox.fill"
        }
    }
}