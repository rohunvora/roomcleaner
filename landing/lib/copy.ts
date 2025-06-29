export const copy = {
  hero: {
    title: "Your messy room, fixed in 60 seconds.",
    subtitle: "Snap 5 photos → AI sends you a step-by-step storage map. Stop hunting for chargers and hoodies.",
    cta: "Sign up for beta",
    ctaLoading: "...",
    successMessage: "✓ You're on the list! Check your email."
  },
  
  howItWorks: {
    title: "How it works",
    steps: [
      {
        number: "1",
        title: "Shoot",
        description: "Take up to 5 photos of any corner, drawer, or closet."
      },
      {
        number: "2", 
        title: "We label",
        description: "Our vision model tags every item and finds the optimal storage layout.",
        note: "Processing < 30 sec per photo. Stored encrypted, deleted on request."
      },
      {
        number: "3",
        title: "You act",
        description: "Follow the plan; tap \"done\" to archive and revisit anytime."
      }
    ]
  },
  
  benefits: {
    title: "Why sign up now",
    items: [
      {
        problem: "Always misplacing stuff →",
        solution: "Know exactly which drawer your passport lives in—without tearing the room apart."
      },
      {
        problem: "Weekend deep-cleans dragging on →",
        solution: "Turn a 4-hour Sunday clean into 40 minutes."
      },
      {
        problem: "Anxiety from clutter →",
        solution: "External order → internal calm. Science backs it; try and feel the delta."
      }
    ]
  },
  
  testimonials: [
    {
      quote: "I've suffered from being messy my whole life, now I have a place for everything.",
      author: "beta user #17"
    },
    {
      quote: "This made my brain more organized in the process.",
      author: "beta user #42"
    }
  ],
  
  faq: {
    title: "FAQ",
    items: [
      {
        question: "Is there an app yet?",
        answer: "We're finishing iOS TestFlight. Early buyers get invites first."
      },
      {
        question: "What if the AI misses stuff?",
        answer: "You can drag boxes or add items manually; we retrain on every correction."
      },
      {
        question: "Can I delete my photos?",
        answer: "Yes—one tap purge in account settings or email us."
      },
      {
        question: "Refund policy?",
        answer: "Full refund within 14 days—no questions asked."
      }
    ]
  },
  
  finalCta: {
    title: "Stop losing things. Start organizing.",
    button: "Get beta access",
    successMessage: "✓ Check your email for beta access"
  },
  
  footer: {
    tagline: "Built in NYC by ex-messy people.",
    links: {
      privacy: "Privacy",
      terms: "Terms",
      email: "emailrohun@gmail.com"
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