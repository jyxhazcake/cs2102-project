import React, { useState } from 'react'

export default function Input() {
  const [ename, setEname] = useState('')
  const [eid, setEid] = useState('')

  //Adding an employee
  const handleAdd = async (e) => {
    e.preventDefault()
    try {
      const body = {
        eid: eid,
        ename: ename,
      }
      const response = await fetch('http://localhost:3000/employees', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      console.log(response)

      window.location.reload()
    } catch (err) {
      console.error(err.message)
    }
  }

  //Removing an employee with id
  const handleDelete = async (id) => {
    try {
      const response = await fetch(`http://localhost:3000/employees/${id}`, {
        method: 'DELETE',
      })
      console.log(response)

      // window.location.reload()
    } catch (err) {
      console.error(err.message)
    }
  }

  return (
    <>
      <form>
        <input
          placeholder="Employee ID"
          type="text"
          value={eid}
          onChange={(e) => setEid(e.target.value)}
        />
        <input
          placeholder="Employee Name"
          type="text"
          value={ename}
          onChange={(e) => setEname(e.target.value)}
        />
        <button onClick={handleAdd}> Add </button>
        <button onClick={() => handleDelete(eid)}> Delete </button>
      </form>
    </>
  )
}
