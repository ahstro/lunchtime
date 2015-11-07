import React from 'react'

const Change = (change) => {
  // Do type specific stuff
  // Currently ignore 'log' and 'external' types
  switch (change.type) {
    case 'external':
      console.log(JSON.stringify(change))
      return <div></div>
    case 'log':
      return <div></div>
    case 'new':
      // TODO: Maybe show that the article is newly created somehow?
      break
  }

  // Check if user is anonymous
  const anonymous = change.user.match(/\d{1,3}.\d{1,3}.\d{1,3}.\d{1,3}/)

  // URL to user's page
  const userUrl = ((anon) => {
    return anon
      ? change.server_url + '/wiki/Special:Contributions/' + change.user
      : change.server_url + '/wiki/User:' + change.user
  })(anonymous)

  // Set color of user link
  const userColor = ((bot, anon) => {
    if (bot) return 'black'
    return anon ? 'red' : 'blue'
  })(change.bot, anonymous)

  // Set the site code based on site, e.g. [en] for English wikipedia
  // TODO: if(change.wiki.match(/wiktionary/)) console.log(change.wiki)
  const siteCode = ((wiki) => {
    switch (wiki) {
      case 'wikidatawiki': return 'wd'
      case 'commonswiki': return 'cm'
      case 'metawiki': return 'me'
      default: return wiki.slice(0, 2)
    }
  })(change.wiki)

  // URL to diff
  const diffUrl = change.server_url + change.server_script_path +
    '/index.php?diff=' + change.revision.new

  // Set color, size and prefix for edited bytes
  const editPositive = (!change.length.old || change.length.old < change.length.new)
  const editPrefix = editPositive ? '+' : '-'
  const editColor = editPositive ? 'green' : 'red'
  const editSize = !change.length.old
          ? change.length.new
          : Math.abs(change.length.old - change.length.new)

  // TODO: flag-icon-css?
  // TODO: Refactor to use <ul> and <li>?
  return (
    <div className='change'>
      <a href={userUrl} className='user'>
        <span className={'user ' + userColor} title={change.user}>&#8226;</span>
      </a>
      <span className='siteCode' title={change.server_name}>[{siteCode}] </span>
      <a href={diffUrl}>
        <span className='title' title={change.comment}>{change.title}</span>
      </a>
      <span className={'edit ' + editColor}>{editPrefix + editSize}</span>
    </div>
  )
}

export default Change
