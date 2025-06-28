#!/bin/bash

echo "🚀 Deploying RoomCleaner Landing Page"

# Check if env file exists
if [ ! -f .env.local ]; then
    echo "❌ Error: .env.local not found"
    echo "Copy .env.local.example and add your credentials"
    exit 1
fi

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Build
echo "🔨 Building..."
npm run build

# Deploy to Vercel
echo "🌐 Deploying to Vercel..."
vercel --prod

echo "✅ Deployment complete!"
echo ""
echo "📊 Campaign URLs:"
echo "- TikTok: https://roomcleaner.ai?ad=tiktok1"
echo "- Instagram: https://roomcleaner.ai?ad=ig1"
echo "- Direct: https://roomcleaner.ai"