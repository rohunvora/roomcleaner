'use client'

import { useEffect, useState } from 'react'

interface DetectionBoxProps {
  x: number
  y: number
  width: number
  height: number
  label: string
  category: 'clothing' | 'electronics' | 'books' | 'personal' | 'misc'
  delay: number
  isAnimating: boolean
}

const categoryColors = {
  clothing: '#3B82F6', // Blue
  electronics: '#10B981', // Green
  books: '#8B5CF6', // Purple
  personal: '#F59E0B', // Amber
  misc: '#6B7280', // Gray
}

export default function DetectionBox({
  x,
  y,
  width,
  height,
  label,
  category,
  delay,
  isAnimating
}: DetectionBoxProps) {
  const [isVisible, setIsVisible] = useState(false)
  
  useEffect(() => {
    if (isAnimating) {
      const timer = setTimeout(() => {
        setIsVisible(true)
      }, delay)
      
      return () => {
        clearTimeout(timer)
        setIsVisible(false)
      }
    } else {
      setIsVisible(false)
    }
  }, [isAnimating, delay])
  
  const color = categoryColors[category]
  
  return (
    <div
      className="absolute"
      style={{
        left: `${x}%`,
        top: `${y}%`,
        width: `${width}%`,
        height: `${height}%`,
        opacity: isVisible ? 1 : 0,
        transform: isVisible ? 'scale(1)' : 'scale(0.9)',
        transition: 'all 0.3s ease-out',
      }}
    >
      {/* Box */}
      <div 
        className="absolute inset-0 rounded border-2"
        style={{
          borderColor: color,
          backgroundColor: `${color}20`,
        }}
      />
      
      {/* Label */}
      <div 
        className="absolute -bottom-6 left-1/2 -translate-x-1/2 px-2 py-1 rounded text-xs font-medium text-white whitespace-nowrap"
        style={{ 
          backgroundColor: color,
          fontSize: '11px',
        }}
      >
        {label}
      </div>
    </div>
  )
}