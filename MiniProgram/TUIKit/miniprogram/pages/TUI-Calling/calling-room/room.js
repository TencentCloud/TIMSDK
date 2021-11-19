const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    localUserInfo: null,
    remoteUserInfo: {},
    config: {
      sdkAppID: app.globalData.SDKAppID,
      userID: app.globalData.userID,
      userSig: app.globalData.userSig,
      type: 1,
      tim: null,
    },
    userID: '',
    title: '视频通话',
    searchResultShow: false,
    country: '86',
    params: {
      type: '1',
    },
  },


  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    const { config } = this.data
    config.sdkAppID = app.globalData.SDKAppID
    config.userID = app.globalData.userInfo.userID
    config.userSig = app.globalData.userInfo.userSig
    config.phone = app.globalData.phone
    config.type = Number(options.type)
    config.tim = wx.$TUIKit

    this.setData({
      params: { ...this.data.params, ...options },
      title: config.type === 1 ? '语音通话' : '视频通话',
      config,
    }, () => {
      this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
      this.TRTCCalling.init()
    })
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
    this.TRTCCalling.destroyed()
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

  call() {
    if (this.data.config.userID === this.data.remoteUserInfo.userID) {
      wx.showToast({
        title: '不可呼叫本机',
      })
      return
    }
    console.log(this.data.remoteUserInfo)
    this.TRTCCalling.call({ userID: this.data.remoteUserInfo.userID, type: ~~this.data.params.type })
  },

  // 搜索input
  userIDToSearchInput(e) {
    if (!e.detail.value) {
      this.data.searchResultShow = false
    }
    this.setData({
      searchResultShow: this.data.searchResultShow,
      userID: e.detail.value,
    })
  },

  // 搜素
  searchUser() {
    if (!this.data.userID) {
      return
    }

    wx.$TUIKit.getUserProfile({ userIDList: [this.data.userID] }).then((imResponse) => {
      this.setData({
        remoteUserInfo: { ...imResponse.data[0] },
        searchResultShow: true,
      })
    })
  },
  // 返回
  onBack() {
    wx.navigateBack({
      delta: 1,
    })
    this.TRTCCalling.destroyed()
  },
  // 图像解析不出来的缺省图设置
  handleErrorImage() {
    const { remoteUserInfo } = this.data
    remoteUserInfo.avatar = 'https://web.sdk.qcloud.com/component/miniApp/resources/avatar2_100.png'
    this.setData({
      remoteUserInfo,
    })
  },
})
