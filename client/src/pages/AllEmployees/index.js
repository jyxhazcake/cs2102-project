import React from 'react'
import Input from '../../components/AllEmployees/Input'
import List from '../../components/AllEmployees/List'
import NavBar from '../../components/NavBar'

export default function AllEmployees() {
  return (
    <>
      <NavBar />
      <h1>All Employees</h1>
      <List />
      <Input />
    </>
  )
}
