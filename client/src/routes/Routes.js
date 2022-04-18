import React from 'react'
import { Route, Routes as Switch } from 'react-router-dom'

import AdminPage from '../pages/AdminPage'
import AllDepartments from '../pages/AllDepartments'
import LandingPage from '../pages/LandingPage'
import AllEmployees from '../pages/AllEmployees'
import MainEmployees from '../pages/MainEmployees'
import ProtectedRoutes from './ProtectedRoutes'

export const Routes = () => (
  <Switch>
    <Route path="/" element={<LandingPage />} />
    <Route element={<ProtectedRoutes />}>
      <Route path="/admin" element={<AdminPage />} />
      <Route path="/departments" element={<AllDepartments />} />
      <Route path="/employees" element={<AllEmployees />} />
      <Route path="/profile/:id" element={<MainEmployees />} />
    </Route>
    <Route path="*" element={<LandingPage />} />
  </Switch>
)
