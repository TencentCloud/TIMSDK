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

    this.setData({
      params: { ...this.data.params, ...options },
      title: config.type === 1 ? '语音通话' : '视频通话',
      config,
    }, () => {
      this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
      this.bindTRTCCallingRoomEvent()
      this.TRTCCalling.login()
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
    // 取消监听事件
    this.unbindTRTCCallingRoomEvent()
    // 退出登录
    this.TRTCCalling.logout()
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

  invitedEvent() {
    wx.hideKeyboard()
  },

  hangupEvent() {},

  rejectEvent() {
    wx.showToast({
      title: '对方已拒绝',
    })
  },

  userLeaveEvent() {},

  onRespEvent() {
    wx.showToast({
      title: '对方不在线',
    })
    this.TRTCCalling.hangup()
  },

  callingTimeoutEvent() {
    wx.showToast({
      title: '无应答超时',
    })
  },

  lineBusyEvent() {
    wx.showToast({
      title: '对方忙线中',
    })
    this.TRTCCalling.hangup()
  },

  callingCancelEvent() {
    wx.showToast({
      title: '通话已取消',
    })
  },

  userEnterEvent() {},

  callEndEvent() {
    wx.showToast({
      title: '通话结束',
      duration: 800,
    })
    this.TRTCCalling.hangup()
  },

  bindTRTCCallingRoomEvent() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.on(TRTCCallingEvent.INVITED, this.invitedEvent)
    // 处理挂断的事件回调
    this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, this.hangupEvent)
    this.TRTCCalling.on(TRTCCallingEvent.REJECT, this.rejectEvent)
    this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
    this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, this.onRespEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
    this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
    this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
    this.TRTCCalling.on(TRTCCallingEvent.CALL_END, this.callEndEvent)
  },
  unbindTRTCCallingRoomEvent() {
    const TRTCCallingEvent = this.TRTCCalling.EVENT
    this.TRTCCalling.off(TRTCCallingEvent.INVITED, this.invitedEvent)
    this.TRTCCalling.off(TRTCCallingEvent.HANG_UP, this.hangupEvent)
    this.TRTCCalling.off(TRTCCallingEvent.REJECT, this.rejectEvent)
    this.TRTCCalling.off(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
    this.TRTCCalling.off(TRTCCallingEvent.NO_RESP, this.onRespEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
    this.TRTCCalling.off(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
    this.TRTCCalling.off(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
    this.TRTCCalling.off(TRTCCallingEvent.CALL_END, this.callEndEvent)
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
      console.log('获取getUserProfile', imResponse.data)
      this.setData({
        remoteUserInfo: { ...imResponse.data[0] },
        searchResultShow: true,
      }, () => {
        console.log('searchUser: remoteUserInfo:', this.data.remoteUserInfo)
      })
    })
      .catch(() => {
      })
  },
  // 返回
  onBack() {
    wx.navigateBack({
      delta: 1,
    })
    this.TRTCCalling.logout()
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
