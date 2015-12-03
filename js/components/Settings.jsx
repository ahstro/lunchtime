import React from 'react'
import Store from '../Store'
import { WIKIS } from '../Static'

const Settings = React.createClass({
  getInitialState () {
    const state = Store.getState()
    return {
      userTypes: state.settings.userTypes,
      types: state.settings.types
    }
  },

  componentDidMount () {
    Store.subscribe(this.handleSettingsChange)
  },

  handleSettingsChange () {
    this.setState(this.getInitialState())
  },

  handleUserTypesChange (e) {
    const { userTypes } = this.state
    const newUserTypes = userTypes.indexOf(e.target.value) !== -1
      ? userTypes.filter(type => type !== e.target.value)
      : userTypes.concat(e.target.value)
    Store.dispatch({ type: 'SET_USER_TYPES', newUserTypes })
  },

  handleSourcesChange (e) {
    const newSource = Array.from(e.target).filter(target => (
      target.selected))[0].value
    Store.dispatch({ type: 'SET_SOURCES', newSource })
  },

  handleTypesChange (e) {
    const { types } = this.state
    const newTypes = types.indexOf(e.target.value) !== -1
      ? types.filter(type => type !== e.target.value)
      : types.concat(e.target.value)
    Store.dispatch({ type: 'SET_TYPES', newTypes })
  },

  renderCheckboxes (labels, handleChange, types) {
    return labels.map(
      (type, _a, _b, loType = type.toLowerCase()) => (
        <label key={type}>
          <input
            onChange={handleChange}
            checked={types.indexOf(loType) !== -1}
            value={loType}
            type='checkbox' />
          {type}
        </label>
      )
    )
  },

  renderWikis (wikis) {
    return Object.keys(wikis).map(wiki => (
      <option key={wiki} value={`${wiki}.wikipedia`}>
        {wikis[wiki]} Wikipedia
      </option>
    ))
  },

  render () {
    // TODO: Change names to correct language
    return (
      <div className='settings'>
        <select onChange={this.handleSourcesChange} name='wiki'>
          <option value=''>All Sources</option>
          <option value='wikidata'>Wikidata</option>
          <option value='commons'>Wikimedia Commons</option>
          <optgroup label='Wikipedias'>
            <option value='wikipedia'>Any Wikipedia</option>
            {this.renderWikis(WIKIS)}
          </optgroup>
        </select>
        <form>
          {this.renderCheckboxes(['Edit', 'New', 'Log', 'External'], this.handleTypesChange, this.state.types)}
        </form>
        <form>
          {this.renderCheckboxes(['Anonymous', 'User', 'Bot'], this.handleUserTypesChange, this.state.userTypes)}
        </form>
      </div>
    )
  }
})

export default Settings
