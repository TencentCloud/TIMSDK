const groupModules = {
  state: {
    groupList: [],
    currentGroupProfile: {}
  },
  getters: {
    hasGroupList: state => state.groupList.length > 0
  },
  mutations: {
    updateGroupList (state, groupList) {
      state.groupList = groupList
    },
    updateCurrentGroupProfile (state, groupProfile) {
      state.currentGroupProfile = groupProfile
    },
    resetGroup (state) {
      state.groupList = []
      state.currentGroupProfile = {}
    }
  }
}

export default groupModules
