import tim from 'tim'

const groupModules = {
  state: {
    groupList: [],
    currentMemberList: [],
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
    updateCurrentMemberList(state, memberList) {
      state.currentMemberList = [...state.currentMemberList, ...memberList]
    },
    resetCurrentMemberList(state) {
      state.currentMemberList = []
    },
    reset(state) {
      Object.assign(state, {
        groupList: [],
        currentMemberList: [],
        createGroupModelVisible: false
      })
    }
  },
  actions: {
    updateGroupList(context, groupList) {
      context.commit('updateGroupList', groupList)
    },
    getGroupMemberList(context, groupID) {
      return tim.getGroupMemberList({
        groupID: groupID,
        offset: context.state.currentMemberList.length,
        count: 30
      }).then((imResponse) => {
        context.commit('updateCurrentMemberList', imResponse.data.memberList)
        return imResponse
      })
    }
  }
}

export default groupModules
