const app = getApp()
Page({

  /**
   * 页面的初始数据
   */
  data: {
    userID: '',
    searchUser: {},
    userInfo: {
    },
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    this.setData({
      userInfo: app.globalData.userInfo,
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
  goBack() {
    wx.navigateBack({
      delta: 1,
    })
  },
  userIDInput(e) {
    this.setData({
      userID: e.detail.value,
      searchUser: {},
    })
  },
  getuserProfile() {
    wx.$TUIKit.getUserProfile({
      userIDList: [this.data.userID],
    }).then((imRes) => {
      if (imRes.data.length > 0) {
        this.setData({
          searchUser: imRes.data[0],
        })
      } else {
        wx.showToast({
          title: '用户不存在',
          icon: 'error',
        })
        this.setData({
          userID: '',
        })
      }
    })
  },
  handleChoose() {
    this.data.searchUser.isChoose = !this.data.searchUser.isChoose
    this.setData({
      searchUser: this.data.searchUser,
    })
  },
  bindConfirmInvite() {
    if (this.data.searchUser.isChoose) {
      wx.navigateTo({
        url: `../../TUI-Chat/chat?conversationID=C2C${this.data.searchUser.userID}`,
      })
    } else {
      wx.showToast({
        title: '请选择相关用户',
        icon: 'none',
      })
    }
  },
})
