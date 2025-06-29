## Project Overview

Room Cleaner is an iOS app designed to help people with ADHD clean their rooms using computer vision to identify items and provide bite-sized cleaning tasks. The project includes both a native iOS app (SwiftUI) and a Next.js landing page.

## Development Commands

### iOS App Development
```bash
# Open project in Xcode
open RoomCleaner/RoomCleaner.xcodeproj

# Build and run through Xcode UI (Cmd+R)
# Target: iOS 16+
```

### Landing Page Development
```bash
cd landing
npm install       # Install dependencies
npm run dev       # Start development server (localhost:3000)
vercel            # Deploy to production
```

### Vision Testing
```bash
export OPENAI_API_KEY='your-key'
python3 test_vision.py  # Test GPT-4 Vision accuracy
```

## Architecture & Structure

### iOS App Architecture (MVVM)

**State Management:**
- Single `AppState` class manages all app state with `@Published` properties
- Environment object pattern for global state access
- Phase-based flow: `welcome → scanning → analyzing → labeling → cleaning → completed`

**Key Components:**
- `RoomScanViewModel`: Handles room scanning and photo management
- `MultiPassVisionAnalyzer`: 2-pass detection system with GridGPT
- `GridOverlayService`: Adds 5x5 grid overlay for spatial detection
- `AppState`: Central state management with phase tracking
- Views are in `Views/` directory, organized by app phase

**GridGPT Detection System:**
- 5x5 grid overlay (A1-E5) on images
- Grid-aware prompts for GPT-4 Vision
- Converts grid cells to bounding boxes
- 60-70% accuracy (good enough for MVP)

### Landing Page Structure

Next.js 13+ app with:
- Supabase for waitlist storage
- Tailwind CSS for styling
- Optional Mailgun/Slack integrations

## Important Configuration

### iOS App
1. **Add OpenAI API Key**:
   ```swift
   // In Configuration.xcconfig
   OPENAI_API_KEY=sk-your-key-here
   ```

2. **Test Mode** is enabled in debug builds:
   - 6 messy room test images available
   - Access via "Use Test Images" on Welcome screen

### Landing Page
Configure environment variables in `landing/.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
MAILGUN_API_KEY= (optional)
SLACK_WEBHOOK_URL= (optional)
```

## Key Implementation Details

### GridGPT Detection Flow
1. User takes 1-4 photos of their room
2. Grid overlay added to each image
3. GPT-4V analyzes with grid-aware prompts
4. Returns items with grid locations (e.g., "B3", "C4-D5")
5. Grid cells converted to bounding boxes
6. Thumbnails created from compressed images

### ADHD-Optimized Features
- Bite-sized tasks (one item at a time)
- Visual progress tracking
- Celebration animations on completion
- No overwhelming task lists
- Focus on "what" not "how" to clean
- Visual thumbnails for each item

### Testing Approach
- Use test mode with sample images
- Test images available in `test_images/` directory
- Console logs show detection results
- No unit tests currently - testing done through UI

## Development Workflow

1. **For UI changes**: Use test mode images
2. **For detection changes**: Test with GridGPT prompts
3. **For new features**: Follow existing MVVM pattern
4. **For landing page**: Standard Next.js development flow

## Current Implementation Status

**Working:**
- Complete app flow from scanning to celebration
- GridGPT spatial detection (60-70% accuracy)
- Real OpenAI API integration
- Visual thumbnails with correct cropping
- Test mode with 6 sample images
- Landing page with waitlist

**Recent Fixes (Dec 28):**
- Fixed thumbnail cropping bug (coordinate mismatch)
- Implemented GridGPT approach
- Cleaned repository structure
- Updated all documentation

**Needs Implementation:**
- Manual location adjustment UI
- Better grid precision (try 7x7)
- Data persistence between sessions
- Before/after photo comparisons

## GridGPT vs Alternatives Analysis

We evaluated 3 approaches:

1. **GridGPT** (Implemented) ✅
   - Simple 5x5 grid overlay
   - No extra dependencies
   - 60-70% accuracy
   - Good for MVP

2. **YOLO→GPT Pipeline**
   - Local YOLO detection
   - Precise bounding boxes
   - 85-90% accuracy
   - Requires 50MB model

3. **Scene Explorer**
   - Complex spatial Q&A
   - Overkill for our needs

Decision: Stick with GridGPT for MVP, consider YOLO for v2.

## Tomorrow's Priority Tasks

1. **Test GridGPT More**
   - Try all 6 test images
   - Measure accuracy improvements
   - Document failure cases

2. **Improve Prompts**
   - Add few-shot examples
   - Test confidence thresholds
   - Try category-specific prompts

3. **Consider 7x7 Grid**
   - Better precision
   - Still simple implementation
   - Test performance impact

4. **Add Manual Adjustment**
   - Let users fix wrong locations
   - Simple drag interface
   - Save corrections for learning

## Project Status Board

### Completed ✅
- [x] Fix Xcode build errors
- [x] Remove all mock data
- [x] Add test image selector
- [x] Fix thumbnail cropping bug
- [x] Implement GridGPT detection
- [x] Compare detection approaches
- [x] Clean repository
- [x] Update all documentation

### In Progress 🏗️
- [ ] Improve GridGPT accuracy
- [ ] Add manual location adjustment
- [ ] Test with more images

### Backlog 📋
- [ ] Implement YOLO→GPT (if needed)
- [ ] Add data persistence
- [ ] Before/after photos
- [ ] App Store submission

## Lessons Learned

**Image Size Mismatch Bug:**
- Original photos: 3024×4032 (high-res)
- Compressed for AI: 768×1024
- AI returns coordinates for compressed image
- Must crop from same compressed image!

**GridGPT Approach:**
- Simple beats complex for MVP
- 60-70% accuracy is "good enough"
- Users can manually adjust
- Ship fast, iterate based on feedback

**API Cost Management:**
- Compress images before sending
- Consider crop-only approach for v2
- Cache detection results
- Batch API calls when possible

## Next Session Quick Start

1. Open Xcode: `open RoomCleaner/RoomCleaner.xcodeproj`
2. Press Cmd+R to run
3. Tap "Use Test Images" on Welcome screen
4. Test GridGPT detection
5. Check console for results

Everything is configured and ready to go!