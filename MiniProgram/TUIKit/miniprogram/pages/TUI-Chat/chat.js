import logger from '../../utils/logger'

Page({

  /**
   * 页面的初始数据
   */
  data: {
    conversationName: '',
    conversation: {},
    messageList: [],
    isShow: false,
    showChat: true,
    conversationID: '',
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    // conversationID: C2C、 GROUP
    logger.log(` TUI-chat | onLoad | conversationID: ${options.conversationID}`)
    const { conversationID } = options
    this.setData({
      conversationID,
    })
    wx.$TUIKit.setMessageRead({ conversationID }).then(() => {
      logger.log('TUI-chat | setMessageRead  | ok')
    })
    wx.$TUIKit.getConversationProfile(conversationID).then((res) => {
      const { conversation } = res.data
      this.setData({
        conversationName: this.getConversationName(conversation),
        conversation,
        isShow: conversation.type === 'GROUP',
      })
    })
  },
  getConversationName(conversation) {
    if (conversation.type === '@TIM#SYSTEM') {
      this.setData({
        showChat: false,
      })
      return '系统通知'
    }
    if (conversation.type === 'C2C') {
      return conversation.remark || conversation.userProfile.nick || conversation.userProfile.userID
    }
    if (conversation.type === 'GROUP') {
      return conversation.groupProfile.name || conversation.groupProfile.groupID
    }
  },

  sendMessage(event) {
    // 将自己发送的消息写进消息列表里面
    this.selectComponent('#message-list').updateMessageList(event.detail.message)
  },
  triggerClose() {
    this.selectComponent('#message-input').handleClose()
  },
  handleCall(event) {
    this.selectComponent('#tui-calling').handleCall(event.detail)
  },
  goBack() {
    const pages = getCurrentPages() // 当前页面栈
    if (pages[pages.length - 2].route === 'pages/TUI-Conversation/create-conversation/create'
      || pages[pages.length - 2].route === 'pages/TUI-Group/create-group/create'
      || pages[pages.length - 2].route === 'pages/TUI-Group/join-group/join') {
      wx.navigateBack({
        delta: 2,
      })
    } else {
      wx.navigateBack({
        delta: 1,

      })
    }
    wx.$TUIKit.setMessageRead({
      conversationID: this.data.conversationID,
    }).then(() => {})
  },
})
