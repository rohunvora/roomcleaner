import TransformationDemo from '@/components/TransformationDemo'
import { copy } from '@/lib/copy'

export default function Home({ searchParams }: { searchParams: { success?: string, error?: string } }) {
  const showSuccess = searchParams?.success === 'true'
  const showError = searchParams?.error
  
  return (
    <div className="min-h-screen bg-white">
      {/* Navigation */}
      <nav className="px-4 sm:px-6 py-4 sm:py-6 max-w-7xl mx-auto flex justify-between items-center animate-on-load">
        <div className="font-bold text-lg sm:text-xl">Room Cleaner</div>
        <div className="flex gap-4 sm:gap-6 text-sm">
          <a href="#how-it-works" className="text-gray-600 hover:text-gray-900 transition-colors">How it works</a>
          <a href="#pricing" className="text-gray-600 hover:text-gray-900 transition-colors">Pricing</a>
        </div>
      </nav>

      {/* Hero Section - Mobile optimized */}
      <section id="signup" className="px-4 sm:px-6 py-12 sm:py-20 max-w-6xl mx-auto">
        <div className="text-center mb-12 sm:mb-16 stagger-children">
          <h1 className="text-3xl sm:text-4xl lg:text-5xl font-bold mb-4 sm:mb-6 leading-tight max-w-4xl mx-auto">
            {copy.hero.title}
          </h1>
          
          <h2 className="text-lg sm:text-xl text-gray-600 mb-8 sm:mb-10 font-normal px-4 sm:px-0 max-w-2xl mx-auto">
            {copy.hero.subtitle}
          </h2>

          {/* Email signup - stacked on mobile */}
          <div className="max-w-md mx-auto px-4 sm:px-0">
            {showSuccess ? (
              <div className="text-green-600 font-medium fade-in p-4 relative">
                <div className="confetti-container" />
                {copy.hero.successMessage}
              </div>
            ) : showError ? (
              <div className="text-red-600 font-medium fade-in p-4">
                {copy.errors.signup}
              </div>
            ) : (
              <>
                <form action="/api/signup" method="POST" className="flex flex-col sm:flex-row gap-3">
                  <input
                    type="email"
                    name="email"
                    placeholder={copy.placeholders.email}
                    className="flex-1 px-5 py-4 sm:py-3 border border-gray-200 rounded-full focus:outline-none focus:border-gray-400 transition-all hover:border-gray-300 text-base"
                    required
                  />
                  <button type="submit" className="btn-primary py-4 sm:py-3 text-base hover-lift">
                    {copy.hero.cta} →
                  </button>
                </form>
                <p className="text-sm text-gray-500 mt-4">{copy.hero.ctaSubtext}</p>
              </>
            )}
          </div>
        </div>

        {/* Hero visual - hidden on very small screens */}
        <div className="relative animate-on-load hidden sm:block" style={{ animationDelay: '0.5s' }}>
          <TransformationDemo />
        </div>
        
        {/* Mobile-only compact demo */}
        <div className="sm:hidden bg-gray-50 rounded-xl p-6 text-center animate-on-load">
          <div className="text-4xl mb-3 wiggle">🏠 → ✨</div>
          <p className="text-sm text-gray-600">See how AI organizes your space</p>
        </div>
      </section>

      {/* How it works - Mobile optimized */}
      <section id="how-it-works" className="py-12 sm:py-20 bg-gray-50">
        <div className="max-w-6xl mx-auto px-4 sm:px-6">
          <div className="text-center mb-12 sm:mb-16 animate-on-load">
            <h2 className="text-3xl sm:text-4xl font-bold mb-3 sm:mb-4">
              {copy.howItWorks.title}
            </h2>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-3 gap-6 sm:gap-8 stagger-children">
            {copy.howItWorks.steps.map((step, i) => (
              <div key={i} className="bg-white rounded-2xl p-6 sm:p-8 shadow-sm card-hover hover-tilt">
                <div className="text-3xl sm:text-4xl mb-3 sm:mb-4 bounce-on-hover">{step.emoji}</div>
                <h3 className="text-lg sm:text-xl font-semibold mb-2">{step.title}</h3>
                <p className="text-gray-600 text-sm sm:text-base">{step.description}</p>
              </div>
            ))}
          </div>
          
          <p className="text-center text-gray-500 mt-8 animate-on-load">
            {copy.howItWorks.clarifier}
          </p>
        </div>
      </section>

      {/* Why Mess Happens - New Section */}
      <section className="py-12 sm:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6">
          <h2 className="text-3xl sm:text-4xl font-bold text-center mb-12 sm:mb-16 animate-on-load">
            {copy.whyMessHappens.title}
          </h2>

          <div className="space-y-6 stagger-children">
            {copy.whyMessHappens.reasons.map((reason, i) => (
              <div key={i} className="flex items-center gap-4 group cursor-pointer">
                <div className="flex-1 flex items-center justify-between p-4 rounded-xl hover:bg-gray-50 transition-all">
                  <span className="font-medium text-gray-700">{reason.problem}</span>
                  <span className="text-gray-500 opacity-0 group-hover:opacity-100 transition-all transform translate-x-2 group-hover:translate-x-0">
                    → {reason.result}
                  </span>
                </div>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* What You Get - Mobile optimized */}
      <section className="py-12 sm:py-20 bg-gray-50">
        <div className="max-w-4xl mx-auto px-4 sm:px-6">
          <h2 className="text-3xl sm:text-4xl font-bold text-center mb-12 sm:mb-16 animate-on-load">
            {copy.whatYouGet.title}
          </h2>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4 stagger-children">
            {copy.whatYouGet.features.map((feature, i) => (
              <div key={i} className="bg-white p-6 rounded-xl flex items-start gap-3 hover-lift">
                <span className="text-green-500 text-xl flex-shrink-0">✓</span>
                <span className="text-gray-700">{feature}</span>
              </div>
            ))}
          </div>
        </div>
      </section>

      {/* Testimonials */}
      <section className="py-12 sm:py-20">
        <div className="max-w-4xl mx-auto px-4 sm:px-6">
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-8 stagger-children">
            {copy.testimonials.map((testimonial, i) => (
              <blockquote key={i} className="bg-gray-50 p-6 sm:p-8 rounded-2xl hover-tilt">
                <p className="text-gray-700 mb-4 italic">"{testimonial.quote}"</p>
                <cite className="text-sm text-gray-500 not-italic">— {testimonial.author}</cite>
              </blockquote>
            ))}
          </div>
        </div>
      </section>

      {/* Pricing - Mobile optimized */}
      <section id="pricing" className="py-12 sm:py-20 bg-gray-50">
        <div className="max-w-lg mx-auto px-4 sm:px-6 text-center animate-on-load">
          <h2 className="text-2xl sm:text-3xl font-bold mb-6 max-w-xl mx-auto">
            {copy.pricing.title}
          </h2>
          <div className="bg-white rounded-2xl p-6 sm:p-8 mt-6 sm:mt-8 shadow-sm hover-lift">
            <div className="text-5xl sm:text-6xl font-bold mb-2 text-gradient">
              {copy.pricing.price}<span className="text-xl sm:text-2xl font-normal text-gray-500">{copy.pricing.period}</span>
            </div>
            <ul className="text-left space-y-2 sm:space-y-3 mb-6 sm:mb-8 text-sm sm:text-base mt-8">
              {copy.pricing.features.map((feature, i) => (
                <li key={i} className="flex items-center gap-2">
                  <span className="text-green-500">✓</span> {feature}
                </li>
              ))}
            </ul>
            <button className="btn-primary block py-4 text-base w-full hover-lift">
              {copy.pricing.cta}
            </button>
          </div>
        </div>
      </section>

      {/* Final CTA - Mobile optimized */}
      <section className="py-12 sm:py-20 bg-gray-900 text-white">
        <div className="max-w-4xl mx-auto px-4 sm:px-6 text-center animate-on-load">
          <h2 className="text-3xl sm:text-4xl font-bold mb-6 sm:mb-8">
            {copy.finalCta.title}
          </h2>
          <a href="#signup" className="btn-secondary inline-block py-4 px-8 text-base hover-lift">
            {copy.finalCta.button}
          </a>
        </div>
      </section>

      {/* Footer - Mobile optimized */}
      <footer className="py-8 sm:py-12 px-4 sm:px-6 text-center text-xs sm:text-sm text-gray-500">
        <div className="max-w-6xl mx-auto">
          <div className="mb-6 sm:mb-8">
            © 2025 Room Cleaner • {copy.footer.tagline}
          </div>
          <div className="flex justify-center gap-6 sm:gap-8">
            <a href="#" className="hover:text-gray-700 transition-colors">
              {copy.footer.links.privacy}
            </a>
            <a href="#" className="hover:text-gray-700 transition-colors">
              {copy.footer.links.terms}
            </a>
            <a href={`mailto:${copy.footer.links.email}`} className="hover:text-gray-700 transition-colors">
              Contact
            </a>
          </div>
          {/* Easter egg */}
          <div className="mt-8 text-xs text-gray-300 opacity-0 hover:opacity-100 transition-opacity cursor-pointer">
            🧹 Fun fact: This was built during a messy room crisis
          </div>
        </div>
      </footer>
    </div>
  )
}