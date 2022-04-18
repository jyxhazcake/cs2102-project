import React from 'react'
import Input from '../../components/AllEmployees/Input'
import List from '../../components/AllEmployees/List'
import AdminSideBar from '../../components/Sidebar/AdminSidebar'

export default function AllEmployees() {
  return (
    <div>
      <AdminSideBar isSelectedEmployee={true} />
      <div
        style={{
          marginLeft: '200px' /* Same as the width of the sidebar */,
        }}
      >
        <h1>All Employees</h1>
        <List />
        <Input />
      </div>
    </div>
  )
}
