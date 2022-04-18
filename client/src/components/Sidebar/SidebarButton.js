import React from 'react'
import { Text, Container } from './styles/Button.styled'

export default function SidebarButton(props) {
  return (
    <Container
      onClick={props.onClick}
      isSelected={props.isSelected}
      type={props.type ?? 'button'}
    >
      <img src={props.icon} alt="temp" />
      <Text> {props.text} </Text>
    </Container>
  )
}
