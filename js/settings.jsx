let React = require('react')

module.exports = React.createClass({
  propTypes: {
    setOptions: React.PropTypes.func
  },

  handleChange: function (e) {
    this.props.setOptions({
      siteGlob: Array.from(e.target).filter(target => target.selected)[0].value
    })
  },

  render: function () {
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
