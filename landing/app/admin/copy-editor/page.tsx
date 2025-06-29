'use client'

import { useState } from 'react'
import { copy as originalCopy } from '@/lib/copy'

export default function CopyEditor() {
  const [editedCopy, setEditedCopy] = useState(JSON.stringify(originalCopy, null, 2))
  const [copyToClipboard, setCopyToClipboard] = useState(false)

  const handleCopy = () => {
    const formattedCopy = `export const copy = ${editedCopy} as const

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
      console.warn(\`Copy not found for path: \${path}\`)
      return \`[Missing: \${path}]\`
    }
  }
  
  return value
}`

    navigator.clipboard.writeText(formattedCopy)
    setCopyToClipboard(true)
    setTimeout(() => setCopyToClipboard(false), 2000)
  }

  return (
    <div className="min-h-screen bg-gray-50 p-8">
      <div className="max-w-6xl mx-auto">
        <h1 className="text-3xl font-bold mb-8">Copy Editor</h1>
        
        <div className="bg-white rounded-lg shadow-sm p-6">
          <div className="mb-4 flex justify-between items-center">
            <p className="text-gray-600">
              Edit the JSON below, then copy the formatted TypeScript code to paste into <code className="bg-gray-100 px-2 py-1 rounded">lib/copy.ts</code>
            </p>
            <button
              onClick={handleCopy}
              className="bg-blue-600 text-white px-4 py-2 rounded-lg hover:bg-blue-700 transition-colors"
            >
              {copyToClipboard ? '✓ Copied!' : 'Copy TypeScript Code'}
            </button>
          </div>
          
          <textarea
            value={editedCopy}
            onChange={(e) => setEditedCopy(e.target.value)}
            className="w-full h-[600px] font-mono text-sm p-4 border border-gray-200 rounded-lg focus:outline-none focus:border-blue-500"
            spellCheck={false}
          />
          
          <div className="mt-4 text-sm text-gray-500">
            <p>💡 Tips:</p>
            <ul className="list-disc list-inside mt-2 space-y-1">
              <li>Use Cmd/Ctrl + F to find specific copy</li>
              <li>Keep the JSON structure intact</li>
              <li>Save your changes by copying the TypeScript code above</li>
              <li>This editor is available at <code className="bg-gray-100 px-2 py-1 rounded">/admin/copy-editor</code> in development</li>
            </ul>
          </div>
        </div>
      </div>
    </div>
  )
} 