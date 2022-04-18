import React from 'react'
import Input from '../../components/AllDepartments/Input'
import List from '../../components/AllDepartments/List'
import AdminSidebar from '../../components/Sidebar/AdminSidebar'

export default function AllDepartments() {
  return (
    <>
      <AdminSidebar isSelectedDepartment={true} />
      <div style={{ marginLeft: '200px' }}>
        <h1>All Departments</h1>
        <List />
        <Input />
      </div>
    </>
  )
}
