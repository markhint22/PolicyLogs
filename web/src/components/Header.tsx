import { Link } from 'react-router-dom'

function Header() {
  return (
    <header className="header">
      <div className="container">
        <Link to="/" className="logo">
          <h1>Policy Logs</h1>
        </Link>
        <nav>
          <ul className="nav-links">
            <li><Link to="/">Home</Link></li>
            <li><Link to="/logs">Logs</Link></li>
          </ul>
        </nav>
      </div>
    </header>
  )
}

export default Header