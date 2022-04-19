import React from 'react'
import Button from './Button'
import ProfileIcon from '../../assets/Sidebar/profile_icon.svg'

export default function Sidebar(props) {
  return (
    <>
      <Button icon={ProfileIcon} text="Profile" state={props.state} />
      <Button icon={ProfileIcon} text="Profile" state={props.state} />
      <Button icon={ProfileIcon} text="Profile" state={props.state} />
    </>
  )
}
