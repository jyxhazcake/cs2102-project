import React from 'react'
import { useNavigate } from 'react-router-dom'
import NavButtons from '../../components/AdminPage/NavButtons'

export default function LandingPage() {
  return (
      <div>
        <h1> Admin Page </h1>
        <div className="">
          <NavButtons />
        </div>
      </div>
    )
  }