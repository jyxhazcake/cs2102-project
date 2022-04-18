import React from 'react'
import { useNavigate } from 'react-router-dom'
import SidebarButton from './SidebarButton'
import EmployeeIcon from '../../assets/Sidebar/employees.svg'
import DepartmentIcon from '../../assets/Sidebar/departments.svg'
import { Logo, LeftContainer, Name, Line } from './styles/AdminSidebar.styled'
import logo from '../../assets/Logo.png'

export default function AdminSidebar(props) {
  const navigate = useNavigate()

  return (
    <LeftContainer>
      <Logo src={logo} alt="logo" />
      <Name> Admin Staff </Name>
      <Line />
      <SidebarButton
        icon={EmployeeIcon}
        text="Employees"
        isSelected={props.isSelectedEmployee}
        onClick={() => navigate('/employees')}
      />
      <SidebarButton
        icon={DepartmentIcon}
        text="Departments"
        isSelected={props.isSelectedDepartment}
        onClick={() => navigate('/departments')}
      />
    </LeftContainer>
  )
}
