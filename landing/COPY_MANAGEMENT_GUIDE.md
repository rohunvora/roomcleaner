# Copy Management Solutions for Your Landing Page

## Current Solution: Centralized Copy File

I've created `lib/copy.ts` which contains all your website copy in one place. Here's how to use it:

```typescript
import { copy } from '@/lib/copy'

// In your component:
<h1>{copy.hero.title}</h1>
<button>{copy.hero.cta}</button>
```

## Alternative Solutions

### 1. **Environment Variables for Key Copy**
Good for: A/B testing, quick changes without code deploys

```env
# .env.local
NEXT_PUBLIC_HERO_TITLE="Your messy room, fixed in 60 seconds."
NEXT_PUBLIC_CTA_TEXT="Sign up for beta"
```

```tsx
// In component
<h1>{process.env.NEXT_PUBLIC_HERO_TITLE}</h1>
```

### 2. **Markdown Files with MDX**
Good for: Long-form content, blog posts, landing pages

```bash
npm install @next/mdx @mdx-js/loader
```

Then create content in `.mdx` files with React components.

### 3. **Headless CMS Integration**
Good for: Non-technical editors, frequent updates

Popular options:
- **Contentful** - Great for structured content
- **Sanity** - Developer-friendly, real-time collaboration
- **Strapi** - Open source, self-hosted option

Example with Sanity:
```typescript
// lib/sanity.ts
import { createClient } from '@sanity/client'

export const client = createClient({
  projectId: 'your-project-id',
  dataset: 'production',
  useCdn: true,
})

// In your page
const copy = await client.fetch(`*[_type == "landingPage"][0]`)
```

### 4. **Google Sheets as CMS**
Good for: Quick edits by non-developers, free

```typescript
// Use Google Sheets API or a service like Sheety
const response = await fetch('https://api.sheety.co/your-sheet-url')
const copy = await response.json()
```

### 5. **i18n Library (Even for Single Language)**
Good for: Future internationalization, organized copy

```bash
npm install next-i18next
```

```json
// public/locales/en/common.json
{
  "hero": {
    "title": "Your messy room, fixed in 60 seconds."
  }
}
```

### 6. **Custom Admin Panel**
Build a simple admin interface:

```typescript
// pages/admin/copy.tsx
export default function CopyAdmin() {
  const [copy, setCopy] = useState(currentCopy)
  
  const handleSave = async () => {
    await fetch('/api/copy', {
      method: 'POST',
      body: JSON.stringify(copy)
    })
  }
  
  return (
    <div>
      <textarea 
        value={copy.hero.title}
        onChange={(e) => setCopy({...copy, hero: {...copy.hero, title: e.target.value}})}
      />
      <button onClick={handleSave}>Save</button>
    </div>
  )
}
```

## Quick Tips for Better Copy Management

1. **Use consistent naming conventions:**
   ```typescript
   // Good
   copy.hero.title
   copy.hero.subtitle
   copy.cta.primary
   
   // Bad
   copy.heroTitle
   copy.hero_subtitle
   copy.CTAButton
   ```

2. **Group related copy:**
   ```typescript
   copy.errors = {
     network: "Network error. Please try again.",
     validation: "Please check your input.",
     generic: "Something went wrong."
   }
   ```

3. **Include microcopy:**
   ```typescript
   copy.tooltips = {
     emailPrivacy: "We'll never spam you",
     betaAccess: "First 100 users get lifetime discount"
   }
   ```

4. **Version your copy:**
   ```typescript
   // copy-v2.ts for A/B testing
   export const copyV2 = {
     hero: {
       title: "Organize any room in under a minute"
     }
   }
   ```

## Recommended Approach for Your Project

Given your stack and needs, I recommend sticking with the centralized `copy.ts` file because:

1. **It's already set up** - No new dependencies
2. **Type-safe** - TypeScript will catch typos
3. **Fast** - No API calls or build steps
4. **Simple** - Anyone can edit one file
5. **Searchable** - Easy to find all copy in one place

To make it even easier to edit, you could:
- Add a VS Code snippet for common copy patterns
- Create a simple script to extract all copy to a spreadsheet
- Build a quick admin UI that edits the copy file

Would you like me to implement any of these enhancements? 