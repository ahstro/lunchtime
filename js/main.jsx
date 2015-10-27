let React = require('react')
let ReactDOM = require('react-dom')
let Stream = require('./stream')

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Stream />,
    document.getElementById('mount')
  )
})
