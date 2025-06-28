# Super Simple Deploy Guide - No Tech Skills Needed! 🚀

I'll walk you through every single click. This takes about 30 minutes total.

## What You Need:
- A computer with internet
- A credit card (for Vercel, but it's free)
- That's it!

---

## Step 1: Create a Vercel Account (5 minutes)

1. Go to **vercel.com**
2. Click **"Sign Up"** (top right)
3. Click **"Continue with GitHub"**
4. If you don't have GitHub:
   - Click "Create an account"
   - Use your email
   - Pick any username (like "yourname123")
   - Click through the setup
5. Authorize Vercel to use GitHub

✅ **Done when:** You see the Vercel dashboard

---

## Step 2: Import This Project (5 minutes)

1. In Vercel dashboard, click **"Add New..."** → **"Project"**
2. Click **"Import Git Repository"**
3. Paste this URL: `https://github.com/rohunvora/roomcleaner`
4. Click **"Import"**
5. In "Configure Project":
   - Root Directory: Click **"Edit"** and type: `landing`
   - Framework Preset: Should say "Next.js" (leave it)
   - Click **"Deploy"**
6. Wait 2-3 minutes for build

✅ **Done when:** You see "Congratulations! Your project has been successfully deployed"

---

## Step 3: Get Your Live URL (1 minute)

1. On the success page, you'll see a URL like: `roomcleaner-landing-abc123.vercel.app`
2. Click **"Continue to Dashboard"**
3. Copy that URL - this is your live landing page!

🎉 **Your landing page is now LIVE!** But we need to add email collection...

---

## Step 4: Create Supabase Account (5 minutes)

1. Go to **supabase.com**
2. Click **"Start your project"**
3. Sign up with your email
4. Click **"New project"**
5. Fill in:
   - Name: `roomcleaner`
   - Database Password: Make up a strong password (save it somewhere!)
   - Region: Pick the closest to you
   - Click **"Create new project"**
6. Wait 2 minutes for setup

✅ **Done when:** You see your project dashboard

---

## Step 5: Set Up Email Collection (5 minutes)

1. In Supabase, click **"SQL Editor"** (left sidebar)
2. Delete any text in the editor
3. Copy and paste EXACTLY this:

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

4. Click **"Run"** (bottom right)
5. You should see "Success. No rows returned"

✅ **Done when:** You see the success message

---

## Step 6: Get Your Supabase Keys (2 minutes)

1. In Supabase, click **"Settings"** (gear icon, left sidebar)
2. Click **"API"**
3. You'll see two things we need:
   - **Project URL**: Looks like `https://abcdefgh.supabase.co`
   - **anon public**: A long string starting with `eyJ...`
4. Keep this tab open, we'll copy these in a moment

---

## Step 7: Connect Supabase to Vercel (5 minutes)

1. Go back to your Vercel dashboard
2. Click on your `roomcleaner-landing` project
3. Click **"Settings"** (top menu)
4. Click **"Environment Variables"** (left sidebar)
5. Add these variables ONE BY ONE:

**First Variable:**
- Key: `NEXT_PUBLIC_SUPABASE_URL`
- Value: (paste your Project URL from Supabase)
- Click **"Save"**

**Second Variable:**
- Key: `NEXT_PUBLIC_SUPABASE_ANON_KEY`
- Value: (paste your anon public key from Supabase)
- Click **"Save"**

6. Now click **"Deployments"** (top menu)
7. Click the **"..."** menu on your latest deployment
8. Click **"Redeploy"**
9. Click **"Redeploy"** again in the popup
10. Wait 2 minutes

✅ **Done when:** Deployment shows "Ready"

---

## Step 8: Test Your Email Collection (2 minutes)

1. Go to your site (the vercel.app URL)
2. Enter a test email and click "Join TestFlight Beta"
3. You should see "You're on the list!"
4. Go back to Supabase
5. Click **"Table Editor"** (left sidebar)
6. Click **"waiting_list"**
7. You should see your test email!

✅ **Done when:** You see emails appearing in Supabase

---

## Step 9: Set Up Your Custom Domain (Optional - 10 minutes)

If you bought roomcleaner.ai or another domain:

1. In Vercel project, click **"Settings"** → **"Domains"**
2. Type your domain and click **"Add"**
3. Follow the instructions they show (varies by where you bought domain)

---

## 🎊 YOU'RE DONE!

### Your Campaign URLs:
- Direct: `your-project.vercel.app`
- TikTok: `your-project.vercel.app?ad=tiktok1`
- Instagram: `your-project.vercel.app?ad=ig1`

### To See Signups:
1. Log into Supabase
2. Click "Table Editor" → "waiting_list"
3. Watch the emails roll in!

### Need Help?
- Vercel Support: support@vercel.com
- Supabase Discord: discord.supabase.com

---

## Bonus: Skip Supabase (Even Simpler!)

If Supabase seems too complex, you can use a Google Form instead:

1. Replace the email form with a Google Form embed
2. Much simpler but less professional looking

Let me know if you want the Google Form version!