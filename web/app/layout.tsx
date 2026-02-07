import type { Metadata } from 'next'
import './globals.css'

export const metadata: Metadata = {
  title: 'Sport Performance Analysis',
  description: 'Sport Performance Analysis Application',
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
