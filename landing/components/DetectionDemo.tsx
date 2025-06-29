'use client'

import { useState, useEffect, useRef } from 'react'
import Image from 'next/image'
import DetectionBox from './DetectionBox'
import { useInView } from '@/hooks/useInView'
import { hardcodedDetections } from '@/lib/hardcodedDetections'

export default function DetectionDemo() {
  const [isAnimating, setIsAnimating] = useState(false)
  const [detectedCount, setDetectedCount] = useState(0)
  const [showBoxes, setShowBoxes] = useState(false)
  const [hasStarted, setHasStarted] = useState(false)
  const containerRef = useRef<HTMLDivElement>(null)
  const counterIntervalRef = useRef<NodeJS.Timeout | null>(null)
  const isInView = useInView(containerRef, { threshold: 0.3 })
  
  // Auto-start when in view
  useEffect(() => {
    if (isInView && !hasStarted) {
      startAnimation()
    }
  }, [isInView, hasStarted])
  
  const startAnimation = () => {
    setIsAnimating(true)
    setHasStarted(true)
    setDetectedCount(0)
    setShowBoxes(true)
    
    // Animate counter
    const totalDuration = 3000 // 3 seconds
    const totalItems = hardcodedDetections.length
    const increment = totalItems / (totalDuration / 50)
    
    let currentCount = 0
    counterIntervalRef.current = setInterval(() => {
      currentCount += increment
      if (currentCount >= totalItems) {
        setDetectedCount(totalItems)
        if (counterIntervalRef.current) {
          clearInterval(counterIntervalRef.current)
        }
        setTimeout(() => setIsAnimating(false), 500)
      } else {
        setDetectedCount(Math.floor(currentCount))
      }
    }, 50)
  }
  
  const handleReplay = () => {
    if (counterIntervalRef.current) {
      clearInterval(counterIntervalRef.current)
    }
    setShowBoxes(false)
    setDetectedCount(0)
    setHasStarted(false)
    setTimeout(() => startAnimation(), 300)
  }
  
  // Cleanup
  useEffect(() => {
    return () => {
      if (counterIntervalRef.current) {
        clearInterval(counterIntervalRef.current)
      }
    }
  }, [])
  
  return (
    <div ref={containerRef} className="relative max-w-4xl mx-auto">
      <div className="relative rounded-lg overflow-hidden border border-gray-200">
        <div className="relative aspect-video">
          <Image 
            src="/demo-room.webp" 
            alt="Messy room being analyzed"
            fill
            className="object-cover"
            priority
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 1024px"
          />
          
          {/* Detection boxes */}
          {showBoxes && (
            <div className="absolute inset-0">
              {hardcodedDetections.map((item) => (
                <DetectionBox
                  key={item.id}
                  x={item.x}
                  y={item.y}
                  width={item.width}
                  height={item.height}
                  label={item.label}
                  category={item.category}
                  delay={item.delay || 0}
                  isAnimating={isAnimating}
                />
              ))}
            </div>
          )}
          
          {/* Counter */}
          <div className="absolute top-4 right-4 bg-white/90 backdrop-blur-sm rounded-lg px-4 py-2 shadow-lg">
            <div className="flex items-center gap-2">
              <div className={`w-2 h-2 rounded-full ${isAnimating ? 'bg-green-500 animate-pulse' : 'bg-gray-400'}`} />
              <span className="font-bold text-lg">{detectedCount}</span>
              <span className="text-sm text-gray-600">items found</span>
            </div>
          </div>
        </div>
      </div>
      
      {/* Controls */}
      <div className="mt-4 text-center">
        <button
          onClick={handleReplay}
          className="text-sm text-blue-600 hover:text-blue-700 font-medium"
        >
          Replay detection →
        </button>
      </div>
    </div>
  )
}