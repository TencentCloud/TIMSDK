import logger from '../../../utils/logger'

Page({

  /**
   * 页面的初始数据
   */
  data: {
    conversationList: [],
    showSelectTag: false,
    array: [
      { name: '发起会话' },
      { name: '发起群聊' },
      { name: '加入群聊' },
    ],
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    // 登入后拉去会话列表
    this.getConversationList()
    wx.$TUIKit.on(wx.$TUIKitEvent.CONVERSATION_LIST_UPDATED, this.onConversationListUpdated, this)
  },
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {
    wx.$TUIKit.off(wx.$TUIKitEvent.SDK_READY, this.onConversationListUpdated)
  },

  handleRoute(event) {
    const url = `../../TUI-Chat/chat?conversationID=${event.currentTarget.id}`
    wx.navigateTo({
      url,
    })
  },
  onConversationListUpdated(event) {
    logger.log('TUI-conversation | onConversationListUpdated  |ok')
    this.setData({
      conversationList: event.data,
    })
  },
  getConversationList() {
    wx.$TUIKit.getConversationList().then((imResponse) => {
      logger.log(`TUI-conversation | getConversationList | getConversationList-length: ${imResponse.data.conversationList.length}`)
      this.setData({
        conversationList: imResponse.data.conversationList,
      })
    })
  },
  showMore() {
    this.setData({
      showSelectTag: !this.data.showSelectTag,
    })
  },
  learnMore() {
    wx.navigateTo({
      url: '../../TUI-User-Center/webview/webview?url=https://cloud.tencent.com/product/im',
    })
  },
  handleOnTap(event) {
    this.setData({
      showSelectTag: false,
    }, () => {
      switch (event.currentTarget.dataset.name) {
        case '发起会话':
          this.$createConversation()
          break
        case '发起群聊':
          this.$createGroup()
          break
        case '加入群聊':
          this.$joinGroup()
        default:
          break
      }
    })
  },

  goHomePage() {
    // wx.navigateTo 不能跳转到 tabbar 页面，使用 wx.switchTab 代替
    wx.switchTab({
      url: '../../TUI-Index/index',
    })
  },
  handleEditToggle() {
    this.setData({
      showSelectTag: false,
    })
  },
  $createConversation() {
    wx.navigateTo({
      url: '../create-conversation/create',
    })
  },
  $createGroup() {
    wx.navigateTo({
      url: '../../TUI-Group/create-group/create',
    })
  },
  $joinGroup() {
    wx.navigateTo({
      url: '../../TUI-Group/join-group/join',
    })
  },
})
