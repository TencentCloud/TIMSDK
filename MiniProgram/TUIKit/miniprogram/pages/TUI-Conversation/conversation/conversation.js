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
    index: Number,
    unreadCount: 0,
    conversationInfomation: {},
    transChenckID: '',
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    // 登入后拉去会话列表
    wx.$TUIKit.on(wx.$TUIKitEvent.CONVERSATION_LIST_UPDATED, this.onConversationListUpdated, this)
    this.getConversationList()
  },
  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {
    wx.$TUIKit.off(wx.$TUIKitEvent.CONVERSATION_LIST_UPDATED, this.onConversationListUpdated)
  },
  // 跳转到子组件需要的参数
  handleRoute(event) {
    const flagIndex = this.data.conversationList.findIndex(item => item.conversationID === event.currentTarget.id)
    this.setData({
      index: flagIndex,
    })
    this.getConversationList()
    this.data.conversationInfomation = { conversationID: event.currentTarget.id,
      unreadCount: this.data.conversationList[this.data.index].unreadCount }
    const url = `../../TUI-Chat/chat?conversationInfomation=${JSON.stringify(this.data.conversationInfomation)}`
    wx.navigateTo({
      url,
    })
  },
  // 更新会话列表
  onConversationListUpdated(event) {
    logger.log('| TUI-conversation | onConversationListUpdated | ok')
    this.setData({
      conversationList: event.data,
    })
  },
  // 获取会话列表
  getConversationList() {
    wx.$TUIKit.getConversationList().then((imResponse) => {
      logger.log(`| TUI-conversation | getConversationList | getConversationList-length: ${imResponse.data.conversationList.length}`)
      this.setData({
        conversationList: imResponse.data.conversationList,
      })
    })
  },
  // 展示发起会话/发起群聊/加入群聊
  showSelectedTag() {
    this.setData({
      showSelectTag: !this.data.showSelectTag,
    })
  },
  // 了解更多链接
  learnMore() {
    wx.navigateTo({
      url: '../../TUI-User-Center/webview/webview?url=https://cloud.tencent.com/product/im',
    })
  },
  // 点击事件跳转
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
  // 返回主页
  goHomePage() {
    // wx.navigateTo 不能跳转到 tabbar 页面，使用 wx.switchTab 代替
    wx.switchTab({
      url: '../../TUI-Index/index',
    })
  },
  // 点击空白区域关闭showMore弹窗
  handleEditToggle() {
    this.setData({
      showSelectTag: false,
    })
  },
  // 跳转事件路径
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
  transCheckID(event) {
    this.setData({
      transChenckID: event.detail.checkID,
    })
  },
})
