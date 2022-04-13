import './App.css'
import LandingPage from './pages/LandingPage'
import { BrowserRouter as Router } from 'react-router-dom'
import { Routes } from './routes/Routes'
import useToken from './useToken';

function App() {

  /*const { token, setToken } = useToken();
  
  if(!token) {
    return <LandingPage setToken={setToken} />
  }*/

  return (
    <div className="App">
      <Router>
        <Routes />
      </Router>
    </div>
  )
}

export default App
