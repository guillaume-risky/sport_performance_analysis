export default function HealthPage() {
  return (
    <main className="container" style={{ paddingTop: '2rem', paddingBottom: '2rem' }}>
      <div className="glass" style={{ padding: '2rem', textAlign: 'center' }}>
        <h1 style={{ color: 'white', fontSize: '2rem', marginBottom: '1rem', fontWeight: 'bold' }}>
          Health Check
        </h1>
        <div style={{ color: 'rgba(255, 255, 255, 0.9)', fontSize: '1.125rem' }}>
          <p style={{ marginBottom: '0.5rem' }}>Status: <strong style={{ color: '#4ade80' }}>OK</strong></p>
          <p style={{ marginTop: '1rem', fontSize: '0.875rem', opacity: 0.8 }}>
            Web application is running successfully
          </p>
        </div>
      </div>
    </main>
  )
}
