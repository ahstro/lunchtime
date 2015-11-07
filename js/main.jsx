import React from 'react'
import ReactDOM from 'react-dom'
import Stream from './components/Stream'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Stream />,
    document.getElementById('mount')
  )
})
