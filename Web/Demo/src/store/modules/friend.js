const friendModules = {
  state: {
    friendList: [],
    createGroupModelVisible: false
  },
  mutations: {
    upadteFriendList(state, friendList) {
      state.friendList = friendList
    },
    reset(state) {
      Object.assign(state, {
        friendList: [],
        createGroupModelVisible: false
      })
    }
  }
}

export default friendModules
