# Room Cleaner

An AI-powered iOS app that helps people (especially those with ADHD) transform messy rooms into organized spaces through guided, bite-sized cleaning tasks.

## 🎯 Problem We're Solving

- **Decision Fatigue**: "Where should this go?" - Every item requires a decision
- **Overwhelm**: Looking at a messy room feels insurmountable
- **Lack of System**: No consistent organization method
- **Maintenance Failure**: Even after cleaning, things get messy again quickly

## 📱 How It Works

### 1. **Capture Current State** 📸
- Guided room scanning with step-by-step photo capture
- Take photos of different areas: overview, desk, bed, floor, closet, drawers
- Progress indicator shows scanning completion

### 2. **AI Analysis** 🤖
- AI processes photos to identify all items
- Categorizes belongings (clothes, electronics, papers, etc.)
- Creates personalized cleaning plan based on YOUR mess

### 3. **Bite-Sized Tasks** ✅
- Breaks overwhelming cleanup into small, manageable tasks
- One task at a time: "Pick up these 3 shirts"
- Time estimates for each task (3-8 minutes)
- Reference photos show exactly what to clean

### 4. **Progress Tracking** 📊
- Real-time progress percentage
- Visual celebration on completion
- Stats like "23 items organized!"

## 🚀 Current Status

### ✅ Implemented Features
- Multi-photo room scanning interface
- Demo mode with mock images for testing
- AI analysis flow (currently using mock data)
- Task-by-task cleaning interface
- Progress tracking and completion celebration
- Simulator-friendly (uses photo library instead of camera)

### 🔄 In Progress
- Real OpenAI GPT-4 Vision integration
- Persistent storage for cleaning sessions
- "Establish homes" feature for items

### 📋 Planned Features
- Before/after photo comparison
- Daily maintenance reminders
- Voice search: "Where did I put my keys?"
- Room-specific organization tips
- Export cleaning reports

## 🛠 Technical Stack

- **SwiftUI** - Modern declarative UI
- **GPT-4 Vision API** - AI-powered image analysis
- **MVVM Architecture** - Clean separation of concerns
- **iOS 16+** - Latest iOS features

## 📲 Installation

1. Clone the repository
```bash
git clone https://github.com/rohunvora/roomcleaner.git
```

2. Open in Xcode
```bash
cd roomcleaner
open RoomCleaner/RoomCleaner.xcodeproj
```

3. Add your OpenAI API key
- Copy `.env.example` to `.env`
- Add your OpenAI API key to the `.env` file
- Update `Services/AIAnalyzer.swift` with your key

4. Build and run on simulator or device

## 🧪 Testing

The app includes a demo mode for easy testing:

1. Run on iPhone simulator
2. When prompted to add photos:
   - Choose "Use Mock Image" for generated messy room images
   - Or "Select from Library" to use your own photos
3. Add at least 4 photos to proceed
4. Experience the full cleaning flow!

To disable demo mode, set `MockData.demoMode = false` in `Utilities/MockData.swift`.

## 🎨 Design Principles

- **ADHD-Friendly**: Large buttons, minimal steps, clear progress
- **Visual-First**: Photos over text wherever possible
- **Non-Overwhelming**: One task at a time
- **Motivating**: Progress tracking and celebrations

## 🤝 Contributing

This project is in active development. Feel free to:
- Report bugs
- Suggest features
- Submit pull requests

## 📄 License

MIT License - see LICENSE file for details

## 🙏 Acknowledgments

Built with the understanding that cleaning isn't just about organization—it's about creating systems that work with how our brains actually function.