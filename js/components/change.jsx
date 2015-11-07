import React from 'react'

// TODO: Maybe rename 'props' to 'change'?
const Change = (props) => {
  // Do type specific stuff
  // Currently ignore 'log' and 'external' types
  switch (props.type) {
    case 'external':
      console.log(JSON.stringify(props))
      return <div></div>
    case 'log':
      return <div></div>
    case 'new':
      // TODO: Maybe show that the article is newly created somehow?
      break
  }

  // Check if user is anonymous
  const anonymous = props.user.match(/\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/)

  // URL to user's page
  const userUrl = ((anon) => {
    return anon
      ? props.server_url + '/wiki/Special:Contributions/' + props.user
      : props.server_url + '/wiki/User:' + props.user
  })(anonymous)

  // Set color of user link
  const userColor = ((bot, anon) => {
    if (bot) return 'black'
    return anon ? 'red' : 'blue'
  })(props.bot, anonymous)

  // Set the site code based on site, e.g. [en] for English wikipedia
  // TODO: if(props.wiki.match(/wiktionary/)) console.log(props.wiki)
  const siteCode = ((wiki) => {
    switch (wiki) {
      case 'wikidatawiki': return 'wd'
      case 'commonswiki': return 'cm'
      case 'metawiki': return 'me'
      default: return wiki.slice(0, 2)
    }
  })(props.wiki)

  // URL to diff
  const diffUrl = props.server_url + props.server_script_path +
    '/index.php?diff=' + props.revision.new

  // Set color, size and prefix for edited bytes
  const editPositive = (!props.length.old || props.length.old < props.length.new)
  const editPrefix = editPositive ? '+' : '-'
  const editColor = editPositive ? 'green' : 'red'
  const editSize = !props.length.old
          ? props.length.new
          : Math.abs(props.length.old - props.length.new)

  // TODO: flag-icon-css?
  // TODO: Refactor to use <ul> and <li>?
  return (
    <div className='change'>
      <a href={userUrl} className='user'>
        <span className={'user ' + userColor} title={props.user}>&#8226;</span>
      </a>
      <span className='siteCode' title={props.server_name}>[{siteCode}] </span>
      <a href={diffUrl}>
        <span className='title' title={props.comment}>{props.title}</span>
      </a>
      <span className={'edit ' + editColor}>{editPrefix + editSize}</span>
    </div>
  )
}

export default Change
