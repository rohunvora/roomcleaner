# Room Cleaner Landing Page

Marketing website for Room Cleaner iOS app. Built with Next.js 14, Tailwind CSS, and Supabase.

Live at: [roomcleaner.vercel.app](https://roomcleaner.vercel.app)

## Development

```bash
npm install
npm run dev     # http://localhost:3000
```

## Key Features

- Server-side rendered for performance
- Animated AI detection demo
- Email waitlist signup
- Mobile-optimized design

## Configuration

Create `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=your_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_key
```

## Copy Management

All website text is in `lib/copy.ts` for easy editing.

## Deployment

Deploys automatically to Vercel on push to main branch.

---

See [parent directory README](../README.md) for full project documentation.