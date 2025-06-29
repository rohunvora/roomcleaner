import Image from 'next/image'
import DetectionBox from './DetectionBox'
import { hardcodedDetections } from '@/lib/hardcodedDetections'

export default function DetectionDemo() {
  return (
    <div className="relative max-w-4xl mx-auto">
      <div className="relative rounded-lg overflow-hidden border border-gray-200 group">
        <div className="relative aspect-video">
          <Image 
            src="/demo-room.webp" 
            alt="Messy room being analyzed"
            fill
            className="object-cover"
            priority
            sizes="(max-width: 768px) 100vw, (max-width: 1200px) 80vw, 1024px"
          />
          
          {/* Shimmer overlay during scan */}
          <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/10 to-transparent animate-[shimmer_3s_ease-out] pointer-events-none" />
          
          {/* Detection boxes with CSS animations */}
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
                isAnimating={true}
              />
            ))}
          </div>
          
          {/* Animated counter */}
          <div className="absolute top-4 right-4 bg-white/90 backdrop-blur-sm rounded-lg px-4 py-2 shadow-lg">
            <div className="flex items-center gap-2">
              <div className="w-2 h-2 rounded-full bg-green-500 animate-pulse" />
              <div className="font-bold text-lg tabular-nums relative h-6 overflow-hidden">
                <div className="animate-[slideNumbers_3s_ease-out_forwards]">
                  <div>0</div>
                  <div>5</div>
                  <div>10</div>
                  <div>15</div>
                  <div>20</div>
                  <div>25</div>
                  <div>30</div>
                </div>
              </div>
              <span className="text-sm text-gray-600">items spotted</span>
            </div>
          </div>
          
          {/* Scanning line effect */}
          <div className="absolute inset-x-0 h-0.5 bg-gradient-to-r from-transparent via-green-500 to-transparent animate-[scanLine_3s_ease-out]" />
        </div>
        
        {/* Hover hint */}
        <div className="absolute bottom-2 left-2 bg-black/70 text-white text-xs px-2 py-1 rounded opacity-0 group-hover:opacity-100 transition-opacity">
          AI detection in action
        </div>
      </div>
      
      {/* Info text with fade in */}
      <div className="mt-4 text-center opacity-0 animate-[fadeInDelayed_4s_ease-out_forwards]">
        <p className="text-sm text-gray-600">
          AI scans your room fast, identifying the items it sees
        </p>
      </div>
    </div>
  )
}