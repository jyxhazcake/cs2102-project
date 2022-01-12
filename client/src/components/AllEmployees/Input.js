import React, { useState } from 'react'

export default function Input() {
  const [name, setName] = useState('')
  const [did, setDid] = useState('')
  const [mobileNum, setMobileNum] = useState('')
  const [kind, setKind] = useState('Senior')
  const [homeNum, setHomeNum] = useState('')
  const [officeNum, setOfficeNum] = useState('')

  //Adding an employee
  const handleAdd = async (e) => {
    e.preventDefault()
    try {
      const body = {
        did: did,
        name: name,
        mobilenum: mobileNum,
        kind: kind,
        homenum: homeNum,
        officenum: officeNum,
      }
      const response = await fetch('http://localhost:3000/employees', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      })
      console.log(response)

      //window.location.reload()
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
      {/* <!-- Button trigger modal --> */}
      <button
        type="button"
        className="btn btn-dark"
        data-toggle="modal"
        data-target="#employeeModal"
      >
        Add Employee
      </button>

      {/* <!-- Modal --> */}
      <div
        className="modal fade"
        id="employeeModal"
        tabIndex="-1"
        role="dialog"
        aria-labelledby="exampleModalLabel"
        aria-hidden="true"
      >
        <div className="modal-dialog" role="document">
          <div className="modal-content">
            <div className="modal-header">
              <h5 className="modal-title" id="exampleModalLongTitle">
                Add an Employee
              </h5>
              <button
                type="button"
                className="close"
                data-dismiss="modal"
                aria-label="Close"
              >
                <span aria-hidden="true">&times;</span>
              </button>
            </div>
            <div className="modal-body">
              <form>
                <div className="form-group">
                  <h5 className="col-form-label">Department ID</h5>
                  <input
                    className="form-control"
                    type="text"
                    value={did}
                    onChange={(e) => setDid(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <h5 className="col-form-label">Employee Name</h5>
                  <input
                    className="form-control"
                    // placeholder="Employee Name"
                    type="text"
                    value={name}
                    onChange={(e) => setName(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <h5 className="col-form-label">Mobile Number</h5>
                  <input
                    className="form-control"
                    // placeholder="Mobile Number"
                    type="text"
                    value={mobileNum}
                    onChange={(e) => setMobileNum(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <h5 className="col-form-label">Home Number (Optional)</h5>
                  <input
                    className="form-control"
                    // placeholder="Home Number"
                    type="text"
                    value={homeNum}
                    onChange={(e) => setHomeNum(e.target.value)}
                  />
                </div>
                <div className="form-group">
                  <h5 className="col-form-label">Office Number (Optional)</h5>
                  <input
                    className="form-control"
                    // placeholder="Office Number"
                    type="text"
                    value={officeNum}
                    onChange={(e) => setOfficeNum(e.target.value)}
                  />
                </div>
              </form>
            </div>
            <div class="modal-footer">
              <button type="button" class="btn btn-success" onClick={handleAdd}>
                Submit
              </button>
            </div>
          </div>
        </div>
      </div>
    </>
  )
}
