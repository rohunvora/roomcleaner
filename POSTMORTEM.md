# Post-mortem – RoomCleaner v1.0

_Date: 2025-07-08_

---

## 1. Original goal
Build a delightful AI assistant that helps people with ADHD clean messy rooms by automatically detecting items and turning them into a simple checklist.

## 2. Status quo ante
• iOS app compiled but required test images and manual API keys.  
• Marketing site existed but duplicated mock data and had no clear README.  
• No environment example file; onboarding friction was high.  
• Duplicate detection arrays in several places.

## 3. What blocked completion
1. **Scope creep** – parallel experiments (YOLO, multi-pass Vision, SwiftUI animations).  
2. **Time** – only one contributor; OpenAI API changes mid-build.  
3. **Missing boilerplate** – env management, docs, mock data reuse.  
4. **Complexity** – spatial detection prompt engineering took longer than expected.

## 4. Decisions taken to ship v1 today
1. Wrote a unified README with quick-start and architecture diagram.  
2. Added `.env.example` so new devs can run both apps fast.  
3. Centralised mock detections in `landing/lib/hardcodedDetections.ts` and imported them everywhere.  
4. Added this post-mortem for transparency and future onboarding.

## 5. Future improvements
1. Replace GridGPT with YOLO → GPT pipeline for higher precision.  
2. Add Android + web PWA.  
3. Persist cleaning sessions to a backend.  
4. Optimise API costs by cropping before sending to GPT-4V.  
5. Accessibility & localisation. 