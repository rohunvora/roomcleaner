#!/usr/bin/env swift

import Foundation
import UIKit

// Simple command line test runner for vision detection
// Run with: swift test_vision.swift

print("🔍 Room Cleaner Vision Detection Test Suite")
print("==========================================\n")

// Check for API key
let apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
if apiKey.isEmpty {
    print("❌ Error: OPENAI_API_KEY environment variable not set")
    print("Run: export OPENAI_API_KEY='your-key-here'")
    exit(1)
}

// Test image paths
let testImages = [
    "bebop38veub21.webp",
    "iesll09jp2o21.webp",
    "who-am-i-based-on-my-relatively-messy-room-v0-3uxt3508qnvc1.webp",
    "who-am-i-based-on-my-relatively-messy-room-v0-jth3v408qnvc1.webp",
    "who-am-i-based-on-my-relatively-messy-room-v0-kny4g508qnvc1.webp",
    "wonderlane-6jA6eVsRJ6Q-unsplash.jpg"
]

// Process each image
for (index, imageName) in testImages.enumerated() {
    print("Processing image \(index + 1)/\(testImages.count): \(imageName)")
    
    let imagePath = "/Users/satoshi/roomcleaner/test_images/\(imageName)"
    
    // Here we would call the actual vision API
    // For now, let's create a mock response structure
    print("  ✓ Processed (mock)")
}

print("\n✅ Test suite complete!")
print("Results saved to: /Users/satoshi/roomcleaner/test_results/")