import { NextResponse } from 'next/server'
import { addToWaitlist } from '@/lib/supabase'

export async function POST(request: Request) {
  try {
    const { email, utmParams } = await request.json()
    
    // Add to waitlist
    await addToWaitlist(email, utmParams)
    
    // Send Slack notification
    if (process.env.SLACK_WEBHOOK_URL) {
      await fetch(process.env.SLACK_WEBHOOK_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          text: `New signup! 🎉`,
          blocks: [
            {
              type: 'section',
              text: {
                type: 'mrkdwn',
                text: `*New RoomCleaner Beta Signup*\n📧 ${email}\n🔗 Source: ${utmParams.utm_source || 'direct'}`
              }
            }
          ]
        })
      })
    }
    
    // TODO: Send Mailgun welcome email
    
    return NextResponse.json({ success: true })
  } catch (error) {
    console.error('Signup error:', error)
    return NextResponse.json({ error: 'Failed to process signup' }, { status: 500 })
  }
}