let React = require('react')
let ReactDOM = require('react-dom')
let Stream = require('./stream')

let options = {}

document.addEventListener('DOMContentLoaded', () => {
  ReactDOM.render(
    <Stream {...options} />,
    document.getElementById('changes')
  )
})
