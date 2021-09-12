import logger from '../../../utils/logger'

Page({

  /**
   * 页面的初始数据
   */
  data: {
    groupID: '',
    searchGroup: {},
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {

  },

  /**
   * 生命周期函数--监听页面初次渲染完成
   */
  onReady() {

  },

  /**
   * 生命周期函数--监听页面显示
   */
  onShow() {

  },

  /**
   * 生命周期函数--监听页面隐藏
   */
  onHide() {

  },

  /**
   * 生命周期函数--监听页面卸载
   */
  onUnload() {

  },

  /**
   * 页面相关事件处理函数--监听用户下拉动作
   */
  onPullDownRefresh() {

  },

  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom() {

  },

  /**
   * 用户点击右上角分享
   */
  onShareAppMessage() {

  },
  goBack() {
    wx.navigateBack({
      delta: 1,
    })
  },
  groupIDInput(e) {
    this.setData({
      groupID: e.detail.value,
    })
  },
  searchGroupByID() {
    wx.$TUIKit.searchGroupByID(this.data.groupID)
      .then((imResponse) => {
        if (imResponse.data.group.groupID !== '') {
          this.setData({
            searchGroup: imResponse.data.group,
          })
        }
      })
      .catch((imError) => {
        wx.hideLoading()
        if (imError.code === 10007) {
          wx.showToast({
            title: '讨论组类型群不允许申请加群',
            icon: 'none',
          })
        } else {
          wx.showToast({
            title: '未找到该群组',
            icon: 'none',
          })
        }
      })
  },
  handleChoose() {
    this.data.searchGroup.isChoose = !this.data.searchGroup.isChoose
    this.setData({
      searchGroup: this.data.searchGroup,
    })
  },
  bindConfirmJoin() {
    logger.log(`TUI-Group | join-group | bindConfirmJoin | groupID: ${this.data.groupID}`)
    wx.$TUIKit.joinGroup({ groupID: this.data.groupID, type: this.data.searchGroup.type })
      .then((imResponse) => {
        switch (imResponse.data.status) {
          case wx.$TUIKitTIM.TYPES.JOIN_STATUS_WAIT_APPROVAL: // 等待管理员同意
            break
          case wx.$TUIKitTIM.TYPES.JOIN_STATUS_SUCCESS: // 加群成功
            console.log(imResponse.data.group) // 加入的群组资料
            break
          case wx.$TUIKitTIM.TYPES.JOIN_STATUS_ALREADY_IN_GROUP: // 已经在群中
            break
          default:
            break
        }
      })
      .catch((imError) => {
        console.warn('joinGroup error:', imError) // 申请加群失败的相关信息
      })
    if (this.data.searchGroup.isChoose) {
      wx.navigateTo({
        url: `../../TUI-Chat/chat?conversationID=GROUP${this.data.searchGroup.groupID}`,
      })
    } else {
      wx.showToast({
        title: '请选择相关群聊',
        icon: 'error',
      })
    }
  },
})
