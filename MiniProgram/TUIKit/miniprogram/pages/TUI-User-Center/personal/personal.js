// miniprogram/pages/TUI-personal/personal.js'
// eslint-disable-next-line no-undef
const app = getApp();
// eslint-disable-next-line no-undef
Page({

  /**
   * 页面的初始数据
   */
  data: {
    userInfo: {
      avatarUrl: '',
    },
    config: {
      avatar: '',
      nick: '',
      phone: '',
      token: '',
      userId: '',
      userSig: '',
    },
    nick: '',
    avatar: '',
    avatarList: [
      { avatarname: '头像1', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_01.png' },
      { avatarname: '头像2', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_02.png' },
      { avatarname: '头像3', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_03.png' },
      { avatarname: '头像4', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_04.png' },
      { avatarname: '头像5', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_05.png' },
      { avatarname: '头像6', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_06.png' },
      { avatarname: '头像7', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_07.png' },
      { avatarname: '头像8', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_08.png' },
      { avatarname: '头像9', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_09.png' },
      { avatarname: '头像10', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_10.png' },
      { avatarname: '头像11', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_11.png' },
      { avatarname: '头像12', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_12.png' },
      { avatarname: '头像13', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_13.png' },
      { avatarname: '头像14', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_14.png' },
      { avatarname: '头像15', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_15.png' },
      { avatarname: '头像16', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_16.png' },
      { avatarname: '头像17', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_17.png' },
      { avatarname: '头像18', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_18.png' },
      { avatarname: '头像19', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_19.png' },
      { avatarname: '头像20', URL: 'https://web.sdk.qcloud.com/component/TUIKit/assets/avatar_20.png' },
    ],
    popupToggle: false,
    popupToggleAvatar: false,
    imageSelected: false,
    imageTitle: '点击操作',

  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    this.setData({
      userInfo: app.globalData.userProfile,
    });
    wx.setNavigationBarTitle({
      title: '个人中心',
    });
  },

  bindEditInput(e) {
    const val = e.detail.value;
    this.setData({
      nick: val ? val : '',
    });
  },

  // 修改昵称确认
  handleEditSubmit() {
    const { nick } = this.data;
    if (nick === app.globalData.userProfile.nick) {
      return;
    }
    this.setData({
      popupToggle: false,
    });
    const promise = wx.$TUIKit.updateMyProfile({
      nick: this.data.nick,
    });
    promise.then((imResponse) => {
      this.setData({
        userInfo: imResponse.data,
        popupToggle: false,
      });
    }).catch((imError) => {
      this.setData({
        popupToggle: false,
      });
      console.warn('updateMyProfile error:', imError); // 更新资料失败的相关信息
    });
  },

  handleEditToggle() {
    this.setData({
      popupToggle: !this.data.popupToggle,
      nick: this.data.userInfo.nick,
    });
  },

  // 修改昵称 禁止冒泡
  handleCatchTap() {
    return;
  },

  // 修改头像
  changeAvatar() {
    this.setData({
      popupToggleAvatar: true,
    });
  },

  click(e) {
    this.setData({
      avatar: e.currentTarget.dataset.value.URL,
    });
  },
  // 修改头像确认
  handleEditSubmitAvatar() {
    wx.$TUIKit.updateMyProfile({
      avatar: this.data.avatar,
    }).then((imResponse) => {
      this.setData({
        userInfo: imResponse.data,
        popupToggleAvatar: !this.data.popupToggleAvatar,
      });
    })
      .catch(() => {
        this.setData({
          popupToggleAvatar: !this.data.popupToggleAvatar,
        });
      });
  },
  handleEditToggleAvatar() {
    this.setData({
      popupToggleAvatar: !this.data.popupToggleAvatar,
      avatar: this.data.avatar,
    });
  },

});
