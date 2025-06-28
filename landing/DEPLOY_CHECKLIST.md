# Deploy Checklist - RoomCleaner Landing

## 1. Supabase Setup (5 min)

1. Create new project at supabase.com
2. Run this SQL in SQL Editor:
```sql
CREATE TABLE waiting_list (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  utm_source TEXT,
  utm_medium TEXT,
  utm_campaign TEXT,
  ad TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

ALTER TABLE waiting_list ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Allow anonymous inserts" ON waiting_list
  FOR INSERT WITH CHECK (true);
```

3. Get credentials from Settings > API:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_ANON_KEY`

## 2. Slack Webhook (2 min)

1. Go to api.slack.com/apps
2. Create app > Incoming Webhooks
3. Add to #signups channel
4. Copy webhook URL

## 3. Local Setup (3 min)

```bash
cd landing
cp .env.local.example .env.local
# Edit .env.local with your credentials
npm install
npm run dev  # Test locally at localhost:3000
```

## 4. Deploy to Vercel (5 min)

```bash
# Install Vercel CLI if needed
npm i -g vercel

# Deploy
vercel

# Follow prompts:
# - Link to new project
# - Name: roomcleaner-landing
# - Framework: Next.js
# - Build: default settings
```

## 5. Add Environment Variables in Vercel

1. Go to vercel.com/dashboard
2. Select roomcleaner-landing
3. Settings > Environment Variables
4. Add all from .env.local

## 6. Custom Domain

1. Settings > Domains
2. Add roomcleaner.ai
3. Add CNAME record in your DNS:
   - Type: CNAME
   - Name: @ (or www)
   - Value: cname.vercel-dns.com

## 7. Test Campaign URLs

- https://roomcleaner.ai?ad=tiktok1
- https://roomcleaner.ai?ad=ig1
- https://roomcleaner.ai?utm_source=tiktok&utm_campaign=launch

## Quick Commands

```bash
# Deploy updates
./deploy.sh

# Check signups (in Supabase)
SELECT email, utm_source, created_at 
FROM waiting_list 
ORDER BY created_at DESC;
```