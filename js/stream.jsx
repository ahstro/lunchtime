let React = require('react')
let Change = require('./change')
let Settings = require('./settings')
let io = require('socket.io-client')

module.exports = React.createClass({
  getInitialState: function () {
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

  renderChange: function (data) {
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

  componentDidMount: function () {
    let socket = io.connect('stream.wikimedia.org/rc')
    socket.on('connect', () => {
      socket.emit('subscribe', '*') // TODO: Allow custom sites
    })
    socket.on('change', this.renderChange)
  },

  handleMouseEnter: function () {
    this.setState({scroll: false})
  },

  handleMouseLeave: function () {
    // TODO: This is called when the mouse enters the right click menu.
    // Stop that. Firefox only :(
    this.setState({scroll: true})
  },

  setOptions: function (opts) {
    let newOpts = this.state.options
    Object.keys(opts).forEach((key) => {
      newOpts[key] = opts[key]
    })
    this.setState({options: newOpts})
  },

  render: function () {
    let changes = this.state.changes.map((change) => (
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
