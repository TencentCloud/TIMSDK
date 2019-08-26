import { formatTime } from '../../utils/index'
import { decodeElement } from '../../utils/decodeElement'

const conversationModules = {
  state: {
    allConversation: [], // 所有的conversation
    currentConversationID: '', // 当前聊天对话ID
    currentConversation: {}, // 当前聊天对话信息
    currentMessageList: [], // 当前聊天消息列表
    nextReqMessageID: '', // 下一条消息标志
    imageUrls: [], // 当前会话中已加载信息所有的图片链接
    isCompleted: false, // 当前会话消息是否已经请求完毕
    isLoading: false // 是否正在请求
  },
  getters: {
    allConversation: state => state.allConversation,
    // 当前聊天对象的ID
    toAccount: state => {
      if (state.currentConversationID.indexOf('C2C') === 0) {
        return state.currentConversationID.substring(3)
      } else if (state.currentConversationID.indexOf('GROUP') === 0) {
        return state.currentConversationID.substring(5)
      }
    },
    // 当前聊天对象的昵称
    toName: state => {
      if (state.currentConversation.type === 'C2C') {
        return state.currentConversation.userProfile.userID
      } else if (state.currentConversation.type === 'GROUP') {
        return state.currentConversation.groupProfile.name
      }
    },
    // 当前聊天对话的Type
    currentConversationType: state => {
      if (state.currentConversationID.indexOf('C2C') === 0) {
        return 'C2C'
      }
      if (state.currentConversationID.indexOf('GROUP') === 0) {
        return 'GROUP'
      }
      return ''
    },
    currentConversation: state => state.currentConversation,
    currentMessageList: state => state.currentMessageList,
    imageUrls: state => state.imageUrls
  },
  mutations: {
    // 历史头插消息列表
    unshiftMessageList (state, messageList) {
      let list = [...messageList]
      let urls = []
      for (let i = 0; i < list.length; i++) {
        let message = list[i]
        list[i].virtualDom = decodeElement(message.elements[0])
        if (message.type === 'TIMImageElem') {
          let url = message.payload.imageInfoArray[1].url
          url = url.slice(0, 2) === '//' ? `https:${url}` : url
          urls.push(url)
        }
        let date = new Date(message.time * 1000)
        list[i].newtime = formatTime(date)
      }
      state.imageUrls = [...urls, ...state.imageUrls]
      state.currentMessageList = [...list, ...state.currentMessageList]
    },
    // 收到
    receiveMessage (state, messageList) {
      let list = [...messageList]
      let urls = []
      for (let i = 0; i < list.length; i++) {
        let item = list[i]
        list[i].virtualDom = decodeElement(item.elements[0])
        let date = new Date(item.time * 1000)
        list[i].newtime = formatTime(date)
        if (item.type === 'TIMImageElem') {
          let url = item.elements[0].content.imageInfoArray[1].url
          url = url.slice(0, 2) === '//' ? `https:${url}` : url
          urls.push(url)
        }
      }
      state.imageUrls = [...state.imageUrls, ...urls]
      state.currentMessageList = [...state.currentMessageList, ...list]
      setTimeout(() => {
        wx.pageScrollTo({
          scrollTop: 99999
        })
      }, 800)
    },
    sendMessage (state, message) {
      message.virtualDom = decodeElement(message.elements[0])
      let date = new Date(message.time * 1000)
      message.newtime = formatTime(date)
      if (message.type === 'TIMImageElem') {
        let url = message.payload.imageInfoArray[1].url
        url = url.slice(0, 2) === '//' ? `https:${url}` : url
        state.imageUrls.push(url)
      }
      state.currentMessageList.push(message)
      setTimeout(() => {
        wx.pageScrollTo({
          scrollTop: 99999
        })
      }, 800)
    },
    // 更新当前的会话
    updateCurrentConversation (state, conversation) {
      state.currentConversation = conversation
      state.currentConversationID = conversation.conversationID
    },
    // 更新当前所有会话列表
    updateAllConversation (state, list) {
      for (let i = 0; i < list.length; i++) {
        if (list[i].lastMessage && (typeof list[i].lastMessage.lastTime === 'number')) {
          let date = new Date(list[i].lastMessage.lastTime * 1000)
          list[i].lastMessage._lastTime = formatTime(date)
        }
      }
      state.allConversation = list
    },
    // 重置当前会话
    resetCurrentConversation (state) {
      state.currentConversationID = '' // 当前聊天对话ID
      state.currentConversation = {} // 当前聊天对话信息
      state.currentMessageList = [] // 当前聊天消息列表
      state.nextReqMessageID = '' // 下一条消息标志
      state.imageUrls = [] // 当前会话中已加载信息所有的图片链接
      state.isCompleted = false // 当前会话消息是否已经请求完毕
      state.isLoading = false // 是否正在请求
    },
    resetAllConversation (state) {
      state.allConversation = []
    },
    removeMessage (state, message) {
      state.currentMessageList.splice(state.currentMessageList.findIndex(item => item.ID === message.ID), 1)
    },
    changeMessageStatus (state, index) {
      state.currentMessageList[index].status = 'fail'
    },
    offAtRemind (state, conversation) {
      let item = state.allConversation.filter(item => item.conversationID === conversation.conversationID)[0]
      item.lastMessage.at = false
    }
  },
  actions: {
    // 消息事件
    onMessageEvent (context, event) {
      let messageList = event.data
      const atTextMessageList = messageList.filter(
        message =>
          message.type === 'TIMTextElem' &&
          message.payload.text.includes('@')
      )
      for (let i = 0; i < atTextMessageList.length; i++) {
        const message = atTextMessageList[i]
        const matched = message.payload.text.match(/@\w+/g)
        if (!matched) {
          continue
        }
        // @ 我的
        if (matched.includes(`@${context.getters.myInfo.userID}`)) {
          // TODO: notification
          context.state.allConversation.filter((item) => {
            if (item.conversationID === message.conversationID) {
              item.lastMessage.at = true
            }
          })
        }
      }
      if (event.name === 'onMessageReceived') {
        let id = context.state.currentConversationID
        if (!id) {
          return
        }
        let list = []
        event.data.forEach(item => {
          if (item.conversationID === id) {
            list.push(item)
          }
        })
        context.commit('receiveMessage', list)
      }
    },
    // 获取消息列表
    getMessageList (context) {
      const {currentConversationID, nextReqMessageID} = context.state
      // 判断是否拉完了
      if (!context.state.isCompleted) {
        if (!context.state.isLoading) {
          context.state.isLoading = true
          wx.$app.getMessageList({ conversationID: currentConversationID, nextReqMessageID: nextReqMessageID, count: 15 }).then(res => {
            context.state.nextReqMessageID = res.data.nextReqMessageID
            context.commit('unshiftMessageList', res.data.messageList)
            if (res.data.isCompleted) {
              context.state.isCompleted = true
              wx.showToast({
                title: '更新成功',
                icon: 'none',
                duration: 1500
              })
            }
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

export default conversationModules
