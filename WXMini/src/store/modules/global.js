const globalModules = {
  state: {
    isSdkReady: false,
    isCalling: false,
    systemInfo: null
  },
  getters: {
    isSdkReady: state => state.isSdkReady,
    isCalling: state => state.isCalling,
    isIphoneX: state => state.systemInfo && state.systemInfo.model.indexOf('iPhone X') > -1
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
    },
    setSystemInfo (state, payload) {
      state.systemInfo = payload
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
