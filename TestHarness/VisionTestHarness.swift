import Foundation
import UIKit

// Test harness for evaluating vision detection accuracy
class VisionTestHarness {
    static let shared = VisionTestHarness()
    
    struct TestResult {
        let imageName: String
        let detectedObjects: [VisionAnalyzer.DetectedObject]
        let processingTime: TimeInterval
        let error: Error?
    }
    
    struct AccuracyReport {
        let totalImagesProcessed: Int
        let totalObjectsDetected: Int
        let averageObjectsPerImage: Double
        let categoryBreakdown: [String: Int]
        let confidenceDistribution: [String: Int] // Low/Medium/High
        let processingTimeAverage: TimeInterval
        let failedImages: [String]
    }
    
    func runTestSuite() async -> AccuracyReport {
        let testImagePaths = [
            "/Users/satoshi/roomcleaner/test_images/bebop38veub21.webp",
            "/Users/satoshi/roomcleaner/test_images/iesll09jp2o21.webp",
            "/Users/satoshi/roomcleaner/test_images/who-am-i-based-on-my-relatively-messy-room-v0-3uxt3508qnvc1.webp",
            "/Users/satoshi/roomcleaner/test_images/who-am-i-based-on-my-relatively-messy-room-v0-jth3v408qnvc1.webp",
            "/Users/satoshi/roomcleaner/test_images/who-am-i-based-on-my-relatively-messy-room-v0-kny4g508qnvc1.webp",
            "/Users/satoshi/roomcleaner/test_images/wonderlane-6jA6eVsRJ6Q-unsplash.jpg"
        ]
        
        var results: [TestResult] = []
        
        for path in testImagePaths {
            let result = await processImage(at: path)
            results.append(result)
            
            // Save individual results
            await saveResultsToFile(result, imagePath: path)
        }
        
        return generateReport(from: results)
    }
    
    private func processImage(at path: String) async -> TestResult {
        let startTime = Date()
        let imageName = URL(fileURLWithPath: path).lastPathComponent
        
        do {
            guard let image = UIImage(contentsOfFile: path) else {
                throw VisionError.imageProcessingFailed
            }
            
            let detectionResult = try await VisionAnalyzer.shared.detectObjects(in: image)
            let processingTime = Date().timeIntervalSince(startTime)
            
            return TestResult(
                imageName: imageName,
                detectedObjects: detectionResult.objects,
                processingTime: processingTime,
                error: nil
            )
        } catch {
            return TestResult(
                imageName: imageName,
                detectedObjects: [],
                processingTime: Date().timeIntervalSince(startTime),
                error: error
            )
        }
    }
    
    private func saveResultsToFile(_ result: TestResult, imagePath: String) async {
        let outputDir = "/Users/satoshi/roomcleaner/test_results"
        
        // Create directory if needed
        try? FileManager.default.createDirectory(
            atPath: outputDir,
            withIntermediateDirectories: true
        )
        
        // Create result dictionary
        var resultDict: [String: Any] = [
            "imageName": result.imageName,
            "processingTime": result.processingTime,
            "objectCount": result.detectedObjects.count,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]
        
        if let error = result.error {
            resultDict["error"] = error.localizedDescription
        } else {
            resultDict["objects"] = result.detectedObjects.map { object in
                [
                    "label": object.label,
                    "confidence": object.confidence,
                    "category": object.category ?? "unknown",
                    "boundingBox": [
                        "x": object.boundingBox.x,
                        "y": object.boundingBox.y,
                        "width": object.boundingBox.width,
                        "height": object.boundingBox.height
                    ]
                ]
            }
        }
        
        // Save as JSON
        let jsonPath = "\(outputDir)/\(result.imageName)_results.json"
        if let jsonData = try? JSONSerialization.data(withJSONObject: resultDict, options: .prettyPrinted) {
            try? jsonData.write(to: URL(fileURLWithPath: jsonPath))
        }
    }
    
    private func generateReport(from results: [TestResult]) -> AccuracyReport {
        let successfulResults = results.filter { $0.error == nil }
        let failedImages = results.filter { $0.error != nil }.map { $0.imageName }
        
        let allObjects = successfulResults.flatMap { $0.detectedObjects }
        
        // Category breakdown
        var categoryBreakdown: [String: Int] = [:]
        for object in allObjects {
            let category = object.category ?? "unknown"
            categoryBreakdown[category, default: 0] += 1
        }
        
        // Confidence distribution
        var confidenceDistribution = ["Low": 0, "Medium": 0, "High": 0]
        for object in allObjects {
            if object.confidence < 0.5 {
                confidenceDistribution["Low"]! += 1
            } else if object.confidence < 0.8 {
                confidenceDistribution["Medium"]! += 1
            } else {
                confidenceDistribution["High"]! += 1
            }
        }
        
        // Average processing time
        let totalProcessingTime = successfulResults.reduce(0.0) { $0 + $1.processingTime }
        let avgProcessingTime = successfulResults.isEmpty ? 0 : totalProcessingTime / Double(successfulResults.count)
        
        // Average objects per image
        let avgObjectsPerImage = successfulResults.isEmpty ? 0 : Double(allObjects.count) / Double(successfulResults.count)
        
        return AccuracyReport(
            totalImagesProcessed: results.count,
            totalObjectsDetected: allObjects.count,
            averageObjectsPerImage: avgObjectsPerImage,
            categoryBreakdown: categoryBreakdown,
            confidenceDistribution: confidenceDistribution,
            processingTimeAverage: avgProcessingTime,
            failedImages: failedImages
        )
    }
    
    func saveReport(_ report: AccuracyReport) {
        let reportPath = "/Users/satoshi/roomcleaner/test_results/accuracy_report.json"
        
        let reportDict: [String: Any] = [
            "timestamp": ISO8601DateFormatter().string(from: Date()),
            "totalImagesProcessed": report.totalImagesProcessed,
            "totalObjectsDetected": report.totalObjectsDetected,
            "averageObjectsPerImage": report.averageObjectsPerImage,
            "categoryBreakdown": report.categoryBreakdown,
            "confidenceDistribution": report.confidenceDistribution,
            "processingTimeAverage": report.processingTimeAverage,
            "failedImages": report.failedImages
        ]
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: reportDict, options: .prettyPrinted) {
            try? jsonData.write(to: URL(fileURLWithPath: reportPath))
        }
        
        // Also save human-readable summary
        let summaryPath = "/Users/satoshi/roomcleaner/test_results/SUMMARY.md"
        let summary = """
        # Vision Detection Accuracy Report
        
        Generated: \(Date())
        
        ## Overview
        - **Total Images Processed**: \(report.totalImagesProcessed)
        - **Total Objects Detected**: \(report.totalObjectsDetected)
        - **Average Objects per Image**: \(String(format: "%.1f", report.averageObjectsPerImage))
        - **Average Processing Time**: \(String(format: "%.1f", report.processingTimeAverage))s
        
        ## Category Breakdown
        \(report.categoryBreakdown.map { "- \($0.key): \($0.value)" }.sorted().joined(separator: "\n"))
        
        ## Confidence Distribution
        - High (>0.8): \(report.confidenceDistribution["High"]!)
        - Medium (0.5-0.8): \(report.confidenceDistribution["Medium"]!)
        - Low (<0.5): \(report.confidenceDistribution["Low"]!)
        
        ## Failed Images
        \(report.failedImages.isEmpty ? "None" : report.failedImages.joined(separator: "\n"))
        """
        
        try? summary.write(toFile: summaryPath, atomically: true, encoding: .utf8)
    }
}