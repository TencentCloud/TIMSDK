import TIM from 'tim-js-sdk/tim-js-friendship'
const friendModules = {
  state: {
    friendList: [],
    applicationList: [],
    unreadCount: 0,
    createGroupModelVisible: false,
    friendGroupList: [],
    currentMemberList: [],
    friendContent: {},
    applicationContent: {},
    },
  mutations: {
    updateFriendList(state, friendList) {
      state.friendList = friendList
    },
    updateUnreadCount(state, unreadCount) {
      state.unreadCount = unreadCount
    },
    updateFriendGroupList(state, friendGroupList) {
      state.friendGroupList = friendGroupList
    },
    updateApplicationList(state, applicationList) {
      state.applicationList = applicationList
    },
    updateFriendContent(state, friendContent) {
      state.friendContent = friendContent
    },
    updateApplicationContent(state, applicationContent) {
      state.applicationContent = applicationContent
    },
    resetApplicationContent(state) {
      state.applicationContent = {}
    },
    resetFriendContent(state) {
      state.friendContent = {}
    },
    deleteApplicationList(state, applicationInfo) {
      const { to, applicationType } = applicationInfo
      if (applicationType === TIM.TYPES.APPLICATION_TYPE_COMEIN) {
        state.comeInApplicationList = state.comeInApplicationList.filter(item => item.to !== to)
      }
      if (applicationType === TIM.TYPES.APPLICATION_TYPE_SENDOUT) {
        state.sendOutApplicationList = state.sendOutApplicationList.filter(item => item.to !== to)
      }
    },
    deleteFriend(state, userID) {
      state.friendList = state.friendList.filter(item => item.userID !== userID)
    },
    // 删除好友分组
    deleteFriendGroupList(state, groupNameList) {
      state.friendGroupList = state.friendGroupList.filter((groupItem) => !groupNameList.includes(groupItem.groupName))
    },
    // 增加好友分组
    addFriendGroupList(state, friendGroup) {
      state.friendGroupList = [...state.friendGroupList, ...friendGroup]
    },
    // 更新分组信息
    updateFriendGroupInfo(state, groupInfo) {
      state.friendGroupList = state.friendGroupList.map( groupItem=> {
        return groupItem.groupName === groupInfo.groupName ? groupInfo : groupItem
      })

    },
    reset(state) {
      Object.assign(state, {
        friendGroupList: [],
        friendList: [],
        applicationList: [],
        createGroupModelVisible: false
      })
    }
  },
  actions: {
    setFriendContent(context, friendContent) {
      context.commit('resetCurrentConversation')
      context.commit('resetApplicationContent')
      context.commit('updateFriendContent', friendContent)
    },
    setApplicationContent(context, applicationContent) {
      context.commit('resetCurrentConversation')
      context.commit('resetFriendContent')
      context.commit('updateApplicationContent', applicationContent)

    },
  }
}

export default friendModules
