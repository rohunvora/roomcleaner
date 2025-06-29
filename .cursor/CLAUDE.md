# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

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
- `MultiPassVisionAnalyzer`: 4-pass detection system for 90%+ accuracy
- `AppState`: Central state management with phase tracking
- Views are in `Views/` directory, organized by app phase

**Multi-Pass Detection System:**
- Pass 1: General objects
- Pass 2: Small/cluttered items
- Pass 3: Textiles/soft materials
- Pass 4: Partially visible objects
- Smart deduplication prevents duplicate items

### Landing Page Structure

Next.js 13+ app with:
- Supabase for waitlist storage
- Tailwind CSS for styling
- Optional Mailgun/Slack integrations

## Important Configuration

### iOS App
1. **Enable Demo Mode** for testing without API calls:
   ```swift
   // In MockData.swift
   static let demoMode = true  // Set to false for production
   ```

2. **Add OpenAI API Key** when ready:
   ```swift
   // In MultiPassVisionAnalyzer.swift
   private let apiKey = "your-openai-api-key"
   ```

### Landing Page
Configure environment variables in `landing/.env.local`:
```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
MAILGUN_API_KEY= (optional)
SLACK_WEBHOOK_URL= (optional)
```

## Key Implementation Details

### Detection & Labeling Flow
1. User takes 4+ photos of their room from different angles
2. Multi-pass vision analyzer processes each photo
3. Items are deduplicated across all photos
4. Manual addition UI allows adding missed items
5. Each item becomes a cleaning task

### ADHD-Optimized Features
- Bite-sized tasks (one item at a time)
- Visual progress tracking
- Celebration animations on completion
- No overwhelming task lists
- Focus on "what" not "how" to clean

### Testing Approach
- Use demo mode for UI development/testing
- Test images available in `test_images/` directory
- `TestHarness/` contains vision accuracy testing utilities
- No unit tests currently - testing done through UI

## Development Workflow

1. **For UI changes**: Enable demo mode and use Xcode simulator
2. **For vision changes**: Test with `test_vision.py` first
3. **For new features**: Follow existing MVVM pattern
4. **For landing page**: Standard Next.js development flow

## Current Implementation Status

**Working:**
- Complete app flow from scanning to celebration
- Multi-pass detection system (placeholder implementation)
- Manual item addition UI
- Demo mode with realistic mock data
- Landing page with waitlist and animated detection demo
- Server-side rendered landing page with pure CSS animations

**Landing Page Features:**
- Animated detection demo showing AI in action
- 30+ items detected with staggered animations
- Category-based color coding for detected items
- Responsive design with lazy loading
- Accessibility features (respects prefers-reduced-motion)

**Needs Implementation:**
- Real OpenAI API integration (currently returns mock data)
- Data persistence between sessions
- Zone assignment logic ("homes" for items)
- Visual organization map overlay
- Before/after photo comparisons
- Voice search for finding specific items
- Smart contextual tips

## MVP Implementation Plan

The project has a detailed 5-week implementation plan to deliver on landing page promises:

**Week 1:** Core AI Detection - Real OpenAI API integration
**Week 2:** Organization Intelligence - Zone assignment system
**Week 3:** Visual Organization Map - Show WHERE to put things
**Week 4:** Data Persistence - Remember everything between sessions
**Week 5:** Smart Tips & Polish - Contextual advice and UX refinement

Target metrics: 70%+ detection accuracy, <$0.50 per room scan, 90%+ task completion rate