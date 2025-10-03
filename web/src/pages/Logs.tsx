import { useState, useEffect } from 'react'
import axios from 'axios'

interface PolicyLog {
  id: number
  title: string
  description: string
  created_at: string
  status: string
}

function Logs() {
  const [logs, setLogs] = useState<PolicyLog[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const response = await axios.get('/api/policy-logs/')
        setLogs(response.data)
      } catch (err) {
        setError('Failed to fetch logs')
        console.error('Error fetching logs:', err)
      } finally {
        setLoading(false)
      }
    }

    fetchLogs()
  }, [])

  if (loading) {
    return <div className="loading">Loading logs...</div>
  }

  if (error) {
    return <div className="error">{error}</div>
  }

  return (
    <div className="logs">
      <div className="container">
        <h1>Policy Logs</h1>
        {logs.length === 0 ? (
          <p>No logs found.</p>
        ) : (
          <div className="logs-grid">
            {logs.map((log) => (
              <div key={log.id} className="log-card">
                <h3>{log.title}</h3>
                <p>{log.description}</p>
                <div className="log-meta">
                  <span className={`status status-${log.status}`}>{log.status}</span>
                  <span className="date">{new Date(log.created_at).toLocaleDateString()}</span>
                </div>
              </div>
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

export default Logs