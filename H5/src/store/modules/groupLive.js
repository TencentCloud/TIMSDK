const groupLiveModules = {
  state: {
    groupLiveInfo: {
      groupID: 0, // 群内直播时为当前群的ID,群组外直播时groupID设置为0
      roomID: 0, // 直播间ID,直播间内的直播群ID与roomID相同
      anchorID: 0, // 主播ID
      roomName: '', // 直播间名称
      isNeededQuitRoom: 0 // 是否需要主动退出直播间 0 默认 1 主动退出
    },
    avChatRoomMessageList: [], // 群直播中直播群消息列表
    avChatRoomGiftMessageList: [], // 群直播中直播群礼物消息列表
    avChatRoomBarrageMessageList: [] // 群直播中直播群弹幕消息列表
  },
  getters: {},
  mutations: {
    /**
     * 更新群直播信息
     * @param {Object} state
     * @param {Object} payload
     */
    updateGroupLiveInfo(state, payload) {
      state.groupLiveInfo = { ...state.groupLiveInfo, ...payload }
    },
    /**
     * 重置群直播信息
     * @param {Object} state
     * @param {Object} payload
     */
    resetGroupLiveInfo(state, payload) {
      state.groupLiveInfo = { ...state.groupLiveInfo, ...payload }
    },
    /**
     * 清除群直播消息列表
     * @param {Object} state
     * @param {Object} payload
     */
    clearAvChatRoomMessageList(state) {
      state.avChatRoomMessageList = []
      state.avChatRoomBarrageMessageList = []
      state.avChatRoomGiftMessageList = []
    },
    /**
     * 将群直播内的直播群消息push进列表
     * @param {Object} state
     * @param {Message[]|Message} data
     * @returns
     */
    pushAvChatRoomMessageList(state, data) {
      // 自定义消息结构体
      // "{"version":"1.0.0","message":"","command":"4","action":301}" 点赞消息
      // "{"version":"1.0.0","message":"Qq","command":"5","action":301}" 弹幕消息
      // "{"version":"1.0.0","message":"2","command":"6","action":301}" 礼物消息
      if (Array.isArray(data)) {
        // 筛选出当前会话的消息
        const result = data.filter(item => item.to === state.groupLiveInfo.roomID)
        state.avChatRoomMessageList = [...state.avChatRoomMessageList, ...result]
        // 弹幕、礼物消息暂时不需要单独处理，此处逻辑先注释
        // const customMessageList = result.filter(item => item.type === 'TIMCustomElem')
        // const barrageMessageList = []
        // const giftMessageList = []
        // customMessageList.forEach(item => {
        //   const data = JSON.parse(item.payload.data)
        //   if (data.command === '5') {
        //     barrageMessageList.push(item)
        //   }
        //   if (data.command === '6') {
        //     giftMessageList.push(item)
        //   }
        // })
        // state.avChatRoomBarrageMessageList = [...state.avChatRoomBarrageMessageList, ...barrageMessageList]
        // state.avChatRoomGiftMessageList = [...state.avChatRoomGiftMessageList, ...giftMessageList]
      } else if (data.to === state.groupLiveInfo.roomID) {
        state.avChatRoomMessageList = [...state.avChatRoomMessageList, data]
        // if (data.type === 'TIMCustomElem') {
        //   const Data = JSON.parse(data.payload.data)
        //   if (Data.command === '5') {
        //     state.avChatRoomBarrageMessageList = [...state.avChatRoomBarrageMessageList, data]
        //   }
        //   if (Data.command === '6') {
        //     state.avChatRoomGiftMessageList = [...state.avChatRoomGiftMessageList, data]
        //   }
        // }
      }
    },
  },
  actions: {}
}

export default groupLiveModules
