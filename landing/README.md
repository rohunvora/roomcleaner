# RoomCleaner Landing Page

Landing page for RoomCleaner AI - deployed at roomcleaner.ai

## Quick Deploy

1. **Install dependencies**
   ```bash
   npm install
   ```

2. **Set up environment variables**
   - Copy `.env.local.example` to `.env.local`
   - Add your Supabase, Mailgun, and Slack credentials

3. **Run locally**
   ```bash
   npm run dev
   ```

4. **Deploy to Vercel**
   ```bash
   vercel
   ```

## Environment Variables

Required for production:
- `NEXT_PUBLIC_SUPABASE_URL` - Supabase project URL
- `NEXT_PUBLIC_SUPABASE_ANON_KEY` - Supabase anon key
- `SLACK_WEBHOOK_URL` - Slack webhook for signup notifications
- `MAILGUN_API_KEY` - Mailgun API key (optional for now)
- `MAILGUN_DOMAIN` - Mailgun domain (optional for now)

## Campaign Tracking

Use UTM parameters for tracking:
- `?utm_source=tiktok&utm_campaign=launch`
- `?ad=tiktok1` (shorthand tracking)

## Database Schema

Create in Supabase:
```sql
CREATE TABLE waiting_list (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  utm_source TEXT,
  utm_medium TEXT,
  utm_campaign TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE waiting_list ENABLE ROW LEVEL SECURITY;

-- Allow inserts from anon users
CREATE POLICY "Allow anonymous inserts" ON waiting_list
  FOR INSERT WITH CHECK (true);
```