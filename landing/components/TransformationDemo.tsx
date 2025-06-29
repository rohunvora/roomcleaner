'use client'

import { useState, useEffect } from 'react'
import Image from 'next/image'

export default function TransformationDemo() {
  const [showAfter, setShowAfter] = useState(false)
  const [currentStep, setCurrentStep] = useState(0)

  const transformationSteps = [
    { label: "Overwhelmed", emotion: "😰", description: "Where do I even start?" },
    { label: "Taking photos", emotion: "📸", description: "Just 5 quick shots" },
    { label: "AI organizing", emotion: "🤖", description: "Creating your personal map" },
    { label: "Peace of mind", emotion: "😌", description: "Everything has a home" }
  ]

  useEffect(() => {
    if (showAfter) {
      const timer = setInterval(() => {
        setCurrentStep(prev => (prev < 3 ? prev + 1 : prev))
      }, 1000)
      return () => clearInterval(timer)
    }
  }, [showAfter])

  return (
    <div className="relative max-w-4xl mx-auto">
      {/* Progress indicator */}
      {showAfter && (
        <div className="mb-8">
          <div className="flex justify-between items-center">
            {transformationSteps.map((step, index) => (
              <div
                key={index}
                className={`flex-1 text-center transition-all duration-500 ${
                  index <= currentStep ? 'opacity-100' : 'opacity-30'
                }`}
              >
                <div className="text-3xl mb-2">{step.emotion}</div>
                <div className="font-semibold text-sm">{step.label}</div>
                <div className="text-xs text-gray-500 mt-1">{step.description}</div>
              </div>
            ))}
          </div>
          <div className="mt-4 h-2 bg-gray-200 rounded-full overflow-hidden">
            <div
              className="h-full bg-green-500 transition-all duration-1000"
              style={{ width: `${((currentStep + 1) / 4) * 100}%` }}
            />
          </div>
        </div>
      )}

      {/* Main demo area */}
      <div className="relative rounded-xl overflow-hidden shadow-2xl">
        {/* Before state */}
        <div className={`transition-opacity duration-1000 ${showAfter ? 'opacity-0' : 'opacity-100'}`}>
          <Image
            src="/messy-room.jpg"
            alt="Messy room before organization"
            width={1200}
            height={800}
            className="w-full h-auto"
            priority
          />
          <div className="absolute inset-0 bg-gradient-to-t from-black/60 to-transparent" />
          <div className="absolute bottom-0 left-0 right-0 p-8 text-white">
            <h3 className="text-2xl font-bold mb-2">The daily struggle</h3>
            <p className="text-lg opacity-90">
              "I know my keys are here somewhere..." <br />
              <span className="text-sm">15 minutes later, still searching.</span>
            </p>
          </div>
        </div>

        {/* After state */}
        <div className={`absolute inset-0 transition-opacity duration-1000 ${showAfter ? 'opacity-100' : 'opacity-0'}`}>
          <Image
            src="/messy-room.jpg"
            alt="Room with organization zones"
            width={1200}
            height={800}
            className="w-full h-auto"
          />
          
          {/* Organization zones overlay */}
          <div className="absolute inset-0">
            {/* Zone labels */}
            <div className={`absolute top-[20%] left-[15%] transition-all duration-500 ${currentStep >= 2 ? 'opacity-100 scale-100' : 'opacity-0 scale-90'}`}>
              <div className="bg-blue-500 text-white px-4 py-2 rounded-lg shadow-lg">
                <div className="font-bold">Clothing Zone</div>
                <div className="text-sm">T-shirts, jeans, socks</div>
              </div>
            </div>

            <div className={`absolute top-[35%] right-[20%] transition-all duration-500 delay-200 ${currentStep >= 2 ? 'opacity-100 scale-100' : 'opacity-0 scale-90'}`}>
              <div className="bg-green-500 text-white px-4 py-2 rounded-lg shadow-lg">
                <div className="font-bold">Electronics</div>
                <div className="text-sm">Chargers, earbuds, cables</div>
              </div>
            </div>

            <div className={`absolute bottom-[30%] left-[40%] transition-all duration-500 delay-400 ${currentStep >= 2 ? 'opacity-100 scale-100' : 'opacity-0 scale-90'}`}>
              <div className="bg-amber-500 text-white px-4 py-2 rounded-lg shadow-lg">
                <div className="font-bold">Daily Essentials</div>
                <div className="text-sm">Keys, wallet, watch</div>
              </div>
            </div>

            <div className={`absolute bottom-[15%] right-[15%] transition-all duration-500 delay-600 ${currentStep >= 2 ? 'opacity-100 scale-100' : 'opacity-0 scale-90'}`}>
              <div className="bg-purple-500 text-white px-4 py-2 rounded-lg shadow-lg">
                <div className="font-bold">Books & Papers</div>
                <div className="text-sm">Notebooks, documents</div>
              </div>
            </div>
          </div>

          {/* Success message */}
          <div className={`absolute bottom-0 left-0 right-0 p-8 bg-gradient-to-t from-black/80 to-transparent transition-all duration-500 ${currentStep === 3 ? 'opacity-100' : 'opacity-0'}`}>
            <div className="text-white">
              <h3 className="text-2xl font-bold mb-2">✨ Transformation complete</h3>
              <p className="text-lg opacity-90">
                Everything has a designated home. Find anything in seconds.
              </p>
            </div>
          </div>
        </div>
      </div>

      {/* Action button */}
      <div className="text-center mt-8">
        {!showAfter ? (
          <button
            onClick={() => setShowAfter(true)}
            className="px-8 py-4 bg-green-600 text-white font-medium rounded-lg hover:bg-green-700 transition-all transform hover:scale-105"
          >
            Watch the transformation →
          </button>
        ) : (
          <button
            onClick={() => {
              setShowAfter(false)
              setCurrentStep(0)
            }}
            className="px-8 py-4 bg-gray-600 text-white font-medium rounded-lg hover:bg-gray-700 transition-all"
          >
            See it again
          </button>
        )}
      </div>
    </div>
  )
}