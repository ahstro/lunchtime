import React from 'react'
import io from 'socket.io-client'
import Change from './change'
import Settings from './settings'

const Stream = React.createClass({
  getInitialState () {
    return {
      changes: [],
      scroll: true,
      options: {
        siteGlob: '',
        // TODO: Temporary hackaround to height problem when some
        // array members are 'log' or 'external' types.
        types: ['edit', 'new']
      }
    }
  },

  renderChange (data) {
    if (this.state.scroll) {
      if (this.state.options.types.indexOf(data.type) !== -1 &&
         data.server_name.match(this.state.options.siteGlob)) {
        this.setState({
          changes: [data]
          .concat(this.state.changes)
          // TODO: Allow custom length.
          // TODO: This causes height problems when only viewing
          // some types of changes, i.e. only 'edit' and 'new's.
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
  },

  handleMouseEnter () {
    this.setState({scroll: false})
  },

  handleMouseLeave () {
    // TODO: This is called when the mouse enters the right click menu.
    // Stop that. Firefox only :(
    this.setState({scroll: true})
  },

  setOptions (opts) {
    const newOpts = this.state.options
    Object.keys(opts).forEach((key) => {
      newOpts[key] = opts[key]
    })
    this.setState({options: newOpts})
  },

  render () {
    const changes = this.state.changes.map((change) => (
      <Change options={this.state.options} {...change} />
    ))

    return (
      <div>
        <Settings setOptions={this.setOptions} />
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
