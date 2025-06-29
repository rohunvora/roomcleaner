import { NextResponse } from 'next/server'
import { addToWaitlist } from '@/lib/supabase'

export async function POST(request: Request) {
  try {
    const formData = await request.formData()
    const email = formData.get('email') as string
    
    if (!email) {
      return NextResponse.redirect(new URL('/?error=missing-email', request.url))
    }

    // Get UTM params from the referrer URL
    const referer = request.headers.get('referer') || ''
    const refererUrl = new URL(referer)
    const utmParams = Object.fromEntries(refererUrl.searchParams.entries())

    await addToWaitlist(email, utmParams)
    
    // Redirect back with success message
    return NextResponse.redirect(new URL('/?success=true', request.url))
  } catch (error) {
    console.error('Signup error:', error)
    return NextResponse.redirect(new URL('/?error=signup-failed', request.url))
  }
}