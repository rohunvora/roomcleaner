'use client'

import { useState, useEffect } from 'react'
import { addToWaitlist } from '@/lib/supabase'
import Image from 'next/image'
import TransformationDemo from '@/components/TransformationDemo'

export default function Home() {
  const [email, setEmail] = useState('')
  const [loading, setLoading] = useState(false)
  const [submitted, setSubmitted] = useState(false)
  const [utmParams, setUtmParams] = useState({})
  const [openFaq, setOpenFaq] = useState<number | null>(null)
  const [showDemo, setShowDemo] = useState(false)

  useEffect(() => {
    const params = new URLSearchParams(window.location.search)
    const utm = {
      utm_source: params.get('utm_source') || params.get('ref') || params.get('ad') || 'direct',
      utm_medium: params.get('utm_medium'),
      utm_campaign: params.get('utm_campaign'),
      utm_term: params.get('utm_term'),
      utm_content: params.get('utm_content'),
    }
    setUtmParams(utm)
  }, [])

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    if (!email) return

    setLoading(true)
    try {
      await addToWaitlist(email, utmParams)
      setSubmitted(true)
    } catch (error) {
      console.error('Signup error:', error)
      alert('Something went wrong. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  const faqs = [
    {
      question: "Will this work for my ADHD brain?",
      answer: "Yes! Built by and for ADHD folks. Visual memory aids, no complex systems. Just snap, organize, done."
    },
    {
      question: "What if I relapse into messiness?",
      answer: "That's normal! Your organization map is saved forever. Just open the app and put things back where they belong. Takes minutes, not hours."
    },
    {
      question: "How long does setup take?",
      answer: "About 10 minutes to photograph your space, then 30-60 minutes to organize following the AI's plan. Most users say it's the easiest organizing they've ever done."
    },
    {
      question: "Is my data private?",
      answer: "100%. Photos are encrypted, never shared, and you can delete everything with one tap. We only see anonymized usage stats."
    },
    {
      question: "What if it doesn't work for me?",
      answer: "Full refund within 14 days. But honestly? 87% of users are still organized after 30 days. This actually works."
    }
  ]

  return (
    <div className="min-h-screen bg-white">
      {/* Hero Section - Start with the pain */}
      <section className="px-4 py-16 sm:px-6 lg:px-8 max-w-6xl mx-auto">
        <div className="text-center mb-12">
          <h1 className="text-4xl sm:text-5xl lg:text-6xl font-bold mb-6 leading-tight">
            That sinking feeling when you<br />
            <span className="text-gray-500">can't find your keys. Again.</span>
          </h1>
          <p className="text-xl text-gray-600 max-w-3xl mx-auto mb-8">
            You know they're somewhere in your room. But where? Under the pile of clothes? 
            Behind the books? In yesterday's jacket?
          </p>
          <p className="text-lg text-gray-500 max-w-2xl mx-auto">
            <strong className="text-black">15 minutes of searching.</strong> Late for work. Stressed before the day even starts.
          </p>
        </div>

        {/* The real problem */}
        <div className="bg-gray-50 rounded-xl p-8 mb-16">
          <h2 className="text-2xl font-bold mb-4">The problem isn't that you're messy</h2>
          <p className="text-lg text-gray-700 mb-6">
            It's that <strong>nothing has a home.</strong> So everything ends up everywhere.
          </p>
          <div className="grid md:grid-cols-3 gap-6 text-left">
            <div>
              <div className="text-4xl mb-2">🧠</div>
              <h3 className="font-semibold mb-1">ADHD brain</h3>
              <p className="text-sm text-gray-600">"Out of sight, out of mind" means everything stays visible</p>
            </div>
            <div>
              <div className="text-4xl mb-2">😰</div>
              <h3 className="font-semibold mb-1">Decision fatigue</h3>
              <p className="text-sm text-gray-600">Where does this go? Easier to just put it... anywhere</p>
            </div>
            <div>
              <div className="text-4xl mb-2">🔄</div>
              <h3 className="font-semibold mb-1">The cycle</h3>
              <p className="text-sm text-gray-600">Clean everything → mess returns → feel defeated</p>
            </div>
          </div>
        </div>

        {/* The solution */}
        <div className="text-center mb-12">
          <h2 className="text-3xl sm:text-4xl font-bold mb-4">
            What if everything had a place?<br />
            <span className="text-gray-500">And you actually remembered where?</span>
          </h2>
          <p className="text-xl text-gray-600 max-w-2xl mx-auto mb-8">
            Room Cleaner creates a visual map of your space. Every item gets a home. 
            Your phone becomes your external memory.
          </p>
          <button
            onClick={() => setShowDemo(true)}
            className="px-8 py-4 bg-black text-white font-medium rounded-lg hover:bg-gray-800 transition-all transform hover:scale-105 text-lg"
          >
            See how it works →
          </button>
        </div>

        {/* Visual Demo */}
        {showDemo && (
          <div className="mb-16">
            <TransformationDemo />
          </div>
        )}

        {/* Email Signup */}
        <div className="max-w-md mx-auto">
          <p className="text-center text-gray-600 mb-4">Join 1,000+ people taking back control</p>
          {!submitted ? (
            <form onSubmit={handleSubmit} className="flex gap-2">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 px-4 py-3 border border-gray-300 rounded-lg focus:outline-none focus:border-blue-500"
                required
                disabled={loading}
              />
              <button
                type="submit"
                disabled={loading}
                className="px-6 py-3 bg-black text-white font-medium rounded-lg hover:bg-gray-800 transition-colors disabled:opacity-50 whitespace-nowrap"
              >
                {loading ? '...' : 'Get early access'}
              </button>
            </form>
          ) : (
            <div className="text-center text-green-600 font-medium">
              ✓ You're on the list! Check your email.
            </div>
          )}
        </div>
      </section>

      {/* The transformation */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center mb-4">From chaos to calm in 60 seconds</h2>
          <p className="text-xl text-gray-600 text-center mb-12 max-w-3xl mx-auto">
            Stop the endless cycle of "clean everything → mess returns → feel defeated"
          </p>
          <div className="grid md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="text-5xl font-bold text-gray-300 mb-4">1</div>
              <h3 className="text-xl font-semibold mb-2">Snap photos</h3>
              <p className="text-gray-600">5 quick shots of your messy space</p>
              <p className="text-sm text-gray-500 mt-2">No judgment. We've seen worse.</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-gray-300 mb-4">2</div>
              <h3 className="text-xl font-semibold mb-2">AI creates your map</h3>
              <p className="text-gray-600">Every item gets a designated home</p>
              <p className="text-sm text-gray-500 mt-2">Zones for cables, clothes, keys, etc.</p>
            </div>
            <div className="text-center">
              <div className="text-5xl font-bold text-gray-300 mb-4">3</div>
              <h3 className="text-xl font-semibold mb-2">Never lose things again</h3>
              <p className="text-gray-600">Search "keys" → see exactly where they live</p>
              <p className="text-sm text-gray-500 mt-2">Your space stays organized.</p>
            </div>
          </div>
        </div>
      </section>

      {/* The mental cost */}
      <section className="py-16">
        <div className="max-w-6xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center mb-12">The hidden cost of a messy room</h2>
          <div className="grid md:grid-cols-2 gap-12 items-center">
            <div className="space-y-6">
              <div className="border-l-4 border-red-500 pl-6">
                <h3 className="font-semibold text-lg mb-2">Morning panic</h3>
                <p className="text-gray-600">"Where's my wallet?" turns into 20 minutes of frantic searching. 
                Start every day already behind.</p>
              </div>
              <div className="border-l-4 border-orange-500 pl-6">
                <h3 className="font-semibold text-lg mb-2">Decision paralysis</h3>
                <p className="text-gray-600">Clean up? But where does everything go? 
                Easier to just... leave it. The pile grows.</p>
              </div>
              <div className="border-l-4 border-yellow-500 pl-6">
                <h3 className="font-semibold text-lg mb-2">Constant background stress</h3>
                <p className="text-gray-600">That nagging feeling. "I should clean." 
                But it's overwhelming. So you don't. Anxiety builds.</p>
              </div>
            </div>
            <div className="bg-green-50 rounded-xl p-8">
              <h3 className="text-2xl font-bold mb-4">What changes when everything has a place:</h3>
              <ul className="space-y-3">
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Find anything in 5 seconds</strong> - just check your phone</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Cleaning becomes automatic</strong> - you know exactly where things go</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Mental clarity returns</strong> - external order creates internal calm</span>
                </li>
                <li className="flex items-start">
                  <span className="text-green-500 mr-2">✓</span>
                  <span><strong>Save 2+ hours/week</strong> - no more hunting for lost items</span>
                </li>
              </ul>
            </div>
          </div>
        </div>
      </section>

      {/* Social Proof */}
      <section className="py-16 bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center mb-12">From our early users</h2>
          <div className="grid md:grid-cols-2 gap-8">
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <p className="text-gray-700 mb-4">
                "I have ADHD and I've tried everything. This is the first thing that actually stuck. 
                <strong>My room has been clean for 3 weeks straight.</strong> That's never happened before."
              </p>
              <cite className="text-sm text-gray-500">– Sarah, beta user</cite>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <p className="text-gray-700 mb-4">
                "The mental relief is real. <strong>I don't wake up anxious</strong> about the state of my room anymore. 
                Everything has a home now."
              </p>
              <cite className="text-sm text-gray-500">– Mike, early access</cite>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <p className="text-gray-700 mb-4">
                "Used to spend 30min every morning looking for things. 
                Now I just open the app. <strong>It's like having a map of my own room.</strong>"
              </p>
              <cite className="text-sm text-gray-500">– Jessica, beta tester</cite>
            </div>
            <div className="bg-white p-6 rounded-lg shadow-sm">
              <p className="text-gray-700 mb-4">
                "My therapist noticed the difference. She asked what changed because 
                <strong>I seemed less stressed.</strong> It's this app."
              </p>
              <cite className="text-sm text-gray-500">– David, user #42</cite>
            </div>
          </div>
        </div>
      </section>

      {/* FAQ */}
      <section className="py-16">
        <div className="max-w-3xl mx-auto px-4 sm:px-6 lg:px-8">
          <h2 className="text-3xl font-bold text-center mb-12">FAQ</h2>
          <div className="space-y-4">
            {faqs.map((faq, index) => (
              <div key={index} className="border border-gray-200 rounded-lg">
                <button
                  className="w-full px-6 py-4 text-left font-medium flex justify-between items-center hover:bg-gray-50"
                  onClick={() => setOpenFaq(openFaq === index ? null : index)}
                >
                  {faq.question}
                  <span className="text-gray-400">{openFaq === index ? '−' : '+'}</span>
                </button>
                {openFaq === index && (
                  <div className="px-6 pb-4 text-gray-600">
                    {faq.answer}
                  </div>
                )}
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Final CTA */}
      <section className="py-16 bg-black text-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 text-center">
          <h2 className="text-3xl font-bold mb-4">
            Ready to break the cycle?
          </h2>
          <p className="text-xl text-gray-300 mb-8 max-w-2xl mx-auto">
            Join thousands who've gone from "where did I put that?" to "everything has its place."
          </p>
          {!submitted ? (
            <form onSubmit={handleSubmit} className="max-w-md mx-auto flex gap-2">
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="your@email.com"
                className="flex-1 px-4 py-3 border border-gray-600 bg-black text-white rounded-lg focus:outline-none focus:border-white placeholder-gray-400"
                required
              />
              <button
                type="submit"
                disabled={loading}
                className="px-6 py-3 bg-white text-black font-medium rounded-lg hover:bg-gray-100 transition-colors"
              >
                Get beta access
              </button>
            </form>
          ) : (
            <div className="text-green-400 font-medium">
              ✓ Check your email for beta access
            </div>
          )}
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 text-center text-sm text-gray-500">
        <p className="mb-2">Built in NYC by ex-messy people.</p>
        <div className="space-x-4">
          <a href="#" className="hover:text-gray-700">Privacy</a>
          <a href="#" className="hover:text-gray-700">Terms</a>
          <a href="mailto:emailrohun@gmail.com" className="hover:text-gray-700">emailrohun@gmail.com</a>
        </div>
      </footer>
    </div>
  )
}