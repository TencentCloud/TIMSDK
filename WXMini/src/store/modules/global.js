const globalModules = {
  state: {
    isSdkReady: false
  },
  getters: {
    isSdkReady: state => state.isSdkReady
  },
  mutations: {
    showToast (state, payload) {
      wx.showToast({
        title: payload.title,
        icon: payload.icon || 'none',
        duration: payload.duration || 800
      })
    },
    setSdkReady (state, payload) {
      state.isSdkReady = payload
    }
  },
  action: {
    kickedReset (context) {
      context.commit('resetGroup')
      context.commit('resetUser')
      context.commit('resetCurrentConversation')
      context.commit('resetAllConversation')
    }
  }
}

export default globalModules
