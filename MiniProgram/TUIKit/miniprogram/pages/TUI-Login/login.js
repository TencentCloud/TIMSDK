import { setTokenStorage } from '../../utils/token'
import logger from '../../utils/logger'
import { genTestUserSig } from '../../debug/GenerateTestUserSig'

const app = getApp()
Page({
  data: {
    userID: '',
    hidden: false,
    privateAgree: false,
    code: '',
    path: '',
    lastTime: 0,
    countryIndicatorStatus: false,
    headerHeight: app.globalData.headerHeight,
    statusBarHeight: app.globalData.statusBarHeight,
  },
  onLoad(option) {
    this.setData({
      path: option.path,
    })
    wx.setStorage({
      key: 'path',
      data: option.path,
    })
  },

  onShow() {
  },

  loginWithToken() {
    wx.switchTab({
      url: '../TUI-Index/index',
    })
  },
  onBack() {
    wx.navigateTo({
      url: '../TUI-Index/TUI-Index',
    })
  },
  // 输入userID
  bindUserIDInput(e) {
    const val = e.detail.value
    this.setData({
      userID: val,
    })
  },
  login() {
    const userID = this.data.userID
    const userSig = genTestUserSig(userID).userSig
    logger.log(`TUI-login | login  | userSig:${userSig} userID:${userID}`)
    app.globalData.userInfo = {
      userSig,
      userID,
    }
    setTokenStorage({
      userInfo: app.globalData.userInfo,
    })
    if (this.data.path && this.data.path !== 'undefined') {
      wx.redirectTo({
        url: this.data.path,
      })
    } else {
      wx.switchTab({
        url: '../TUI-Index/index',
      })
    }
  },
  onAgreePrivateProtocol() {
    this.setData({
      privateAgree: !this.data.privateAgree,
    })
  },

  linkToPrivacyTreaty() {
    const url = 'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html'
    wx.navigateTo({
      url: `../TUI-User-Center/webview/webview?url=${url}&nav=Privacy-Protection`,
    })
  },

  linkToUserAgreement() {
    const url = 'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html'
    wx.navigateTo({
      url: `../TUI-User-Center/webview/webview?url=${url}&nav=User-Agreement`,
    })
  },
})
