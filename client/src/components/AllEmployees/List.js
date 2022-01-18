import React, { useEffect, useState } from 'react'

export default function List() {
  const [employees, setEmployees] = useState([])

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
      <table className="table table-dark">
        <thead className="thead-light">
          <tr>
            <th scope="col">Employee ID</th>
            <th scope="col">Employee Name</th>
          </tr>
        </thead>
        <tbody>
          {employees.map((dept) => (
            <tr key={dept.eid}>
              <td>{dept.eid}</td>
              <td>{dept.ename}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  )
}
