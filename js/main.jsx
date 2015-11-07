import React from 'react'
import ReactDOM from 'react-dom'
import Stream from './components/stream'

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Stream />,
    document.getElementById('mount')
  )
})
