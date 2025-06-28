import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ subsets: ['latin'] })

export const metadata: Metadata = {
  title: 'RoomCleaner AI - Your messy room, fixed in 60 seconds',
  description: 'Snap 5 photos → AI spits out a storage map. Turn overwhelming messes into manageable tasks.',
  openGraph: {
    title: 'RoomCleaner AI - Your messy room, fixed in 60 seconds',
    description: 'Snap 5 photos → AI spits out a storage map.',
    images: '/og-image.png',
    type: 'website',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'RoomCleaner AI',
    description: 'Your messy room, fixed in 60 seconds.',
    images: '/og-image.png',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body className={inter.className}>{children}</body>
    </html>
  )
}