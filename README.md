# Room Cleaner iOS App

An iOS app that helps people with ADHD organize messy rooms using AI-powered object detection and bite-sized cleaning tasks.

## 🚨 Current Status (Dec 28, 2024)

**The app builds and runs!** Key updates:
- ✅ Fixed all Xcode build errors
- ✅ Implemented GridGPT spatial detection system
- ✅ Real OpenAI API integration working
- ✅ Test mode with 6 Reddit messy room images
- ✅ Delightful cleaning UI with visual thumbnails
- ⚠️ Detection accuracy: ~60-70% (GridGPT approach)
- 💰 Cost: ~$0.02-0.03 per room scan

## 🎯 What's Working

1. **Complete App Flow**
   - Welcome screen with test image selector
   - Multi-photo capture (1-4 photos)
   - Real-time AI analysis with grid overlay
   - Category-based task organization
   - Visual thumbnails for each item
   - Progress tracking and celebrations

2. **GridGPT Spatial Detection**
   - 5x5 grid overlay (A1-E5) for location tracking
   - Grid-aware prompts for GPT-4 Vision
   - Coordinate conversion for thumbnails
   - Good enough for MVP (60-70% accuracy)

3. **Test Mode**
   - 6 real messy room images from Reddit
   - Debug builds show test selector
   - Great for development without taking photos

## 🔧 Quick Start

1. **Clone and open in Xcode:**
   ```bash
   git clone [your-repo-url]
   cd roomcleaner
   open RoomCleaner/RoomCleaner.xcodeproj
   ```

2. **Add your OpenAI API key:**
   ```bash
   cd RoomCleaner
   cp Configuration.xcconfig.template Configuration.xcconfig
   # Edit Configuration.xcconfig and add your key:
   # OPENAI_API_KEY=sk-...
   ```

3. **Build and run:**
   - Select your device/simulator
   - Press Cmd+R
   - Test with sample images or take real photos

## 📁 Repository Structure

```
roomcleaner/
├── RoomCleaner/          # iOS app (Swift/SwiftUI)
│   ├── Services/         # AI integration & detection
│   │   ├── OpenAIService.swift       # GPT-4 Vision API
│   │   ├── GridOverlayService.swift  # Grid overlay system
│   │   └── MultiPassVisionAnalyzer.swift
│   ├── Views/           # UI components
│   │   ├── DelightfulCleaningView.swift  # Main cleaning UI
│   │   └── WelcomeView.swift            # Test image selector
│   └── Models/          # Data structures
├── landing/             # Next.js marketing website
├── docs/               # Documentation
│   └── SPATIAL_DETECTION_COMPARISON.md  # GridGPT vs alternatives
└── test_images/        # Sample messy rooms
```

## 🚀 GridGPT Detection System

We implemented a grid-based detection approach:

1. **Grid Overlay**: 5x5 grid (A1-E5) added to images
2. **Smart Prompts**: GPT-4V returns grid locations
3. **Visual Thumbnails**: Grid cells converted to crops

### Why GridGPT?
- ✅ Simple implementation (no extra models)
- ✅ Works entirely through OpenAI API
- ✅ Good enough for MVP (60-70% accuracy)
- ✅ No 50MB YOLO model to bundle

### Future: YOLO→GPT Pipeline
For v2.0, consider upgrading to local YOLO detection:
- Higher accuracy (85-90%)
- Precise bounding boxes
- Lower API costs
- See `docs/SPATIAL_DETECTION_COMPARISON.md` for details

## 📝 Recent Changes (Dec 28)

1. **Fixed thumbnail accuracy bug** - Crops now use compressed images
2. **Implemented GridGPT** - Grid overlay for spatial detection
3. **Compared 3 approaches** - GridGPT vs YOLO pipelines
4. **Cleaned repository** - Moved old files to `/archive`
5. **Updated all documentation** - Ready for handoff

## 🐛 Known Issues

1. **Detection Accuracy**: ~60-70% (GridGPT limitation)
2. **Grid Precision**: 20% chunks may miss small items
3. **API Costs**: $0.02-0.03 per scan (4 full images)

## 💡 Next Steps

### Tomorrow's Priority Tasks:
1. [ ] Test grid detection with more images
2. [ ] Fine-tune prompts for better accuracy
3. [ ] Add manual location adjustment UI
4. [ ] Consider 7x7 grid for better precision

### v2.0 Considerations:
1. [ ] Implement YOLO→GPT pipeline
2. [ ] Add offline detection capability
3. [ ] Train custom model on room data
4. [ ] Reduce API costs with crop-only approach

## 🔗 Resources

- [GridGPT Inspiration](https://github.com/quinny1187/GridGPT)
- [YOLO→GPT Example](https://github.com/zawawiAI/yolo_gpt)
- [Spatial Detection Comparison](docs/SPATIAL_DETECTION_COMPARISON.md)
- [Project Status](PROJECT_STATUS.md)

## 📱 App Store Submission

When ready to ship:
1. Set `Configuration.xcconfig` with production API key
2. Disable test mode in `WelcomeView.swift`
3. Update app version and build number
4. Test on real devices
5. Submit to App Store Connect

---

**Questions?** The codebase is well-documented. Start with `RoomCleanerApp.swift` and follow the flow. GridGPT implementation is in `GridOverlayService.swift`.