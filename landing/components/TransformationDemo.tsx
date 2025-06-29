import Image from 'next/image'

export default function TransformationDemo() {
  return (
    <div className="relative max-w-4xl mx-auto">
      {/* Progress indicator with CSS animation */}
      <div className="mb-8 animate-in">
        <div className="flex justify-between items-center">
          {[
            { label: "Overwhelmed", emotion: "😰", description: "Where do I even start?", delay: '0s' },
            { label: "Taking photos", emotion: "📸", description: "Just 5 quick shots", delay: '1s' },
            { label: "AI organizing", emotion: "🤖", description: "Drafting your personal map", delay: '2s' },
            { label: "Relief", emotion: "😌", description: "Finally a clear first step", delay: '3s' }
          ].map((step, index) => (
            <div
              key={index}
              className="flex-1 text-center opacity-30 animate-[stepFadeIn_0.8s_ease-out_forwards]"
              style={{ animationDelay: step.delay }}
            >
              <div className="text-3xl mb-2">{step.emotion}</div>
              <div className="font-semibold text-sm">{step.label}</div>
              <div className="text-xs text-gray-500 mt-1">{step.description}</div>
            </div>
          ))}
        </div>
        <div className="mt-4 h-2 bg-gray-200 rounded-full overflow-hidden">
          <div className="h-full bg-green-500 animate-[progressFill_4s_ease-out_forwards]" />
        </div>
      </div>

      {/* Main demo area - Static transformation display */}
      <div className="grid md:grid-cols-2 gap-8">
        {/* Before state */}
        <div className="relative rounded-xl overflow-hidden shadow-lg">
          <div className="aspect-[4/3] bg-gradient-to-br from-gray-100 to-gray-200 flex items-center justify-center">
            <div className="text-center p-8">
              <div className="text-6xl mb-4">🏠</div>
              <h3 className="text-xl font-bold mb-2">Before</h3>
              <p className="text-gray-600">
                Cluttered surfaces, daily frustration
              </p>
            </div>
          </div>
        </div>

        {/* After state with animated zones */}
        <div className="relative rounded-xl overflow-hidden shadow-lg">
          <div className="aspect-[4/3] bg-gradient-to-br from-blue-50 to-green-50 relative">
            {/* Animated organization zones */}
            <div className="absolute top-[20%] left-[15%] opacity-0 animate-[zoneSlideIn_0.6s_ease-out_0.5s_forwards]">
              <div className="bg-blue-500 text-white px-3 py-2 rounded-lg shadow-lg text-sm">
                <div className="font-bold">Clothing Zone</div>
              </div>
            </div>

            <div className="absolute top-[25%] right-[20%] opacity-0 animate-[zoneSlideIn_0.6s_ease-out_0.8s_forwards]">
              <div className="bg-green-500 text-white px-3 py-2 rounded-lg shadow-lg text-sm">
                <div className="font-bold">Electronics</div>
              </div>
            </div>

            <div className="absolute bottom-[30%] left-[20%] opacity-0 animate-[zoneSlideIn_0.6s_ease-out_1.1s_forwards]">
              <div className="bg-amber-500 text-white px-3 py-2 rounded-lg shadow-lg text-sm">
                <div className="font-bold">Daily Items</div>
              </div>
            </div>

            <div className="absolute bottom-[25%] right-[15%] opacity-0 animate-[zoneSlideIn_0.6s_ease-out_1.4s_forwards]">
              <div className="bg-purple-500 text-white px-3 py-2 rounded-lg shadow-lg text-sm">
                <div className="font-bold">Books</div>
              </div>
            </div>

            {/* Center content */}
            <div className="absolute inset-0 flex items-center justify-center">
              <div className="text-center p-8 bg-white/80 backdrop-blur rounded-xl">
                <div className="text-6xl mb-4">✨</div>
                <h3 className="text-xl font-bold mb-2">After</h3>
                <p className="text-gray-600">
                  Tidy space, five-minute upkeep
                </p>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Feature callout */}
      <div className="text-center mt-8 opacity-0 animate-[fadeIn_0.8s_ease-out_4s_forwards]">
        <p className="text-lg text-gray-600">
          AI spots dozens of items and suggests where they belong.
        </p>
      </div>
    </div>
  )
}