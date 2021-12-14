// pages/about/create.js
// eslint-disable-next-line no-undef
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
      {
        name: '注销账户',
        path: '../cancel/cancel',
      },
    ],
  },
  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    wx.setNavigationBarTitle({
      title: '关于',
    });
  },
  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },
  /**
   * 路由跳转
   */
  handleRouter(event) {
    const data = event.currentTarget.dataset.item;
    if (data.name === '注销账户') {
      wx.navigateTo({
        url: '../cancel/cancel',
      });
    }
  },
});
