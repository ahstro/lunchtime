let React = require('react')
let Change = require('./change')
let io = require('socket.io-client')

module.exports = React.createClass({
  getInitialState: () => ({
    changes: [],
    scroll: true
  }),

  componentDidMount: function () {
    let socket = io.connect('stream.wikimedia.org/rc')
    socket.on('connect', () => {
      socket.emit('subscribe', '*') // TODO: Allow custom sites
    })
    socket.on('change', (data) => {
      if (this.state.scroll) {
        // TODO: Temporary hackaround to height problem when some
        // array members are 'log' or 'external' types.
        if (data.type === 'edit' || data.type === 'new') {
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
    })
  },

  handleMouseEnter: function () {
    this.setState({scroll: false})
  },

  handleMouseLeave: function () {
    // TODO: This is called when the mouse enters the right click menu.
    // Stop that. Firefox only :(
    this.setState({scroll: true})
  },

  render: function () {
    let changes = this.state.changes.map((change) => <Change {...change} />)

    return (
      <div
        onMouseEnter={this.handleMouseEnter}
        onMouseLeave={this.handleMouseLeave}>
        {changes}
      </div>
    )
  }
})
