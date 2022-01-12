import React, { useState } from 'react'

export default function Input() {
  const [dname, setDname] = useState('')
  const [did, setDid] = useState('')

  //Adding a department
  const handleAdd = async (e) => {
    e.preventDefault()
    try {
      const body = {
        did: did,
        dname: dname,
      }
      const response = await fetch('http://localhost:3000/departments', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })

      console.log(response)

      // window.location.reload()
    } catch (err) {
      console.error(err.message)
    }
  }

  //Deleting a department with id
  const handleDelete = async (id) => {
    try {
      const response = await fetch(`http://localhost:3000/departments/${id}`, {
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
          placeholder="Department ID"
          type="text"
          value={did}
          onChange={(e) => setDid(e.target.value)}
        />
        <input
          placeholder="Department Name"
          type="text"
          value={dname}
          onChange={(e) => setDname(e.target.value)}
        />
        <button onClick={handleAdd}> Add </button>
        <button onClick={() => handleDelete(did)}> Delete </button>
      </form>
    </>
  )
}
