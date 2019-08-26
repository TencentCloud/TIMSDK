import tim from '../../tim'
const blacklistModule = {
  state: {
    blacklist: []
  },
  mutations: {
    updateBlacklist(state, blacklist) {
      state.blacklist = blacklist
    },
    removeFromBlacklist(state, userID) {
      state.blacklist = state.blacklist.filter(item => item.userID !== userID)
    },
    reset(state) {
      Object.assign(state, {
        blacklist: []
      })
    }
  },
  actions: {
    getBlacklist(context) {
      tim
        .getBlacklist()
        .then(({ data }) => tim.getUserProfile({ userIDList: data }))
        .then(({ data }) => {
          context.commit('updateBlacklist', data)
        })
    }
  }
}

export default blacklistModule
