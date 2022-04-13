import React, { useState, useEffect } from 'react'
import { useParams } from 'react-router-dom'
import { Header, Data, ProfileBox, StyledImg } from './styles/Profile.styled'
import DefaultAvatar from '../../assets/Default_Avatar.png'

export default function Profile() {
  const { id } = useParams()
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
    <ProfileBox>
      {employees
        .filter((employee) => employee.eid == id)
        .map((employee) => (
          <div key={employee.eid}>
            <Header> Profile Picture </Header>
            <StyledImg src={DefaultAvatar} alt="default_avatar" />
            <Header> Name </Header>
            <Data> {employee.ename}</Data>
            <Header> Employee ID </Header>
            <Data> {employee.eid}</Data>
            <Header> Employee Email </Header>
            <Data> {employee.email}</Data>
            <Header> Mobile Contact </Header>
            <Data> +65 {employee.mobile_num}</Data>
            <Header> Office Contact </Header>
            <Data> {employee.office_num}</Data>
            <Header> Department </Header>
            <Data> Data Not Yet Gathered</Data>
            <Header> Department ID </Header>
            <Data> {employee.did}</Data>
            <Header> Role </Header>
            <Data> {employee.role}</Data>
          </div>
        ))}
    </ProfileBox>
  )
}
