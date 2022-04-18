import React, { useEffect, useState } from 'react'
import { useNavigate } from 'react-router-dom'

export default function List() {
  const navigate = useNavigate()
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
    <div>
      <table className="table table-dark">
        <thead className="thead-light">
          <tr>
            <th scope="col">Employee ID</th>
            <th scope="col">Employee Name</th>
          </tr>
        </thead>
        <tbody>
          {employees.map((dept) => (
            <tr key={dept.eid} onClick={() => navigate(`/profile/${dept.eid}`)}>
              <td>{dept.eid}</td>
              <td>{dept.ename}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
