import React from 'react'
import Store from '../Store'

const Settings = React.createClass({
  handleChange (e) {
    const newSource = Array.from(e.target).filter(target => target.selected)[0].value
    Store.dispatch({
      type: 'SET_SOURCES',
      newSource
    })
  },

  render () {
    // TODO: Change names to correct language
    return (
      <div>
        <select onChange={this.handleChange} name='wiki'>
          <option value=''>All Sources</option>
          <option value='wikipedia'>Any Wikipedia</option>
          <option value='wikidata'>Wikidata</option>
          <option value='commons'>Wikimedia Commons</option>
          <option value='en.wikipedia'>English Wikipedia</option>
          <option value='sv.wikipedia'>Swedish Wikipedia</option>
        </select>
      </div>
    )
  }
})

export default Settings
