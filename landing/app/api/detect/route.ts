import { NextRequest, NextResponse } from 'next/server'
import { hardcodedDetections } from '@/lib/hardcodedDetections'

// Type definitions for OpenAI Vision API
interface Detection {
  id: number
  x: number // percentage from left
  y: number // percentage from top
  width: number // percentage width
  height: number // percentage height
  label: string
  category: 'clothing' | 'electronics' | 'books' | 'personal' | 'misc'
  confidence?: number
  delay?: number // animation delay in ms
}

export async function POST(request: NextRequest) {
  try {
    const { imageUrl } = await request.json()
    
    if (!imageUrl) {
      return NextResponse.json({ error: 'Image URL is required' }, { status: 400 })
    }

    const apiKey = process.env.OPENAI_API_KEY
    if (!apiKey) {
      console.error('OpenAI API key not configured')
      // Return mock data if no API key
      return NextResponse.json({ detections: getMockDetections() })
    }

    // Call OpenAI Vision API
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${apiKey}`
      },
      body: JSON.stringify({
        model: 'gpt-4-vision-preview',
        messages: [
          {
            role: 'user',
            content: [
              {
                type: 'text',
                text: `Analyze this messy room image and identify ALL visible items. For each item, provide:
1. A clear, specific label (e.g., "Blue T-shirt", "iPhone", "Chemistry Textbook")
2. Its location as percentages (x, y from top-left, width, height)
3. Category: clothing, electronics, books, personal, or misc

Return a JSON array with this exact format:
[{"id": 1, "x": 15, "y": 20, "width": 10, "height": 8, "label": "Blue T-shirt", "category": "clothing"}]

Be thorough - identify EVERY visible item including small objects, partially visible items, and items in piles. Aim for 20-30 items minimum.`
              },
              {
                type: 'image_url',
                image_url: {
                  url: imageUrl
                }
              }
            ]
          }
        ],
        max_tokens: 2000,
        temperature: 0.3
      })
    })

    if (!response.ok) {
      throw new Error(`OpenAI API error: ${response.statusText}`)
    }

    const data = await response.json()
    const content = data.choices[0].message.content

    // Parse the JSON response
    let detections: Detection[]
    try {
      // Extract JSON from the response (it might be wrapped in markdown code blocks)
      const jsonMatch = content.match(/\[[\s\S]*\]/)
      if (jsonMatch) {
        detections = JSON.parse(jsonMatch[0])
      } else {
        throw new Error('No JSON array found in response')
      }
    } catch (parseError) {
      console.error('Failed to parse OpenAI response:', content)
      return NextResponse.json({ detections: getMockDetections() })
    }

    // Add animation delays based on position
    detections = detections.map((item, index) => ({
      ...item,
      id: index + 1,
      delay: index * 100 // Stagger animations
    }))

    return NextResponse.json({ detections })

  } catch (error) {
    console.error('Detection API error:', error)
    // Return mock data as fallback
    return NextResponse.json({ detections: getMockDetections() })
  }
}

// Fallback mock data
function getMockDetections(): Detection[] {
  // Use the single source of truth for demo detections
  return hardcodedDetections as Detection[]
}