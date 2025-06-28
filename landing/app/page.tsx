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
    <main className="min-h-screen bg-dark-bg overflow-x-hidden">
      {/* Background gradient */}
      <div className="fixed inset-0 hero-gradient opacity-50" />
      
      {/* Hero Section */}
      <section className="relative px-6 py-24 sm:py-32 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          {/* Beta badge */}
          <div className="mb-8 inline-flex items-center rounded-full px-3 py-1 text-sm font-medium bg-neon-green/10 text-neon-green ring-1 ring-neon-green/20">
            <span className="pulse-glow">🚀 Beta launching January 2025</span>
          </div>
          
          <h1 className="text-5xl font-bold tracking-tight sm:text-7xl mb-6 bg-gradient-to-r from-white to-gray-400 bg-clip-text text-transparent">
            Your messy room,<br />
            <span className="text-neon-green">fixed in 60 seconds.</span>
          </h1>
          <p className="text-xl leading-8 text-gray-300 mb-10">
            Snap 5 photos → AI spits out a storage map → Follow simple tasks
          </p>
          
          {!submitted ? (
            <form onSubmit={handleSubmit} className="mt-10 flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 rounded-xl bg-white/5 px-5 py-4 text-white placeholder:text-gray-500 border border-white/10 focus:border-neon-green focus:outline-none focus:ring-2 focus:ring-neon-green/20 transition-all"
                required
              />
              <button
                type="submit"
                disabled={loading}
                className="glow-button rounded-xl px-8 py-4 text-base font-semibold text-black hover:text-black disabled:opacity-50"
              >
                {loading ? (
                  <span className="flex items-center gap-2">
                    <svg className="animate-spin h-5 w-5" viewBox="0 0 24 24">
                      <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4" fill="none" />
                      <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z" />
                    </svg>
                    Joining...
                  </span>
                ) : 'Join TestFlight Beta'}
              </button>
            </form>
          ) : (
            <div className="mt-10 p-6 rounded-2xl bg-gradient-to-br from-neon-green/20 to-neon-green/5 border border-neon-green/30 max-w-md mx-auto card-gradient">
              <div className="flex items-center gap-3 mb-3">
                <div className="h-12 w-12 rounded-full bg-neon-green/20 flex items-center justify-center">
                  <span className="text-2xl">🎉</span>
                </div>
                <div className="text-left">
                  <p className="text-neon-green font-semibold text-lg">You're on the list!</p>
                  <p className="text-gray-400 text-sm">Check your email for next steps</p>
                </div>
              </div>
            </div>
          )}
          
          {/* Social proof */}
          <div className="mt-12 flex items-center justify-center gap-8 text-sm text-gray-400">
            <div className="flex items-center gap-2">
              <span className="text-neon-green font-semibold">2,847</span>
              <span>people with ADHD waiting</span>
            </div>
          </div>
        </div>

        {/* Hero Image */}
        <div className="mt-20 flow-root sm:mt-24">
          <div className="relative mx-auto max-w-5xl">
            <div className="absolute inset-0 bg-gradient-to-t from-dark-bg via-transparent to-transparent z-10" />
            <div className="relative rounded-2xl bg-gradient-to-br from-gray-900/50 to-gray-900/20 p-1 ring-1 ring-white/10">
              <img
                src="/hero-v2.svg"
                alt="Before and after room organization with AI detection"
                className="rounded-xl shadow-2xl w-full"
              />
              <div className="absolute -bottom-4 -right-4 bg-neon-green text-black px-4 py-2 rounded-full font-semibold text-sm shadow-lg float">
                ✨ Real AI detection
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Features Grid */}
      <section className="py-24 px-6 lg:px-8 relative">
        <div className="mx-auto max-w-6xl">
          <div className="text-center mb-16">
            <h2 className="text-3xl sm:text-4xl font-bold mb-4">
              Built for ADHD brains
            </h2>
            <p className="text-xl text-gray-400">
              We know "just clean your room" isn't helpful advice
            </p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {[
              {
                icon: "🧠",
                title: "Zero decisions",
                desc: "AI decides where everything goes. You just follow."
              },
              {
                icon: "⚡",
                title: "5-minute tasks",
                desc: "Bite-sized chunks you can actually finish."
              },
              {
                icon: "🎯",
                title: "Visual guidance",
                desc: "See exactly what to pick up with highlighted boxes."
              },
              {
                icon: "🏆",
                title: "Instant wins",
                desc: "Dopamine hits with every completed micro-task."
              },
              {
                icon: "📍",
                title: "Never lose items",
                desc: "Everything gets a home. Search finds it instantly."
              },
              {
                icon: "🔄",
                title: "Maintains itself",
                desc: "Daily 2-minute tidies keep chaos away."
              }
            ].map((feature, i) => (
              <div key={i} className="group relative p-6 rounded-2xl bg-white/5 border border-white/10 hover:border-neon-green/50 transition-all hover:shadow-lg hover:shadow-neon-green/10">
                <div className="text-4xl mb-4">{feature.icon}</div>
                <h3 className="text-xl font-semibold mb-2">{feature.title}</h3>
                <p className="text-gray-400">{feature.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing Preview */}
      <section className="py-24 px-6 lg:px-8 relative">
        <div className="mx-auto max-w-2xl">
          <div className="relative">
            <div className="absolute -inset-4 bg-gradient-to-r from-neon-green/20 to-emerald-500/20 blur-xl opacity-50" />
            <div className="relative rounded-3xl bg-gradient-to-b from-white/10 to-white/5 p-8 sm:p-12 ring-1 ring-white/10">
              <div className="text-center">
                <div className="inline-flex items-center gap-2 rounded-full bg-neon-green/10 px-3 py-1 text-sm font-medium text-neon-green mb-4">
                  Limited time offer
                </div>
                <h3 className="text-3xl font-bold mb-2">Early Bird Pricing</h3>
                <div className="mt-6 flex items-baseline justify-center gap-2">
                  <span className="text-5xl font-bold text-neon-green">S$5</span>
                  <span className="text-xl text-gray-400">/month</span>
                </div>
                <p className="mt-2 text-gray-400 line-through">Regular price: S$9.99/mo</p>
                <p className="mt-6 text-sm font-medium text-neon-green">
                  ✨ First 200 beta users lock in this price forever
                </p>
                <div className="mt-8 flex items-center justify-center gap-4 text-sm text-gray-400">
                  <span className="flex items-center gap-1">
                    <svg className="w-4 h-4 text-neon-green" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                    Cancel anytime
                  </span>
                  <span className="flex items-center gap-1">
                    <svg className="w-4 h-4 text-neon-green" fill="currentColor" viewBox="0 0 20 20">
                      <path fillRule="evenodd" d="M16.707 5.293a1 1 0 010 1.414l-8 8a1 1 0 01-1.414 0l-4-4a1 1 0 011.414-1.414L8 12.586l7.293-7.293a1 1 0 011.414 0z" clipRule="evenodd" />
                    </svg>
                    All features included
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* How It Works */}
      <section className="py-24 px-6 lg:px-8 relative">
        <div className="mx-auto max-w-4xl">
          <h2 className="text-3xl sm:text-4xl font-bold text-center mb-16">
            60 seconds to organized
          </h2>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8 md:gap-12">
            {[
              {
                step: "1",
                emoji: "📸",
                title: "Snap photos",
                desc: "Quick shots of your room, drawers, closet"
              },
              {
                step: "2", 
                emoji: "🤖",
                title: "AI analyzes",
                desc: "Identifies every item and creates your plan"
              },
              {
                step: "3",
                emoji: "✅", 
                title: "Follow tasks",
                desc: "Simple 5-minute chunks until done"
              }
            ].map((item, i) => (
              <div key={i} className="relative text-center group">
                {i < 2 && (
                  <div className="hidden md:block absolute top-16 left-full w-full h-0.5 bg-gradient-to-r from-white/20 to-transparent" />
                )}
                <div className="mx-auto h-32 w-32 rounded-full bg-white/5 flex items-center justify-center mb-6 group-hover:bg-white/10 transition-colors">
                  <div className="text-5xl">{item.emoji}</div>
                  <div className="absolute -top-2 -right-2 h-8 w-8 rounded-full bg-neon-green text-black flex items-center justify-center font-bold text-sm">
                    {item.step}
                  </div>
                </div>
                <h3 className="text-xl font-semibold mb-2">{item.title}</h3>
                <p className="text-gray-400">{item.desc}</p>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Social Proof */}
      <section className="py-24 px-6 lg:px-8 bg-white/5">
        <div className="mx-auto max-w-6xl">
          <div className="grid grid-cols-1 md:grid-cols-2 gap-12 items-center">
            <div>
              <h2 className="text-3xl sm:text-4xl font-bold mb-8">
                Join thousands reclaiming their space
              </h2>
              <div className="space-y-6">
                {[
                  {
                    text: "Finally, an app that gets how my ADHD brain works. The micro-tasks are genius!",
                    author: "Sarah M.",
                    tag: "Beta Tester"
                  },
                  {
                    text: "I went from disaster zone to organized in one afternoon. Mind blown.",
                    author: "Alex K.", 
                    tag: "Early Adopter"
                  },
                  {
                    text: "The AI actually sees my mess better than I do. It's like having a patient friend help.",
                    author: "Jordan T.",
                    tag: "ADHD Community"
                  }
                ].map((testimonial, i) => (
                  <div key={i} className="p-6 rounded-xl bg-white/5 border border-white/10">
                    <p className="text-gray-300 mb-4 italic">"{testimonial.text}"</p>
                    <div className="flex items-center gap-3">
                      <div className="h-10 w-10 rounded-full bg-gradient-to-br from-neon-green/20 to-emerald-500/20" />
                      <div>
                        <p className="font-medium">{testimonial.author}</p>
                        <p className="text-sm text-gray-500">{testimonial.tag}</p>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
            <div className="relative">
              <div className="absolute inset-0 bg-gradient-to-br from-neon-green/20 to-transparent blur-3xl" />
              <div className="relative bg-white/5 rounded-2xl p-8 border border-white/10">
                <h3 className="text-2xl font-bold mb-6">The ADHD tax is real</h3>
                <div className="space-y-4">
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Duplicate purchases</span>
                    <span className="font-semibold">S$127/mo</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Lost item time</span>
                    <span className="font-semibold">14 hrs/mo</span>
                  </div>
                  <div className="flex justify-between items-center">
                    <span className="text-gray-400">Cleaning paralysis</span>
                    <span className="font-semibold">∞ stress</span>
                  </div>
                  <div className="border-t border-white/10 pt-4 mt-4">
                    <div className="flex justify-between items-center">
                      <span className="text-neon-green font-semibold">RoomCleaner cost</span>
                      <span className="text-neon-green font-bold">S$5/mo</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </section>

      {/* Beta Counter */}
      <section className="py-16 px-6 lg:px-8">
        <div className="mx-auto max-w-2xl text-center">
          <div className="inline-flex items-center gap-3 rounded-full bg-white/5 px-6 py-3 text-sm border border-white/10">
            <span className="relative flex h-3 w-3">
              <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-neon-green opacity-75"></span>
              <span className="relative inline-flex rounded-full h-3 w-3 bg-neon-green"></span>
            </span>
            <span className="font-medium">73 / 200 beta spots remaining</span>
            <span className="text-gray-500">• Closes Jan 31</span>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-24 px-6 lg:px-8">
        <div className="mx-auto max-w-2xl">
          <h2 className="text-3xl sm:text-4xl font-bold text-center mb-12">
            Questions? We got you
          </h2>
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <div key={index} className="rounded-xl bg-white/5 border border-white/10 overflow-hidden hover:border-white/20 transition-colors">
                <button
                  onClick={() => setExpandedFaq(expandedFaq === index ? null : index)}
                  className="w-full px-6 py-5 text-left flex justify-between items-center hover:bg-white/5 transition-colors"
                >
                  <span className="font-medium pr-4">{faq.q}</span>
                  <span className={`text-2xl transition-transform ${expandedFaq === index ? 'rotate-45' : ''}`}>+</span>
                </button>
                <div className={`px-6 overflow-hidden transition-all ${expandedFaq === index ? 'pb-5' : 'max-h-0'}`}>
                  <p className="text-gray-400">{faq.a}</p>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-24 px-6 lg:px-8 relative">
        <div className="absolute inset-0 hero-gradient opacity-30" />
        <div className="relative mx-auto max-w-2xl text-center">
          <h2 className="text-3xl sm:text-4xl font-bold mb-6">
            Ready to reclaim your space?
          </h2>
          <p className="text-xl text-gray-300 mb-8">
            Join the beta and finally get organized (for real this time)
          </p>
          {!submitted && (
            <form onSubmit={handleSubmit} className="flex flex-col sm:flex-row gap-4 max-w-md mx-auto">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 rounded-xl bg-white/5 px-5 py-4 text-white placeholder:text-gray-500 border border-white/10 focus:border-neon-green focus:outline-none focus:ring-2 focus:ring-neon-green/20 transition-all"
                required
              />
              <button
                type="submit"
                disabled={loading}
                className="glow-button rounded-xl px-8 py-4 text-base font-semibold text-black hover:text-black disabled:opacity-50"
              >
                {loading ? 'Joining...' : 'Get Early Access'}
              </button>
            </form>
          )}
        </div>
      </section>

      {/* Footer */}
      <footer className="relative border-t border-white/10 mt-24 py-12 px-6 lg:px-8">
        <div className="mx-auto max-w-6xl">
          <div className="grid grid-cols-1 md:grid-cols-4 gap-8">
            <div className="md:col-span-2">
              <h3 className="text-2xl font-bold mb-4 text-neon-green">RoomCleaner AI</h3>
              <p className="text-gray-400 mb-4">
                The first cleaning app designed specifically for ADHD brains. 
                Turn chaos into calm, one micro-task at a time.
              </p>
              <div className="flex gap-4">
                <a href="#" className="text-gray-400 hover:text-white transition-colors">
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M24 12.073c0-6.627-5.373-12-12-12s-12 5.373-12 12c0 5.99 4.388 10.954 10.125 11.854v-8.385H7.078v-3.47h3.047V9.43c0-3.007 1.792-4.669 4.533-4.669 1.312 0 2.686.235 2.686.235v2.953H15.83c-1.491 0-1.956.925-1.956 1.874v2.25h3.328l-.532 3.47h-2.796v8.385C19.612 23.027 24 18.062 24 12.073z"/>
                  </svg>
                </a>
                <a href="#" className="text-gray-400 hover:text-white transition-colors">
                  <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                    <path d="M23.953 4.57a10 10 0 01-2.825.775 4.958 4.958 0 002.163-2.723c-.951.555-2.005.959-3.127 1.184a4.92 4.92 0 00-8.384 4.482C7.69 8.095 4.067 6.13 1.64 3.162a4.822 4.822 0 00-.666 2.475c0 1.71.87 3.213 2.188 4.096a4.904 4.904 0 01-2.228-.616v.06a4.923 4.923 0 003.946 4.827 4.996 4.996 0 01-2.212.085 4.936 4.936 0 004.604 3.417 9.867 9.867 0 01-6.102 2.105c-.39 0-.779-.023-1.17-.067a13.995 13.995 0 007.557 2.209c9.053 0 13.998-7.496 13.998-13.985 0-.21 0-.42-.015-.63A9.935 9.935 0 0024 4.59z"/>
                  </svg>
                </a>
              </div>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Product</h4>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Features</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Pricing</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Beta Program</a></li>
              </ul>
            </div>
            <div>
              <h4 className="font-semibold mb-4">Support</h4>
              <ul className="space-y-2 text-gray-400">
                <li><a href="#" className="hover:text-white transition-colors">Help Center</a></li>
                <li><a href="mailto:support@roomcleaner.ai" className="hover:text-white transition-colors">Contact</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Privacy Policy</a></li>
                <li><a href="#" className="hover:text-white transition-colors">Terms of Service</a></li>
              </ul>
            </div>
          </div>
          <div className="mt-12 pt-8 border-t border-white/10 flex flex-col sm:flex-row justify-between items-center gap-4">
            <p className="text-sm text-gray-400">
              © 2025 RoomCleaner AI. Made with 💚 for the ADHD community.
            </p>
            <div className="flex gap-6 text-sm text-gray-400">
              <span>Singapore 🇸🇬</span>
            </div>
          </div>
        </div>
      </footer>
    </main>
  )
}