import { NextRequest, NextResponse } from 'next/server'

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
  return [
    { id: 1, x: 15, y: 65, width: 8, height: 10, label: "T-shirt", category: "clothing", delay: 0 },
    { id: 2, x: 25, y: 70, width: 6, height: 8, label: "Jeans", category: "clothing", delay: 100 },
    { id: 3, x: 70, y: 80, width: 7, height: 6, label: "Socks", category: "clothing", delay: 200 },
    { id: 4, x: 45, y: 75, width: 5, height: 7, label: "Hoodie", category: "clothing", delay: 300 },
    { id: 5, x: 30, y: 40, width: 6, height: 4, label: "Phone", category: "electronics", delay: 400 },
    { id: 6, x: 55, y: 35, width: 10, height: 6, label: "Laptop", category: "electronics", delay: 500 },
    { id: 7, x: 40, y: 45, width: 4, height: 5, label: "Earbuds", category: "electronics", delay: 600 },
    { id: 8, x: 65, y: 50, width: 8, height: 5, label: "Tablet", category: "electronics", delay: 700 },
    { id: 9, x: 10, y: 50, width: 7, height: 5, label: "Textbook", category: "books", delay: 800 },
    { id: 10, x: 20, y: 55, width: 5, height: 3, label: "Notebook", category: "books", delay: 900 }
  ]
}