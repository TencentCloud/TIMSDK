const groupModules = {
  state: {
    groupList: [],
    currentGroupProfile: {},
    currentGroupMemberList: [],
    offset: 0,
    count: 15,
    isLoading: false
  },
  getters: {
    hasGroupList: state => state.groupList.length > 0
  },
  mutations: {
    updateOffset (state) {
      state.offset += state.count
    },
    updateGroupList (state, groupList) {
      state.groupList = groupList
    },
    updateCurrentGroupMemberList (state, groupMemberList) {
      state.currentGroupMemberList = [...state.currentGroupMemberList, ...groupMemberList]
    },
    updateCurrentGroupProfile (state, groupProfile) {
      state.currentGroupProfile = groupProfile
    },
    resetGroup (state) {
      state.groupList = []
      state.currentGroupProfile = {}
      state.currentGroupMemberList = []
      state.offset = 0
    },
    setCurrentGroupMemberList (state, groupMemberList) {
      state.currentGroupMemberList = [...groupMemberList]
    }
  },
  actions: {
    getGroupMemberList (context) {
      const { offset, count, isLoading, currentGroupProfile: { memberNum, groupID } } = context.state
      const notCompleted = (offset < memberNum)
      if (notCompleted) {
        if (!isLoading) {
          context.state.isLoading = true
          wx.$app.getGroupMemberList({ groupID: groupID, offset: offset, count: count }).then((res) => {
            context.commit('updateCurrentGroupMemberList', res.data.memberList)
            context.commit('updateOffset')
            context.state.isLoading = false
          }).catch(err => {
            console.log(err)
          })
        } else {
          wx.showToast({
            title: '你拉的太快了',
            icon: 'none',
            duration: 500
          })
        }
      } else {
        wx.showToast({
          title: '没有更多啦',
          icon: 'none',
          duration: 1500
        })
      }
    }
  }
}

export default groupModules
