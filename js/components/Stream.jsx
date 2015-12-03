import React from 'react'
import io from 'socket.io-client'
import Change from './Change'
import Settings from './Settings'
import Store from '../Store'

const Stream = React.createClass({
  getInitialState () {
    return {
      changes: [],
      scroll: true,
      settings: Store.getState().settings
    }
  },

  getUserType(change) {
    return change.bot ? 'bot'
      : change.user.match(/\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/)
        ? 'anonymous'
        : 'user'
  },

  renderChange (data) {
    const { scroll, settings, changes } = this.state
    data.userType = this.getUserType(data)
    if (scroll) {
      if (settings.types.indexOf(data.type) !== -1 &&
          settings.userTypes.indexOf(data.userType) !== -1 &&
          data.server_name.match(settings.sources)) {
        this.setState({
          changes: [data]
          .concat(changes)
          // TODO: Allow custom length.
          // TODO: This causes height problems when only viewing
          //       some types of changes, i.e. only 'edit' and 'new's.
          .slice(0, 24)
        })
      }
    }
  },

  componentDidMount () {
    const socket = io.connect('stream.wikimedia.org/rc')
    socket.on('connect', () => {
      socket.emit('subscribe', '*') // TODO: Allow custom sites
    })
    socket.on('change', this.renderChange)
    Store.subscribe(this.handleSettingsChange)
  },

  handleSettingsChange () {
    this.setState({settings: Store.getState().settings})
  },

  handleMouseEnter () {
    this.setState({scroll: false})
  },

  handleMouseLeave () {
    // TODO: This is called when the mouse enters the right click menu.
    //       Stop that. Firefox only :(
    this.setState({scroll: true})
  },

  render () {
    const changes = this.state.changes.map(change => (
      <Change
        key={`${change.id || change.log_id || change.log_params.log}-${change.timestamp}`}
        {...change} />
    ))

    return (
      <div>
        <Settings />
        <div
          className='changes'
          onMouseEnter={this.handleMouseEnter}
          onMouseLeave={this.handleMouseLeave}>
          {changes}
        </div>
      </div>
    )
  }
})

export default Stream
