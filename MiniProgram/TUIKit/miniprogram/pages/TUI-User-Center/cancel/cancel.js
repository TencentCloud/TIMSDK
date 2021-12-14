// miniprogram/pages/cancelaton/cancel.js
import { cancellation } from '../../../utils/api';
import logger from '../../../utils/logger';
// eslint-disable-next-line no-undef
const app = getApp();
// eslint-disable-next-line no-undef
Page({

  /**
   * 页面的初始数据
   */
  data: {
    userInfo: {
    },
    phone: '',
  },
  /**
   * 生命周期函数--监听页面加载
   */
  onLoad() {
    this.setData({
      userInfo: app.globalData.userProfile,
      phone: app.globalData.userInfo.phone,
    });
    wx.setNavigationBarTitle({
      title: '注销账户',
    });
  },


  handleCancellation() {
    this.setData({
      toggle: true,
    });
  },
  close() {
    this.setData({
      toggle: false,
    });
  },
  submit() {
    logger.log('| TUI-User-Center | cancel | logout-cancellation');
    wx.$TUIKit.logout().then(() => {
      cancellation({}, (res) => {
        logger.log('| TUI-User-Center | cancel | cancellation | ok');
        if (res.data.errorCode === 0) {
          wx.getStorage({
            key: 'path',
            complete: () => {
              wx.clearStorage();
              app.resetLoginData();
              wx.redirectTo({ url: '../../TUI-Login/login',
                success: () => {
                  wx.showToast({
                    title: ' 注销成功',
                    icon: 'none',
                  });
                } });
              this.close();
            },
          });
        }
      });
    });
  },
});


