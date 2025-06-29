export const copy = {
  hero: {
    title: "A simple system to organize your room using photos",
    subtitle: "Room Cleaner helps you assign everything a place. You take photos, we help you map where things should go. Then you just follow the plan.",
    cta: "Get early access",
    ctaSubtext: "Built for people who've tried everything else.",
    ctaLoading: "...",
    successMessage: "✓ You're on the list! Check your email."
  },
  
  howItWorks: {
    title: "Photos in. System out.",
    steps: [
      {
        emoji: "📸",
        title: "Snap 5–10 photos",
        description: "Just take wide shots of your room from different angles."
      },
      {
        emoji: "🗺️", 
        title: "Get your layout",
        description: "Our AI identifies items and creates a personalized map for your space."
      },
      {
        emoji: "✅",
        title: "Follow your plan",
        description: "Put stuff where it belongs. Use your phone to remember where everything is."
      }
    ],
    clarifier: "No hardware. No extra cleaning tools. Just your phone."
  },
  
  whyMessHappens: {
    title: "You're not disorganized — your space is unassigned.",
    reasons: [
      {
        problem: "No clear home for anything",
        result: "So stuff ends up everywhere."
      },
      {
        problem: "Cleaning takes too much thinking",
        result: "So you avoid it."
      },
      {
        problem: "Systems break fast",
        result: "So you give up."
      }
    ]
  },
  
  whatYouGet: {
    title: "Your room, documented.",
    features: [
      "Visual record of what's where",
      "Personalized zones for each item type",
      "A plan you can reference later",
      "No judgment, no instructions to \"just declutter\""
    ]
  },
  
  testimonials: [
    {
      quote: "It gave me a starting point when I had none. That's what I needed.",
      author: "Real user, ADHD, living alone"
    },
    {
      quote: "Now I don't re-do the same cleanup every week.",
      author: "Beta tester #4"
    }
  ],
  
  pricing: {
    title: "$9/month. Built for people who want to fix the mess, not study it.",
    price: "$9",
    period: "/month",
    features: [
      "Unlimited room scans",
      "Search your visual map anytime",
      "Adjust layout as things change"
    ],
    cta: "Start 14-day trial"
  },
  
  finalCta: {
    title: "Organizing sucks. This helps.",
    button: "Get early access",
    successMessage: "✓ Check your email for early access"
  },
  
  footer: {
    tagline: "Made with ♥ by fellow messy humans",
    links: {
      privacy: "Privacy",
      terms: "Terms",
      email: "hello@roomcleaner.ai"
    }
  },
  
  // Error messages
  errors: {
    signup: "Something went wrong. Please try again."
  },
  
  // Form placeholders
  placeholders: {
    email: "your@email.com"
  }
} as const

// Type-safe helper to get nested values
export type CopyPath = 
  | 'hero.title' 
  | 'hero.subtitle'
  | 'hero.cta'
  // ... add more as needed

export function getCopy(path: string): string {
  const keys = path.split('.')
  let value: any = copy
  
  for (const key of keys) {
    value = value[key]
    if (value === undefined) {
      console.warn(`Copy not found for path: ${path}`)
      return `[Missing: ${path}]`
    }
  }
  
  return value
} 