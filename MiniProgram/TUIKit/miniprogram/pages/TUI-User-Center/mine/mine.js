import logger from '../../../utils/logger'
const app = getApp()
Page({
  data: {
    // 页面初始信息
    userListInfo: [
      { extra: 1, name: '隐私条例', path: 'https://web.sdk.qcloud.com/document/Tencent-IM-Privacy-Protection-Guidelines.html', nav: 'Privacy-Protection', iconUrl: '../../../static/assets/Privacyregulations.svg' },
      { extra: 1, name: '用户协议', path: 'https://web.sdk.qcloud.com/document/Tencent-IM-User-Agreement.html', nav: 'User-Agreement', iconUrl: '../../../static/assets/Useragreement.svg' },
      { extra: 3, name: '免责声明', iconUrl: '../../../static/assets/Disclaimers.svg' },
      { extra: 2, name: '关于', url: '../about/about', iconUrl: '../../../static/assets/about.svg' },
      { extra: 1, name: '联系我们', path: 'https://cloud.tencent.com/document/product/269/20043', iconUrl: '../../../static/assets/contact.svg' },
    ],
    config: {
      nick: '',
      userID: '',

    },
    hasname: true,
  },
  onload() {
  },
  onShow() {
    wx.$TUIKit.getMyProfile()
      .then((imResponse) => {
        this.setData({
          config: imResponse.data,
        })
        app.globalData.userProfile = imResponse.data
        if (imResponse.data.nick) {
          this.setData({
            hasname: false,
          })
        }
      })
      .catch((imError) => {
        console.warn('getMyProfile error:', imError) // 获取个人资料失败的相关信息
      })
  },
  personal() {
    // TUIKit xxxx | mine | personal | xxxx
    wx.navigateTo({
      url: '../personal/personal',
    })
  },
  quit() {
    // TUIKit xxxx | mine | quit | xxxx
    logger.log('| TUI-User-Center | mine  | quit-logout ')
    wx.$TUIKit.logout().then(() => {
      wx.clearStorage()
      app.resetLoginData()
      wx.redirectTo({ url: '../../TUI-Login/login',
        success: () => {
          wx.showToast({
            title: '退出成功',
            icon: 'none',
          })
        },
      })
    })
  },


  handleRouter(event) {
    const data = event.currentTarget.dataset.item
    if (data.url) {
      wx.navigateTo({ url: `${data.url}` })
    } else if (data.name === '免责声明') {
      this.setData({
        popupToggle: true,
      })
    } else {
      wx.navigateTo({
        url: `../webview/webview?url=${data.path}&nav=${data.nav}`,
      })
    }
  },
  Agree() {
    this.setData({
      popupToggle: false,
    })
  },
})
