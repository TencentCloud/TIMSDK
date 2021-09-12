// pages/about/create.js
Page({
  /**
   * 页面的初始数据
   */
  data: {
    list: [
      {
        name: 'SDK版本',
        value: wx.$TUIKitVersion,
      },
    ],
  },
  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    wx.setNavigationBarTitle({
      title: '关于',
    })
  },
  onBack() {
    wx.navigateBack({
      delta: 1,
    })
  },
})
