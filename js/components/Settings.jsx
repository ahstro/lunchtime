import React from 'react'
import Store from '../Store'

const Settings = React.createClass({
  getInitialState () {
    return {
      types: Store.getState().settings.types
    }
  },

  componentDidMount () {
    Store.subscribe(this.handleSettingsChange)
  },

  handleSettingsChange () {
    this.setState({types: Store.getState().settings.types})
  },

  handleSourcesChange (e) {
    const newSource = Array.from(e.target).filter(target => target.selected)[0].value
    Store.dispatch({ type: 'SET_SOURCES', newSource })
  },

  handleTypesChange (e) {
    const { types } = this.state
    const newTypes = types.indexOf(e.target.value) !== -1
      ? types.filter(type => type !== e.target.value)
      : types.concat(e.target.value)
    Store.dispatch({ type: 'SET_TYPES', newTypes })
  },

  renderCheckboxes () {
    const { types } = this.state
    return ['Edit', 'New', 'Log', 'External'] .map(
      (type, _a, _b, loType = type.toLowerCase()) => (
        <label>
          <input
            checked={types.indexOf(loType) !== -1}
            value={loType}
            type='checkbox' />
          {type}
        </label>
      )
    )
  },

  render () {
    // TODO: Change names to correct language
    return (
      <div className='settings'>
        <select onChange={this.handleSourcesChange} name='wiki'>
          <option value=''>All Sources</option>
          <option value='wikipedia'>Any Wikipedia</option>
          <option value='wikidata'>Wikidata</option>
          <option value='commons'>Wikimedia Commons</option>
          <option value='en.wikipedia'>English Wikipedia</option>
          <option value='sv.wikipedia'>Swedish Wikipedia</option>
        </select>
        <form onChange={this.handleTypesChange}>
          {this.renderCheckboxes()}
        </form>
      </div>
    )
  }
})

export default Settings
