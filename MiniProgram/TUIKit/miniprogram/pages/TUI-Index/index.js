// miniprogram/pages/TUI-Index/TUI-create.js
import logger from '../../utils/logger'

const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    sceneList: [
      { name: '在线客服', url: '../TUI-Conversation/conversation/conversation', iconUrl: '../../static/assets/online-service.svg' },
      { name: '实时通话', url: '../TUI-Calling/calling-index/index', iconUrl: '../../static/assets/calling.svg' },
      { name: '互动直播', url: '', iconUrl: '../../static/assets/interactive-live.svg' },
    ],
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
  },
  onShow() {
    logger.log(`| TUI-Index | onshow  | login |userSig:${app.globalData.userInfo.userSig} userID:${app.globalData.userInfo.userID}`)
    wx.$TUIKit.login({
      userID: app.globalData.userInfo.userID,
      userSig: app.globalData.userInfo.userSig,
    }).then(() => {
    })
      .catch(() => {
      })
  },
  handleOnPageNavigate(event) {
    const tab = event.currentTarget.dataset.item
    if (!tab.url) {
      wx.navigateToMiniProgram({
        appId: 'wx3b91b7aaa809ecf9',
      })
    } else {
      wx.navigateTo({
        url: tab.url,
      })
    }
  },
  learnMore() {
    wx.navigateTo({
      url: '../TUI-User-Center/webview/webview?url=https://cloud.tencent.com/product/im',
    })
  },
})
