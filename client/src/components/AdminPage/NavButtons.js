import React from 'react'
import { useNavigate } from 'react-router-dom'
import { StyledButton, ButtonContainer } from './styles/NavButtons.styled'

export default function NavButtons() {
  const navigate = useNavigate()

  return (
    <div>
      <ButtonContainer>
        <StyledButton
          type="button"
          className="btn btn-dark"
          onClick={() => navigate('/departments')}
        >
          Departments
        </StyledButton>
        <StyledButton
          type="button"
          className="btn btn-dark"
          onClick={() => navigate('/employees')}
        >
          Employees
        </StyledButton>
      </ButtonContainer>
    </div>
  )
}
