function Home() {
  return (
    <div className="home">
      <div className="container">
        <h1>Welcome to Policy Logs</h1>
        <p>
          This is a comprehensive policy logging system with web, mobile, and backend components.
        </p>
        <div className="features">
          <div className="feature-card">
            <h3>Web Dashboard</h3>
            <p>Full-featured React web application for managing and viewing policy logs.</p>
          </div>
          <div className="feature-card">
            <h3>Mobile Access</h3>
            <p>iOS and Android apps for on-the-go policy log access.</p>
          </div>
          <div className="feature-card">
            <h3>Robust Backend</h3>
            <p>Django-powered API for secure and scalable data management.</p>
          </div>
        </div>
      </div>
    </div>
  )
}

export default Home