import { createStore } from 'redux'

const INITIAL_STATE = {
  settings: {
    sources: '',
    // TODO: Temporary hackaround to height problem when some
    //       array members are 'log' or 'external' types.
    types: ['edit', 'new']
  }
}

const setSource = (state, newSource) => (
  {
    ...state,
    settings: {
      ...state.settings,
      sources: newSource
    }
  }
)

const setState = (state = INITIAL_STATE, action) => {
  switch (action.type) {
    case 'SET_SOURCE': return setSource(state, action.newSource)
    default: return state
  }
}

const Store = createStore(setState)

export default Store
