#!/bin/bash

# Deploy script for Room Cleaner landing page
echo "🚀 Deploying Room Cleaner landing page to Vercel..."

# Change to landing directory
cd landing

# Build locally first to catch errors
echo "📦 Building locally..."
npm run build

if [ $? -eq 0 ]; then
    echo "✅ Build successful, deploying to Vercel..."
    vercel --prod
    echo "🎉 Deployment complete!"
else
    echo "❌ Build failed, please fix errors before deploying"
    exit 1
fi