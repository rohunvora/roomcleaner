import type { Config } from 'tailwindcss'

const config: Config = {
  content: [
    './pages/**/*.{js,ts,jsx,tsx,mdx}',
    './components/**/*.{js,ts,jsx,tsx,mdx}',
    './app/**/*.{js,ts,jsx,tsx,mdx}',
  ],
  theme: {
    extend: {
      colors: {
        background: 'rgb(var(--background) / <alpha-value>)',
        foreground: 'rgb(var(--foreground) / <alpha-value>)',
        card: 'rgb(var(--card) / <alpha-value>)',
        'card-foreground': 'rgb(var(--card-foreground) / <alpha-value>)',
        primary: 'rgb(var(--primary) / <alpha-value>)',
        'primary-foreground': 'rgb(var(--primary-foreground) / <alpha-value>)',
        secondary: 'rgb(var(--secondary) / <alpha-value>)',
        'secondary-foreground': 'rgb(var(--secondary-foreground) / <alpha-value>)',
        accent: 'rgb(var(--accent) / <alpha-value>)',
        'accent-foreground': 'rgb(var(--accent-foreground) / <alpha-value>)',
        muted: 'rgb(var(--muted) / <alpha-value>)',
        'muted-foreground': 'rgb(var(--muted-foreground) / <alpha-value>)',
        border: 'rgb(var(--border) / <alpha-value>)',
      },
      borderRadius: {
        lg: 'var(--radius)',
        md: 'calc(var(--radius) - 2px)',
        sm: 'calc(var(--radius) - 4px)',
      },
      fontFamily: {
        sans: ['Inter', 'system-ui', '-apple-system', 'sans-serif'],
      },
      backgroundImage: {
        'gradient-radial': 'radial-gradient(var(--tw-gradient-stops))',
        'gradient-conic':
          'conic-gradient(from 180deg at 50% 50%, var(--tw-gradient-stops))',
      },
      keyframes: {
        // Transformation demo animations
        stepFadeIn: {
          'from': {
            opacity: '0.3',
            transform: 'translateY(10px)',
          },
          'to': {
            opacity: '1',
            transform: 'translateY(0)',
          },
        },
        progressFill: {
          'from': { width: '0%' },
          'to': { width: '100%' },
        },
        zoneSlideIn: {
          'from': {
            opacity: '0',
            transform: 'scale(0.8) translateY(20px)',
          },
          'to': {
            opacity: '1',
            transform: 'scale(1) translateY(0)',
          },
        },
        fadeIn: {
          'from': { opacity: '0' },
          'to': { opacity: '1' },
        },
        
        // Detection demo animations
        slideNumbers: {
          '0%': { transform: 'translateY(0)' },
          '16%': { transform: 'translateY(-24px)' },
          '33%': { transform: 'translateY(-48px)' },
          '50%': { transform: 'translateY(-72px)' },
          '66%': { transform: 'translateY(-96px)' },
          '83%': { transform: 'translateY(-120px)' },
          '100%': { transform: 'translateY(-144px)' },
        },
        digitFlip: {
          '0%, 10%': { transform: 'translateY(0)' },
          '15%, 25%': { transform: 'translateY(-100%)' },
          '30%, 40%': { transform: 'translateY(-200%)' },
          '45%, 55%': { transform: 'translateY(-300%)' },
          '60%, 70%': { transform: 'translateY(-400%)' },
          '75%, 85%': { transform: 'translateY(-500%)' },
          '90%, 100%': { transform: 'translateY(0)' },
        },
        countUp: {
          'from': { content: '"0"' },
          '10%': { content: '"3"' },
          '20%': { content: '"6"' },
          '30%': { content: '"9"' },
          '40%': { content: '"12"' },
          '50%': { content: '"15"' },
          '60%': { content: '"18"' },
          '70%': { content: '"21"' },
          '80%': { content: '"24"' },
          '90%': { content: '"27"' },
          'to': { content: '"30"' },
        },
        shimmer: {
          'from': { transform: 'translateX(-200%)' },
          'to': { transform: 'translateX(200%)' },
        },
        scanLine: {
          '0%': {
            top: '0',
            opacity: '0',
          },
          '5%': { opacity: '1' },
          '95%': { opacity: '1' },
          '100%': {
            top: '100%',
            opacity: '0',
          },
        },
        fadeInDelayed: {
          '0%, 80%': {
            opacity: '0',
            transform: 'translateY(10px)',
          },
          '100%': {
            opacity: '1',
            transform: 'translateY(0)',
          },
        },
        boxAppear: {
          'from': {
            opacity: '0',
            transform: 'scale(0.9)',
          },
          'to': {
            opacity: '1',
            transform: 'scale(1)',
          },
        },
      },
      animation: {
        'stepFadeIn': 'stepFadeIn 0.8s ease-out forwards',
        'progressFill': 'progressFill 4s ease-out forwards',
        'zoneSlideIn': 'zoneSlideIn 0.6s ease-out forwards',
        'fadeIn': 'fadeIn 0.8s ease-out forwards',
        'slideNumbers': 'slideNumbers 3s ease-out forwards',
        'digitFlip': 'digitFlip 3s ease-out',
        'countUp': 'countUp 3s ease-out',
        'shimmer': 'shimmer 3s ease-out',
        'scanLine': 'scanLine 3s ease-out',
        'fadeInDelayed': 'fadeInDelayed 4s ease-out forwards',
        'boxAppear': 'boxAppear 0.3s ease-out forwards',
      },
    },
  },
  plugins: [],
}
export default config