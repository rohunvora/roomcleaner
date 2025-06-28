#!/usr/bin/env python3
"""
Vision Detection Test Suite V2 - Improved Prompting
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
RESULTS_DIR = Path("/Users/satoshi/roomcleaner/test_results_v2")

# Create results directory
RESULTS_DIR.mkdir(exist_ok=True)

def encode_image(image_path: str) -> str:
    """Encode image to base64"""
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

def detect_objects_v2(image_path: Path) -> Dict[str, Any]:
    """Improved object detection with better prompting"""
    
    # Get file extension and determine MIME type
    ext = image_path.suffix.lower()
    mime_type = "image/jpeg" if ext in ['.jpg', '.jpeg'] else "image/webp"
    
    base64_image = encode_image(str(image_path))
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {API_KEY}"
    }
    
    # Enhanced prompt for comprehensive detection
    prompt = """You are an advanced object detection system analyzing a messy room. Your task is to identify EVERY visible object, no matter how small or partially visible.

CRITICAL INSTRUCTIONS:
1. Scan the ENTIRE image systematically - left to right, top to bottom
2. Include ALL items, even if they're:
   - Partially visible or obscured
   - Very small (pens, coins, cables)
   - In piles or stacks
   - On the floor, furniture, walls, or any surface
   - In the background

For each object, provide:
- label: Specific name (e.g., "red Nike sneaker", "iPhone charging cable", "crumpled white paper")
- confidence: 0.0-1.0
- boundingBox: {x, y, width, height} as percentages (0-100)
- category: One of [clothes, electronics, papers, books, trash, toiletries, food, furniture, school_supplies, personal_items, misc]

IMPORTANT RULES:
- A messy room typically has 30-60+ visible objects
- Count each distinct item separately (3 shirts = 3 objects)
- Include items like: tissues, wrappers, bottles, chargers, pens, notebooks, bags, shoes, dishes, etc.
- Be EXHAUSTIVE - if you can see it, detect it
- Use descriptive labels with colors/brands when visible

Return ONLY valid JSON:
{
  "objects": [...],
  "totalObjectCount": number,
  "messLevel": "low|medium|high|extreme"
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
        "temperature": 0.2
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

def compare_with_v1(image_name: str, v2_count: int):
    """Compare with V1 results if available"""
    v1_path = Path("/Users/satoshi/roomcleaner/test_results") / f"{image_name.split('.')[0]}_result.json"
    if v1_path.exists():
        with open(v1_path) as f:
            v1_data = json.load(f)
            if 'detection_result' in v1_data and 'objects' in v1_data['detection_result']:
                v1_count = len(v1_data['detection_result']['objects'])
                improvement = ((v2_count - v1_count) / v1_count * 100) if v1_count > 0 else 0
                return v1_count, improvement
    return None, None

def main():
    """Run the improved test suite"""
    
    print("🔍 Room Cleaner Vision Detection Test Suite V2")
    print("============================================\n")
    
    # Check API key
    if not API_KEY:
        print("❌ Error: OPENAI_API_KEY not found in .env file")
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
            response = detect_objects_v2(image_path)
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
                mess_level = detection_result.get('messLevel', 'unknown')
                
                # Compare with V1
                v1_count, improvement = compare_with_v1(image_path.name, object_count)
                
                print(f"  ✓ Detected {object_count} objects (mess level: {mess_level}) in {processing_time:.1f}s")
                if v1_count:
                    print(f"    V1→V2: {v1_count}→{object_count} ({improvement:+.0f}%)")
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
    
    # Generate comparison report
    print("\n📊 Generating comparison report...")
    
    successful_v2 = [r for r in all_results if 'objects' in r.get('detection_result', {})]
    total_objects_v2 = sum(len(r['detection_result']['objects']) for r in successful_v2)
    avg_objects_v2 = total_objects_v2 / len(successful_v2) if successful_v2 else 0
    
    # Category analysis
    category_counts = {}
    for result in successful_v2:
        for obj in result['detection_result']['objects']:
            cat = obj.get('category', 'unknown')
            category_counts[cat] = category_counts.get(cat, 0) + 1
    
    report = {
        "version": "V2",
        "timestamp": datetime.now().isoformat(),
        "total_images": len(test_images),
        "successful": len(successful_v2),
        "total_objects": total_objects_v2,
        "avg_objects_per_image": round(avg_objects_v2, 1),
        "category_breakdown": category_counts,
        "prompt_improvements": [
            "More explicit instructions to be exhaustive",
            "Emphasis on 30-60+ objects expectation",
            "Better category definitions",
            "Added mess level assessment"
        ]
    }
    
    # Save report
    report_path = RESULTS_DIR / "comparison_report.json"
    with open(report_path, 'w') as f:
        json.dump(report, f, indent=2)
    
    print(f"\n✅ Test complete!")
    print(f"📈 V2 Results: {total_objects_v2} objects ({avg_objects_v2:.1f} avg)")
    print(f"📁 Results saved to: {RESULTS_DIR}")

if __name__ == "__main__":
    main()