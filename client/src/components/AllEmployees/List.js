import React, { useEffect, useState } from 'react'

export default function List() {
  const [departments, setDepartments] = useState([])

  const getDepartments = async () => {
    try {
      const response = await fetch('http://localhost:3000/employees')
      const jsonData = await response.json()

      console.log(jsonData)

      setDepartments(jsonData)
    } catch (err) {
      console.error(err.message)
    }
  }

  useEffect(() => {
    getDepartments()
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
          {departments.map((dept) => (
            <tr key={dept.did}>
              <td>{dept.did}</td>
              <td>{dept.name}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </>
  )
}
