import React, { useState } from 'react'
import {
  TableContainer,
  Row,
  Header,
  Data,
  Icon,
  ResignedText,
} from '../Table/Table.styled'
import { ButtonContainer } from '../Form/Form.styled'
import { useNavigate } from 'react-router-dom'
import trash from '../../assets/Trashcan.svg'
import Modal from '../Modal'
import ConfirmationText from '../ConfirmationText'
import TextButton from '../TextButton'

export default function TableEmployee(props) {
  const headers = ['#', 'Name', 'Role', '']
  const [showConfirm, setShowConfirm] = useState(0)
  const navigate = useNavigate()

  const today = new Date()
  //Removing an employee with id
  const handleResign = async (id) => {
    try {
      const body = {
        eid: id,
        date: today,
      }
      const response = await fetch(`http://localhost:3000/employees/resign`, {
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

  return (
    <>
      <TableContainer>
        <tbody>
          <Row>
            {headers.map((hdr) => (
              <Header key={hdr}> {hdr} </Header>
            ))}
          </Row>
          {props.data.map((emp) => (
            <Row key={emp.eid}>
              <Data onClick={() => navigate(`/profile/${emp.eid}`)}>
                {emp.eid}
              </Data>
              <Data onClick={() => navigate(`/profile/${emp.eid}`)}>
                {emp.ename}
              </Data>
              <Data> {emp.role} </Data>
              <Data>
                {emp.resigned_date ? (
                  <ResignedText> Resigned </ResignedText>
                ) : (
                  <Icon
                    src={trash}
                    alt="delete"
                    onClick={() => setShowConfirm(emp.eid)}
                  />
                )}
              </Data>

              {showConfirm === emp.eid && (
                <Modal width="50%" margin="100px auto">
                  <ConfirmationText>
                    Confirm resignation of {emp.ename}?
                  </ConfirmationText>
                  <ButtonContainer>
                    <TextButton onClick={() => setShowConfirm(0)}>
                      Cancel
                    </TextButton>
                    <TextButton
                      enabled={true}
                      onClick={() => handleResign(emp.eid)}
                    >
                      Confirm
                    </TextButton>
                  </ButtonContainer>
                </Modal>
              )}
            </Row>
          ))}
        </tbody>
      </TableContainer>
    </>
  )
}
