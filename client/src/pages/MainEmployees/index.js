import React, { useState } from 'react'
import Profile from '../../components/MainEmployees/Profile'
import Button from '../../components/Sidebar/Button'
import Sidebar from '../../components/Sidebar/Sidebar'

export default function MainEmployees() {
  const [currentTab, setCurrentTab] = useState(1)
  const sections = ['Profile', 'Meetings', 'Bookings']

  function TabPage(tabID) {
    switch (tabID) {
      case 1:
        return <Profile />
    }
  }
  return (
    <>
      {sections.map((section, index) => {
        const isSelected = sections.indexOf(section) === currentTab - 1
        return (
          <Button
            key={index}
            onClick={() => setCurrentTab(index + 1)}
            isSelected={isSelected}
          >
            {section}
          </Button>
        )
      })}
      {TabPage(currentTab)}
    </>
  )
}
