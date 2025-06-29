import Foundation

struct APIConfiguration {
    static var openAIAPIKey: String {
        // Load from Configuration.xcconfig
        if let path = Bundle.main.path(forResource: "Configuration", ofType: "xcconfig"),
           let config = NSDictionary(contentsOfFile: path),
           let apiKey = config["OPENAI_API_KEY"] as? String,
           !apiKey.isEmpty {
            return apiKey
        }
        
        // No fallback - require proper configuration
        fatalError("OpenAI API key not found. Please add your API key to Configuration.xcconfig")
    }
    
    // API Settings
    // First try environment variable, then fall back to hardcoded key from xcconfig
    static let apiURL = "https://api.openai.com/v1/chat/completions"
    static let model = "gpt-4o"
    static let maxTokens = 4096
    static let temperature = 0.3
    
    // Image Settings
    static let maxImageDimension: CGFloat = 1024
    static let jpegCompressionQuality: CGFloat = 0.7
    static let maxImageSize = 1024 * 1024 * 2 // 2MB
    
    // Cost Management
    static let costPerImage = 0.01 // Approximate cost per image
    static let maxImagesPerScan = 10
    static let monthlyFreeScans = 30
    
    // Timeout Settings
    static let requestTimeout: TimeInterval = 30
    static let retryAttempts = 2
    static let retryDelay: TimeInterval = 2
    
    // Feature Flags
    static let enableBrandDetection = true
    static let enableStorageMatching = true
    static let enableManualAddition = true
    
    // Debug Settings
    #if DEBUG
    static let logAPIRequests = true
    #else
    static let logAPIRequests = false
    #endif
}