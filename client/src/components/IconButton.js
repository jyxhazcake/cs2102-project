import React from 'react'
import styled from 'styled-components'

const Icon = styled.img`
  padding-right: 7px;
  display: inline-block;
`

const Text = styled.div`
  font-family: 'Roboto';
  font-style: normal;
  font-weight: 500;
  font-size: 14px;
  line-height: 21px;
  /* or 150% */

  letter-spacing: 0.1px;

  /* Black / High Emphasis */

  color: rgba(0, 0, 0, 0.87);
  display: inline-block;
`

const ButtonContainer = styled.button`
  all: unset;
  padding: 10px;
  cursor: pointer;
`

export default function IconButton(props) {
  return (
    <ButtonContainer type={props.type ?? 'button'} onClick={props.onClick}>
      <Icon src={props.src} alt="img" />
      <Text> {props.children} </Text>
    </ButtonContainer>
  )
}
