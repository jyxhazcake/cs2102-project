import React from 'react'
import { useNavigate } from 'react-router-dom'

export default function LandingPage() {
  const navigate = useNavigate()

  return (
    <div>
      <h1> Landing Page </h1>
      <button
        type="button"
        className="btn btn-dark"
        onClick={() => navigate('/departments')}
      >
        All Departments
      </button>
    </div>
  )
}
