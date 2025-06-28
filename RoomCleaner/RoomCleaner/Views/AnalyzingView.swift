import SwiftUI

struct AnalyzingView: View {
    @State private var dots = ""
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Animation
            ZStack {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(Color.blue.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .scaleEffect(animationScale(for: index))
                        .opacity(animationOpacity(for: index))
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever()
                            .delay(Double(index) * 0.3),
                            value: dots
                        )
                }
                
                Image(systemName: "brain")
                    .font(.system(size: 40))
                    .foregroundColor(.blue)
            }
            
            VStack(spacing: 20) {
                Text("AI is analyzing your room\(dots)")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 10) {
                    AnalysisStep(text: "Identifying items", isActive: true)
                    AnalysisStep(text: "Categorizing belongings", isActive: true)
                    AnalysisStep(text: "Creating cleaning plan", isActive: false)
                }
                .padding(.top, 20)
            }
            
            Spacer()
        }
        .onAppear {
            animateDots()
        }
    }
    
    func animateDots() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if dots.count < 3 {
                dots += "."
            } else {
                dots = ""
            }
        }
    }
    
    func animationScale(for index: Int) -> CGFloat {
        return dots.isEmpty ? 1.0 : 2.0
    }
    
    func animationOpacity(for index: Int) -> Double {
        return dots.isEmpty ? 1.0 : 0.0
    }
}

struct AnalysisStep: View {
    let text: String
    let isActive: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            if isActive {
                ProgressView()
                    .scaleEffect(0.8)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray.opacity(0.3))
            }
            
            Text(text)
                .foregroundColor(isActive ? .primary : .secondary)
            
            Spacer()
        }
        .padding(.horizontal, 40)
    }
}