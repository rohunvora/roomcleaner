#!/usr/bin/env python3
"""
Vision Detection Test Suite for Room Cleaner
Tests GPT-4 Vision's ability to detect objects in messy room images
"""

import os
import json
import base64
import time
from datetime import datetime
from pathlib import Path
import requests
from typing import List, Dict, Any

# Load environment variables from .env file
def load_env():
    env_path = Path(__file__).parent / '.env'
    if env_path.exists():
        with open(env_path) as f:
            for line in f:
                if '=' in line and not line.strip().startswith('#'):
                    key, value = line.strip().split('=', 1)
                    os.environ[key] = value

load_env()

# Configuration
API_KEY = os.environ.get('OPENAI_API_KEY', '')
API_URL = "https://api.openai.com/v1/chat/completions"
TEST_IMAGES_DIR = Path("/Users/satoshi/roomcleaner/test_images")
RESULTS_DIR = Path("/Users/satoshi/roomcleaner/test_results")

# Create results directory
RESULTS_DIR.mkdir(exist_ok=True)

def encode_image(image_path: str) -> str:
    """Encode image to base64"""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def detect_objects(image_path: Path) -> Dict[str, Any]:
    """Call GPT-4 Vision API to detect objects in image"""
    
    # Get file extension and determine MIME type
    ext = image_path.suffix.lower()
    mime_type = "image/jpeg" if ext in ['.jpg', '.jpeg'] else "image/webp"
    
    base64_image = encode_image(str(image_path))
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }
    
    # Optimized prompt for object detection
    prompt = """You are an expert object detection system. Analyze this image of a messy room and identify ALL visible objects.

For EACH distinct object you can see, provide:
1. A clear, specific label (e.g., "blue t-shirt", "iPhone charger", "water bottle")
2. Confidence score (0.0-1.0)
3. Bounding box coordinates (x, y, width, height) as percentages of image dimensions
4. Category (clothes, electronics, papers, books, trash, toiletries, food, furniture, misc)

Rules:
- Detect EVERY visible object, even partially visible ones
- Be specific with labels (not just "item" or "object")
- Include items on surfaces, floor, furniture, in piles
- Distinguish between similar items (e.g., multiple shirts)
- Include small items like pens, cables, wrappers

Return ONLY a JSON object with this exact structure:
{
  "objects": [
    {
      "label": "string",
      "confidence": 0.0-1.0,
      "boundingBox": {"x": 0-100, "y": 0-100, "width": 0-100, "height": 0-100},
      "category": "string"
    }
  ],
  "totalObjectCount": number
}"""
    
    payload = {
        "model": "gpt-4o",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": prompt
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:{mime_type};base64,{base64_image}",
                            "detail": "high"
                        }
                    }
                ]
            }
        ],
        "max_tokens": 4096,
        "temperature": 0.1
    }
    
    response = requests.post(API_URL, headers=headers, json=payload)
    return response.json()

def extract_detection_result(response: Dict[str, Any]) -> Dict[str, Any]:
    """Extract detection results from API response"""
    try:
        content = response['choices'][0]['message']['content']
        
        # Find JSON in the response
        start_idx = content.find('{')
        end_idx = content.rfind('}') + 1
        
        if start_idx != -1 and end_idx > start_idx:
            json_str = content[start_idx:end_idx]
            return json.loads(json_str)
        else:
            return {"error": "No JSON found in response", "raw_content": content}
    except Exception as e:
        return {"error": str(e), "response": response}

def analyze_results(all_results: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Generate accuracy report from all test results"""
    
    successful_results = [r for r in all_results if 'objects' in r.get('detection_result', {})]
    failed_results = [r for r in all_results if 'objects' not in r.get('detection_result', {})]
    
    total_objects = sum(len(r['detection_result']['objects']) for r in successful_results)
    
    # Category breakdown
    category_counts = {}
    confidence_levels = {"high": 0, "medium": 0, "low": 0}
    
    for result in successful_results:
        for obj in result['detection_result']['objects']:
            # Category
            category = obj.get('category', 'unknown')
            category_counts[category] = category_counts.get(category, 0) + 1
            
            # Confidence
            conf = obj.get('confidence', 0)
            if conf >= 0.8:
                confidence_levels["high"] += 1
            elif conf >= 0.5:
                confidence_levels["medium"] += 1
            else:
                confidence_levels["low"] += 1
    
    avg_objects_per_image = total_objects / len(successful_results) if successful_results else 0
    
    return {
        "timestamp": datetime.now().isoformat(),
        "total_images_processed": len(all_results),
        "successful_detections": len(successful_results),
        "failed_detections": len(failed_results),
        "total_objects_detected": total_objects,
        "average_objects_per_image": round(avg_objects_per_image, 1),
        "category_breakdown": category_counts,
        "confidence_distribution": confidence_levels,
        "failed_images": [r['image_name'] for r in failed_results]
    }

def main():
    """Run the test suite"""
    
    print("🔍 Room Cleaner Vision Detection Test Suite")
    print("==========================================\n")
    
    # Check API key
    if not API_KEY:
        print("❌ Error: OPENAI_API_KEY environment variable not set")
        print("Run: export OPENAI_API_KEY='your-key-here'")
        return
    
    # Get test images
    test_images = list(TEST_IMAGES_DIR.glob("*"))
    test_images = [img for img in test_images if img.suffix.lower() in ['.jpg', '.jpeg', '.webp', '.png']]
    
    print(f"Found {len(test_images)} test images\n")
    
    all_results = []
    
    # Process each image
    for idx, image_path in enumerate(test_images):
        print(f"Processing {idx + 1}/{len(test_images)}: {image_path.name}")
        
        start_time = time.time()
        
        try:
            # Call API
            response = detect_objects(image_path)
            detection_result = extract_detection_result(response)
            
            processing_time = time.time() - start_time
            
            result = {
                "image_name": image_path.name,
                "image_path": str(image_path),
                "processing_time": round(processing_time, 2),
                "detection_result": detection_result,
                "timestamp": datetime.now().isoformat()
            }
            
            # Save individual result
            result_path = RESULTS_DIR / f"{image_path.stem}_result.json"
            with open(result_path, 'w') as f:
                json.dump(result, f, indent=2)
            
            if 'objects' in detection_result:
                object_count = len(detection_result['objects'])
                print(f"  ✓ Detected {object_count} objects in {processing_time:.1f}s")
            else:
                print(f"  ✗ Detection failed: {detection_result.get('error', 'Unknown error')}")
            
            all_results.append(result)
            
        except Exception as e:
            print(f"  ✗ Error: {str(e)}")
            all_results.append({
                "image_name": image_path.name,
                "error": str(e)
            })
        
        # Rate limiting
        time.sleep(1)
    
    # Generate report
    print("\n📊 Generating accuracy report...")
    report = analyze_results(all_results)
    
    # Save report
    report_path = RESULTS_DIR / "accuracy_report.json"
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    # Save human-readable summary
    summary = f"""# Vision Detection Accuracy Report

Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}

## Overview
- **Total Images Processed**: {report['total_images_processed']}
- **Successful Detections**: {report['successful_detections']}
- **Failed Detections**: {report['failed_detections']}
- **Total Objects Detected**: {report['total_objects_detected']}
- **Average Objects per Image**: {report['average_objects_per_image']}

## Category Breakdown
{chr(10).join(f"- {cat}: {count}" for cat, count in sorted(report['category_breakdown'].items()))}

## Confidence Distribution
- High (≥0.8): {report['confidence_distribution']['high']}
- Medium (0.5-0.8): {report['confidence_distribution']['medium']}
- Low (<0.5): {report['confidence_distribution']['low']}

## Failed Images
{chr(10).join(f"- {img}" for img in report['failed_images']) if report['failed_images'] else "None"}
"""
    
    summary_path = RESULTS_DIR / "SUMMARY.md"
    with open(summary_path, 'w') as f:
        f.write(summary)
    
    print(f"\n✅ Test suite complete!")
    print(f"📁 Results saved to: {RESULTS_DIR}")
    print(f"📄 Summary: {summary_path}")
    
    # Print quick summary
    print(f"\n📈 Quick Summary:")
    print(f"   - Detected {report['total_objects_detected']} total objects")
    print(f"   - Average {report['average_objects_per_image']} objects per image")
    if report['failed_images']:
        print(f"   - {len(report['failed_images'])} images failed")

if __name__ == "__main__":
    main()