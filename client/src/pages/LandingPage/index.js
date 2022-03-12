import React from 'react'
import { useNavigate } from 'react-router-dom'
import NavButtons from '../../components/AdminPage/NavButtons'

export default function LandingPage() {
    const navigate = useNavigate()
  
    return (
      <div>
        <h1> Landing Page </h1>
        <form action="/" method="POST">
          <div>
            <input 
            type="text" 
            id="username" 
            name="username"
            placeholder="Username" 
            required/>
          </div>
          <div>
            <input 
            type="text" 
            id="password" 
            name="password" 
            placeholder="Password"
            required/>
          </div>
          <div>
            <input
            type="submit"
            value="Log in"
            />
          </div>
        </form>
      </div>
    )
}