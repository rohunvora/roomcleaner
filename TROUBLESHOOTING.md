# Troubleshooting Room Cleaner iOS App

## "The data couldn't be read because it is missing" Error

This error typically occurs when the OpenAI API response cannot be parsed. Here's how to debug:

### 1. Check Console Logs

Run the app with Xcode and watch the console output. You should see:

**Successful flow:**
```
🎯 Analyzing 1 real photos with OpenAI API
🔑 API Key: sk-proj-__...
🔍 Sending OpenAI request with image size: 245KB
📝 Prompt length: 892 characters
📡 OpenAI response status: 200
📥 Raw API response: {"id":"chatcmpl-...
📝 AI Response content: Here's the detection...
📋 Extracted JSON: {"items":[...
✅ Successfully parsed 25 items and 5 storage areas
```

**Common errors:**
```
❌ Failed to decode OpenAI response: ...
❌ No JSON found in response content
❌ Failed to decode detection response: ...
```

### 2. Common Causes & Solutions

#### Invalid API Key
- **Symptom:** Status code 401
- **Fix:** Check your API key in `Configuration.xcconfig`
- **Test:** Visit https://platform.openai.com/api-keys

#### API Key Not Loaded
- **Symptom:** "OpenAI API key is missing"
- **Fix:** Make sure `Configuration.xcconfig` is in the project root

#### Rate Limit
- **Symptom:** Status code 429
- **Fix:** Wait a bit and try again, or upgrade your OpenAI plan

#### Network Issues
- **Symptom:** Network error messages
- **Fix:** Check internet connection

#### JSON Parsing Issues
- **Symptom:** "No JSON found in response"
- **Fix:** The AI might not be returning proper JSON format

#### JSON Format Mismatch (Fixed)
- **Symptom:** `Missing required field 'items' at path:` error in second pass
- **Cause:** The second pass prompt asked for `new_items` but code expected `items`
- **Status:** This has been fixed in the latest version

### 3. Quick Fixes to Try

1. **Reduce image quality** (uses less tokens):
   - In `APIConfiguration.swift`, change:
   ```swift
   static let jpegCompressionQuality: CGFloat = 0.5 // was 0.7
   ```

2. **Test with a simple prompt**:
   - In `MultiPassVisionAnalyzer.swift`, temporarily replace the prompt with:
   ```swift
   let prompt = "List 3 items you see in this image as JSON: {\"items\": [{\"label\": \"item name\", \"category\": \"other\", \"confidence\": 0.9}], \"storage_areas\": []}"
   ```

3. **Check API usage**:
   - Visit: https://platform.openai.com/usage
   - Make sure you have credits/not over limit

### 4. Enable Maximum Logging

The app already has detailed logging enabled. Look for these emoji markers in console:
- 🎯 = Starting analysis
- 🔍 = Sending request
- 📡 = API response received
- ❌ = Error occurred
- ✅ = Success

### 5. Test API Key Directly

Run this in Terminal to test your API key:
```bash
curl https://api.openai.com/v1/models \
  -H "Authorization: Bearer YOUR_API_KEY_HERE"
```

Should return a list of models if the key is valid.

### 6. Fallback Options

If API continues to fail:
- The app will show "Continue Anyway" button
- This creates a basic cleaning plan
- You can still use the app's task interface

## Other Issues

### Test Images Not Loading
- Check console for: "✅ Loaded test image from dev path"
- If you see "⚠️ Could not load test image", the app will show colored placeholders

### App Crashes
- Check for memory issues with large images
- Try with fewer/smaller test images

### No Items Detected
- Normal for very clean rooms
- App will create a "Manual Room Check" task
- Try with messier test images

### Items Miscategorized
- Example: Bedding items marked as "clothing"
- This has been fixed - pillows/blankets now go to "other" category
- The AI now has clearer category guidelines

## Recent Fixes

### JSON Format Mismatch (June 2024)
- **Issue:** Second pass failed with "Missing required field 'items'"
- **Cause:** Prompt asked for `new_items` but parser expected `items`
- **Solution:** Updated prompt to use correct JSON field names

### Category Improvements (June 2024)
- **Issue:** Pillows and bedding categorized as "clothing"
- **Solution:** Added explicit guidance that bedding goes in "other" category
- **Result:** More accurate categorization

## Need More Help?

1. Check Xcode console for detailed error messages
2. Look for the exact error in the logs
3. Share the full error message and console output for debugging 