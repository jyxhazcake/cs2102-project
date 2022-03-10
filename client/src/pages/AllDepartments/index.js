import React from 'react'
import Input from '../../components/AllDepartments/Input'
import List from '../../components/AllDepartments/List'
import NavBar from '../../components/NavBar'

export default function AllDepartments() {
  return (
    <>
      <NavBar />
      <h1>All Departments</h1>
      <List />
      <Input />
    </>
  )
}
