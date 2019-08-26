const groupModules = {
  state: {
    groupList: [],
    createGroupModelVisible: false
  },
  getters: {
    hasGroupList: state => state.groupList.length > 0
  },
  mutations: {
    updateGroupList(state, groupList) {
      state.groupList = groupList
    },
    updateCreateGroupModelVisible(state, visible) {
      state.createGroupModelVisible = visible
    },
    reset(state) {
      Object.assign(state, {
        groupList: [],
        createGroupModelVisible: false
      })
    }
  },
  actions: {
    updateGroupList(context, groupList) {
      context.commit('updateGroupList', groupList)
    }
  }
}

export default groupModules
