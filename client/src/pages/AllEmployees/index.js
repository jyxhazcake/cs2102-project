import React, { useState, useEffect } from 'react'
import AddEmployee from '../../components/AllEmployees/AddEmployee'
import AdminSideBar from '../../components/Sidebar/AdminSidebar'
import TableEmployee from '../../components/AllEmployees/TableEmployee'
import CheckHealth from '../../components/AllEmployees/CheckHealth'
import SearchInput from '../../components/SearchInput'

export default function AllEmployees() {
  const [employees, setEmployees] = useState([])
  const [search, setSearch] = useState('')

  const getEmployees = async () => {
    try {
      const response = await fetch('http://localhost:3000/employees')
      const jsonData = await response.json()

      console.log(jsonData)

      setEmployees(jsonData)
    } catch (err) {
      console.error(err.message)
    }
  }

  useEffect(() => {
    getEmployees()
  }, [])

  return (
    <>
      <AdminSideBar isSelectedEmployee={true} />
      <div
        style={{
          marginLeft: '200px' /* Same as the width of the sidebar */,
        }}
      >
        <SearchInput
          placeholder="Search Employees"
          onChange={(e) => setSearch(e.target.value)}
        />
        <AddEmployee />
        <CheckHealth />
        <TableEmployee
          data={employees.filter((emp) => {
            for (const property in emp) {
              if (
                property === 'eid' ||
                property === 'ename' ||
                property === 'role'
              ) {
                if (
                  String(emp[property])
                    .toLowerCase()
                    .includes(search.toLowerCase())
                ) {
                  return emp
                }
              }
            }
          })}
        />
      </div>
    </>
  )
}
