# Room Cleaner Repository Structure

## Overview
Room Cleaner is an iOS app that helps people with ADHD organize their rooms using AI-powered object detection. The repository contains both the iOS app (SwiftUI) and a marketing landing page (Next.js).

## Directory Structure

```
roomcleaner/
├── RoomCleaner/           # iOS App (SwiftUI)
│   ├── RoomCleaner/       # Main app code
│   │   ├── Models/        # Data models and app state
│   │   ├── Services/      # AI detection and analysis
│   │   ├── ViewModels/    # MVVM view models
│   │   ├── Views/         # SwiftUI views
│   │   └── Utilities/     # Helper code and mock data
│   └── RoomCleaner.xcodeproj
│
├── landing/               # Marketing Website (Next.js)
│   ├── app/              # Next.js 13+ app directory
│   ├── components/       # React components
│   ├── lib/              # Utilities and copy management
│   ├── public/           # Static assets
│   └── scripts/          # Build and maintenance scripts
│
├── test_images/          # Sample messy room images for testing
├── test_results/         # AI detection test results
├── TestHarness/          # Swift testing utilities
│
├── .cursor/              # Cursor IDE configuration
│   ├── instructions.md   # AI assistant guidelines
│   └── scratchpad.md    # Development notes and plans
│
└── docs/                 # Archived documentation
```

## Key Files

### iOS App
- `RoomCleaner/Services/MultiPassVisionAnalyzer.swift` - 4-pass AI detection system
- `RoomCleaner/Models/AppState.swift` - Central state management
- `RoomCleaner/Utilities/MockData.swift` - Demo mode configuration

### Landing Page
- `landing/app/page.tsx` - Main landing page
- `landing/lib/copy.ts` - All website copy in one place
- `landing/components/DetectionDemo.tsx` - Animated detection demo

### Configuration
- `landing/.env.local` - Environment variables (create from .env.example)
- iOS API key configuration in `MultiPassVisionAnalyzer.swift`

## Getting Started

### iOS Development
```bash
# Open in Xcode
open RoomCleaner/RoomCleaner.xcodeproj

# Enable demo mode for UI development (no API calls)
# In MockData.swift: static let demoMode = true
```

### Landing Page Development
```bash
cd landing
npm install
npm run dev  # Runs on http://localhost:3000
```

## Development Status

✅ **Completed:**
- Full iOS app UI flow
- ADHD-optimized UX
- Landing page with animations
- Mock data system for testing

🚧 **In Progress** (see `.cursor/scratchpad.md` for detailed plan):
- Real OpenAI API integration
- Zone assignment system
- Data persistence
- Visual organization maps

## Testing

```bash
# Test AI detection accuracy
export OPENAI_API_KEY='your-key'
python3 test_vision_v2.py
```

## Deployment

Landing page deploys automatically to Vercel:
- Production: https://roomcleaner.vercel.app
- Preview: Created for each PR

## Contributing

1. Check `.cursor/scratchpad.md` for current development plans
2. Use demo mode for UI development
3. Test with images in `test_images/`
4. Follow existing MVVM patterns in iOS code
5. Keep landing page copy in `lib/copy.ts` 