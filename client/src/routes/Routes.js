import React from 'react'
import { Route, Routes as Switch } from 'react-router-dom'

import AllDepartments from '../pages/AllDepartments'
import LandingPage from '../pages/LandingPage'
import AllEmployees from '../pages/AllEmployees'
import Profile from '../components/MainEmployees/Profile'
import MainEmployees from '../pages/MainEmployees'

export const Routes = () => (
  <Switch>
    <Route path="/" element={<LandingPage />} />
    <Route path="/departments" element={<AllDepartments />} />
    <Route path="/employees" element={<AllEmployees />} />
    <Route path="/profile/:id" element={<MainEmployees />} />
  </Switch>
)
