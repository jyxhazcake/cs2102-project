import React from 'react'
import { useNavigate } from 'react-router-dom'
import NavButtons from '../../components/AdminPage/NavButtons'

export default function LandingPage() {
    const navigate = useNavigate()
  
    return (
      <div>
        <h1> Landing Page </h1>
        <div className="">
          <input type = "text" name = "Username" />
          <input type = "text" name = "Password" />
        </div>
      </div>
    )
  }