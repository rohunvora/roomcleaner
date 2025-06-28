'use client'

import { useState, useEffect } from 'react'
import { addToWaitlist } from '@/lib/supabase'
import Image from 'next/image'

export default function Home() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [utmParams, setUtmParams] = useState({})
  const [expandedFaq, setExpandedFaq] = useState<number | null>(null)

  useEffect(() => {
    // Capture UTM parameters
    const params = new URLSearchParams(window.location.search)
    const utm: Record<string, string> = {}
    params.forEach((value, key) => {
      if (key.startsWith('utm_') || key === 'ad') {
        utm[key] = value
      }
    })
    setUtmParams(utm)
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email || loading) return

    setLoading(true)
    try {
      const response = await fetch('/api/signup', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ email, utmParams })
      })
      
      if (!response.ok) throw new Error('Signup failed')
      
      setSubmitted(true)
      
      // Track conversion
      if (typeof window !== 'undefined' && (window as any).posthog) {
        (window as any).posthog.capture('form_submit', {
          email,
          ...utmParams
        })
      }
    } catch (error) {
      console.error('Error:', error)
      alert('Something went wrong. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const faqs = [
    {
      q: "How does the AI detection work?",
      a: "We use advanced computer vision to identify every item in your photos, then create a personalized organization plan just for your space."
    },
    {
      q: "What if it misses some items?",
      a: "Our quick-add feature lets you tap to add any missed items in under 10 seconds. The more you use it, the smarter it gets."
    },
    {
      q: "Is my data private?",
      a: "Absolutely. Photos are processed on-device when possible, and any cloud processing is encrypted and deleted after analysis."
    },
    {
      q: "When will the app launch?",
      a: "We're launching the TestFlight beta in January 2025. Early adopters get lifetime pricing at S$5/mo."
    }
  ]

  return (
    <main className="min-h-screen bg-dark-bg">
      {/* Hero Section */}
      <section className="relative overflow-hidden px-6 py-24 sm:py-32 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <h1 className="text-4xl font-bold tracking-tight sm:text-6xl mb-6">
            Your messy room,<br />fixed in 60 seconds.
          </h1>
          <p className="text-lg leading-8 text-gray-300 mb-10">
            Snap 5 photos → AI spits out a storage map.
          </p>
          
          {!submitted ? (
            <form onSubmit={handleSubmit} className="mt-10 flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 rounded-md bg-white/10 px-4 py-3 text-white placeholder:text-gray-400 border border-white/20 focus:border-neon-green focus:outline-none"
                required
              />
              <button
                type="submit"
                disabled={loading}
                className="glow-button rounded-md px-8 py-3 text-sm font-semibold text-black hover:text-black disabled:opacity-50"
              >
                {loading ? 'Joining...' : 'Join TestFlight Beta'}
              </button>
            </form>
          ) : (
            <div className="mt-10 p-6 rounded-lg bg-neon-green/10 border border-neon-green/30 max-w-md mx-auto">
              <p className="text-neon-green font-semibold mb-2">🎉 You're on the list!</p>
              <p className="text-gray-300">Check your email for next steps.</p>
            </div>
          )}
        </div>

        {/* Hero Image */}
        <div className="mt-16 flow-root sm:mt-24">
          <div className="relative mx-auto max-w-4xl">
            <div className="relative rounded-xl bg-gray-900/50 p-2">
              <img
                src="/hero.svg"
                alt="Before and after room organization with AI detection"
                className="rounded-lg shadow-2xl ring-1 ring-white/10 w-full"
              />
            </div>
          </div>
        </div>
      </section>

      {/* Pricing Preview */}
      <section className="py-16 px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <div className="rounded-2xl bg-gradient-to-b from-neon-green/20 to-neon-green/5 p-8 ring-1 ring-neon-green/20">
            <h3 className="text-2xl font-bold mb-4">Launch Pricing</h3>
            <p className="text-3xl font-bold text-neon-green mb-2">S$9.99/mo</p>
            <p className="text-gray-300">after beta</p>
            <p className="mt-4 text-sm text-neon-green font-semibold">
              ✨ First 200 beta users keep S$5/mo forever
            </p>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-16 px-6 lg:px-8">
        <div className="mx-auto max-w-4xl">
          <h2 className="text-3xl font-bold text-center mb-12">How it works</h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="mx-auto h-16 w-16 rounded-full bg-neon-green/20 flex items-center justify-center mb-4">
                <span className="text-2xl">📸</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">Shoot</h3>
              <p className="text-gray-400">Snap photos of your messy room, drawers, and closets</p>
            </div>
            <div className="text-center">
              <div className="mx-auto h-16 w-16 rounded-full bg-neon-green/20 flex items-center justify-center mb-4">
                <span className="text-2xl">🤖</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">We label</h3>
              <p className="text-gray-400">AI detects every item and creates your organization plan</p>
            </div>
            <div className="text-center">
              <div className="mx-auto h-16 w-16 rounded-full bg-neon-green/20 flex items-center justify-center mb-4">
                <span className="text-2xl">✅</span>
              </div>
              <h3 className="text-xl font-semibold mb-2">You act</h3>
              <p className="text-gray-400">Follow simple tasks to transform your space</p>
            </div>
          </div>
        </div>
      </section>

      {/* Pain to Payoff */}
      <section className="py-16 px-6 lg:px-8">
        <div className="mx-auto max-w-2xl">
          <div className="space-y-4">
            <div className="flex gap-4">
              <span className="text-red-500">❌</span>
              <p className="text-gray-300">Staring at the mess, paralyzed, not knowing where to start</p>
            </div>
            <div className="flex gap-4">
              <span className="text-neon-green">✅</span>
              <p className="text-gray-300">Clear, bite-sized tasks that take 5 minutes each</p>
            </div>
            <div className="flex gap-4">
              <span className="text-red-500">❌</span>
              <p className="text-gray-300">Losing items daily, buying duplicates you already own</p>
            </div>
            <div className="flex gap-4">
              <span className="text-neon-green">✅</span>
              <p className="text-gray-300">Visual map of where everything belongs</p>
            </div>
            <div className="flex gap-4">
              <span className="text-red-500">❌</span>
              <p className="text-gray-300">"Just clean your room" - easier said than done with ADHD</p>
            </div>
            <div className="flex gap-4">
              <span className="text-neon-green">✅</span>
              <p className="text-gray-300">Built by people with ADHD, for people with ADHD</p>
            </div>
          </div>
        </div>
      </section>

      {/* Beta Counter */}
      <section className="py-16 px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <div className="inline-flex items-center gap-2 rounded-full bg-white/10 px-6 py-3 text-sm">
            <span className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-neon-green opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-neon-green"></span>
            </span>
            <span>127 / 200 beta spots remaining</span>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-16 px-6 lg:px-8">
        <div className="mx-auto max-w-2xl">
          <h2 className="text-3xl font-bold text-center mb-12">FAQ</h2>
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <div key={index} className="border border-white/10 rounded-lg overflow-hidden">
                <button
                  onClick={() => setExpandedFaq(expandedFaq === index ? null : index)}
                  className="w-full px-6 py-4 text-left flex justify-between items-center hover:bg-white/5"
                >
                  <span className="font-medium">{faq.q}</span>
                  <span className="text-gray-400">{expandedFaq === index ? '−' : '+'}</span>
                </button>
                {expandedFaq === index && (
                  <div className="px-6 pb-4">
                    <p className="text-gray-400">{faq.a}</p>
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Footer */}
      <footer className="border-t border-white/10 mt-24 py-12 px-6 lg:px-8">
        <div className="mx-auto max-w-4xl flex flex-col sm:flex-row justify-between items-center gap-4">
          <div className="text-sm text-gray-400">
            © 2025 RoomCleaner AI. All rights reserved.
          </div>
          <div className="flex gap-6 text-sm">
            <a href="/privacy" className="text-gray-400 hover:text-white">Privacy</a>
            <a href="/terms" className="text-gray-400 hover:text-white">Terms</a>
            <a href="mailto:support@roomcleaner.ai" className="text-gray-400 hover:text-white">support@roomcleaner.ai</a>
          </div>
        </div>
      </footer>
    </main>
  )
}