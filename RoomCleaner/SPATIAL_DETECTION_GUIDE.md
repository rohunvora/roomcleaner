# Spatial Detection & Visual Thumbnails Guide

## Overview

The Room Cleaner app now includes visual thumbnails for each detected item, helping users identify exactly which "white pillow" or "red shirt" needs to be cleaned up.

## How It Works

### 1. Detection Process
When analyzing photos, GPT-4 Vision provides:
- **Item Label**: "red Nike shoe"
- **Location**: General area like "bottom-left"
- **Bounding Box**: Precise coordinates (when available)

### 2. Thumbnail Generation

The app creates thumbnails using two methods:

#### Precise Cropping (Preferred)
- Uses exact bounding box coordinates from GPT-4
- Creates accurate crops of individual items
- Best for clear item identification

#### Location-Based Fallback
- Used when GPT-4 doesn't provide bounding boxes
- Creates 20% crops based on general location
- Provides approximate visual reference

### 3. Memory Optimization
- Original crops are resized to 150x150 pixels
- Reduces memory usage while maintaining quality
- Displays at 50x50 in the UI (3x for Retina)

## Improving Thumbnail Accuracy

### For Better Results:
1. **Take Clear Photos**: Well-lit, uncluttered angles
2. **Multiple Angles**: Different perspectives help detection
3. **Avoid Overlaps**: Items should be somewhat separated

### Current Limitations:
- GPT-4 Vision doesn't always provide precise bounding boxes
- Overlapping items may share thumbnails
- Very small items might not get accurate crops

## Technical Details

### Coordinate System
- Bounding boxes use normalized coordinates (0.0 to 1.0)
- (0,0) = top-left corner of image
- (1,1) = bottom-right corner of image

### Example Bounding Box:
```json
{
  "x": 0.1,      // 10% from left edge
  "y": 0.7,      // 70% from top edge
  "width": 0.15, // 15% of image width
  "height": 0.2  // 20% of image height
}
```

### Location Grid:
```
┌─────────┬─────────┬─────────┐
│top-left │top-ctr  │top-right│
├─────────┼─────────┼─────────┤
│ctr-left │ center  │ctr-right│
├─────────┼─────────┼─────────┤
│btm-left │btm-ctr  │btm-right│
└─────────┴─────────┴─────────┘
```

## Future Improvements

Planned enhancements include:
- Tap-to-highlight items in full photo
- Manual adjustment of crop areas
- Better handling of overlapping items
- Caching thumbnails between sessions 