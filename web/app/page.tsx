import Link from 'next/link'

export default function Home() {
  return (
    <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
      <div className="glass" style={{ padding: '2rem', textAlign: 'center' }}>
        <h1 style={{ color: 'white', fontSize: '2rem', marginBottom: '1rem', fontWeight: 'bold' }}>
          Sport Performance Analysis
        </h1>
        <p style={{ color: 'rgba(255, 255, 255, 0.9)', marginBottom: '2rem' }}>
          Welcome to the application
        </p>
        <Link 
          href="/health" 
          style={{ 
            display: 'inline-block',
            padding: '0.75rem 1.5rem',
            backgroundColor: 'rgba(255, 255, 255, 0.2)',
            color: 'white',
            textDecoration: 'none',
            borderRadius: '8px',
            border: '1px solid rgba(255, 255, 255, 0.3)',
            transition: 'all 0.3s ease'
          }}
        >
          Check Health
        </Link>
      </div>
    </main>
  )
}
