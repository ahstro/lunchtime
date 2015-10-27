let React = require('react')
let ReactDOM = require('react-dom')
let Stream = require('./components/stream')

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Stream />,
    document.getElementById('mount')
  )
})
