import { createStore } from 'redux'

const INITIAL_STATE = {
  settings: {
    sources: '',
    // TODO: Temporary hackaround to height problem when some
    //       array members are 'log' or 'external' types.
    types: ['edit', 'new']
  }
}

const updateSettings = (setting) => (state, newSetting) => (
  {...state, settings: {...state.settings, [setting]: newSetting}}
)

const setSources = updateSettings('sources')
const setTypes = updateSettings('types')

const Store = createStore((state = INITIAL_STATE, action) => {
  switch (action.type) {
    case 'SET_SOURCES': return setSources(state, action.newSource)
    case 'SET_TYPES': return setTypes(state, action.newTypes)
    default: return state
  }
})

export default Store