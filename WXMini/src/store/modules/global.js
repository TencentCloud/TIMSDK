const globalModules = {
  state: {
    isSdkReady: false,
    isCalling: false
  },
  getters: {
    isSdkReady: state => state.isSdkReady,
    isCalling: state => state.isCalling
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
    },
    setCalling (state, payload) {
      state.isCalling = payload
    }
  },
  actions: {
    resetStore (context) {
      context.commit('resetGroup')
      context.commit('resetUser')
      context.commit('resetCurrentConversation')
      context.commit('resetAllConversation')
    }
  }
}

export default globalModules
