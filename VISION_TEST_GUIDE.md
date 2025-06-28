# Vision Detection Test Guide

## Overview

This guide explains how to test GPT-4 Vision's ability to detect objects in messy room images. Our goal is to achieve ≥85% accuracy in detecting visible objects.

## Quick Start

1. **Set up your API key**
   ```bash
   export OPENAI_API_KEY='your-api-key-here'
   ```

2. **Run the test suite**
   ```bash
   cd /Users/satoshi/roomcleaner
   python3 test_vision.py
   ```

3. **Check results**
   - Results are saved in `/Users/satoshi/roomcleaner/test_results/`
   - Read `SUMMARY.md` for human-readable report
   - Individual JSON files contain detailed object detections

## Test Images

The test suite uses 6 real messy room images located in `/test_images/`:
1. `bebop38veub21.webp` - General messy room
2. `iesll09jp2o21.webp` - Cluttered bedroom
3. `who-am-i-based-on-my-relatively-messy-room-v0-3uxt3508qnvc1.webp` - Personal room #1
4. `who-am-i-based-on-my-relatively-messy-room-v0-jth3v408qnvc1.webp` - Personal room #2
5. `who-am-i-based-on-my-relatively-messy-room-v0-kny4g508qnvc1.webp` - Personal room #3
6. `wonderlane-6jA6eVsRJ6Q-unsplash.jpg` - Professional messy room photo

## What We're Testing

The vision model attempts to detect:
- **Object Label**: Specific names (e.g., "blue t-shirt", "water bottle")
- **Confidence**: How sure the model is (0.0-1.0)
- **Bounding Box**: Location in the image
- **Category**: Type of object (clothes, electronics, papers, etc.)

## Success Metrics

We're aiming for:
- ≥85% of visible objects detected
- High confidence (>0.8) for most detections
- Accurate categorization
- Specific labels (not generic "item" or "object")

## Understanding Results

### accuracy_report.json
```json
{
  "total_objects_detected": 156,
  "average_objects_per_image": 26.0,
  "category_breakdown": {
    "clothes": 45,
    "electronics": 23,
    "papers": 18,
    ...
  }
}
```

### Individual Results
Each image gets its own result file with detected objects:
```json
{
  "objects": [
    {
      "label": "blue jeans on floor",
      "confidence": 0.92,
      "boundingBox": {"x": 23, "y": 45, "width": 15, "height": 20},
      "category": "clothes"
    }
  ]
}
```

## Improving Accuracy

If accuracy is below 85%, we can:
1. **Refine prompts** - More specific instructions
2. **Adjust model parameters** - Temperature, detail level
3. **Pre-process images** - Enhance contrast, resize
4. **Post-process results** - Filter low-confidence detections

## Integration with iOS App

Once we achieve target accuracy:
1. Replace mock implementation in `VisionAnalyzer.swift`
2. Add bounding box overlay in the UI
3. Use detections to generate cleaning tasks

## Troubleshooting

- **"No API key"**: Set `OPENAI_API_KEY` environment variable
- **"Rate limit"**: Script includes 1-second delay between requests
- **"Failed detection"**: Check individual result JSON for error details