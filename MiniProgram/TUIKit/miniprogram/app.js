import TIM from './static/tim-wx'
import TIMUploadPlugin from './static/tim-upload-plugin'
import logger from './utils/logger'
import { SDKAPPID } from './debug/GenerateTestUserSig'
// app.js
App({
  onLaunch() {
    wx.setStorageSync('islogin', false)
    wx.$TUIKit = TIM.create({ SDKAppID: this.globalData.SDKAppID })
    wx.$TUIKit.registerPlugin({ 'tim-upload-plugin': TIMUploadPlugin })
    wx.$TUIKitTIM = TIM
    wx.$TUIKitEvent = TIM.EVENT
    wx.$TUIKitVersion = TIM.VERSION
    wx.$TUIKitTypes = TIM.TYPES
    // 监听系统级事件
    wx.$TUIKit.on(wx.$TUIKitEvent.SDK_NOT_READY, this.onSdkNotReady)
    wx.$TUIKit.on(wx.$TUIKitEvent.KICKED_OUT, this.onKickedOut)
    wx.$TUIKit.on(wx.$TUIKitEvent.ERROR, this.onTIMError)
    wx.$TUIKit.on(wx.$TUIKitEvent.NET_STATE_CHANGE, this.onNetStateChange)
    wx.$TUIKit.on(wx.$TUIKitEvent.SDK_RELOAD, this.onSDKReload)
    wx.$TUIKit.on(wx.$TUIKitEvent.SDK_READY, this.onSDKReady)
  },


  onShow() {
    wx.setKeepScreenOn({
      keepScreenOn: true,
    })
  },
  // TODO:
  resetLoginData() {
    this.globalData.expiresIn = ''
    this.globalData.sessionID = ''
    this.globalData.userInfo = {
      userID: '',
      userSig: '',
      token: '',
      phone: '',
    }
    this.globalData.userProfile = null
    logger.log(`| app |  resetLoginData | globalData: ${this.globalData}`)
  },
  globalData: {
    // userInfo: userID userSig token phone
    userInfo: null,
    // 个人信息
    userProfile: null,
    headerHeight: 0,
    statusBarHeight: 0,
    SDKAppID: SDKAPPID,
  },
  onSDKReady() {

  },
  onSdkNotReady() {

  },

  onKickedOut() {
    wx.showToast({
      title: '您被踢下线',
      icon: 'error',
    })
    wx.navigateTo({
      url: './pages/TUI-Login/login',
    })
  },

  onTIMError() {
  },

  onNetStateChange() {

  },

  onSDKReload() {

  },
})
