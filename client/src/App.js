import './App.css'
import LandingPage from './pages/LandingPage'
import { useState, useEffect } from 'react'
import { BrowserRouter as Router } from 'react-router-dom'
import { Routes } from './routes/Routes'

function App() {

  const checkAuthenticated = async () => {
    try {
      const res = await fetch("http://localhost:3000/verify", {
        method: "POST",
        headers: { jwt_token: localStorage.token }
      });

      const parseRes = await res.json();

      parseRes === true ? setIsAuthenticated(true) : setIsAuthenticated(false);
    } catch (err) {
      console.error(err.message);
    }
  };

  useEffect(() => {
    checkAuthenticated();
  }, []);

  const [isAuthenticated, setIsAuthenticated] = useState(false);

  const setAuth = boolean => {
    setIsAuthenticated(boolean);
  };

  if(!isAuthenticated) {
    return <LandingPage setAuth={setAuth} />
  }

  return (
    <div className="App">
      <Router>
        <Routes />
      </Router>
    </div>
  )
}

export default App
