// miniprogram/pages/TUI-Group/memberprofile-group/memberprofile.js
import logger from '../../../utils/logger';
// eslint-disable-next-line no-undef
Page({

  /**
   * 页面的初始数据
   */
  data: {
    personalProfile: {
    },
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    logger.log(`| TUI-Group | onLoad | personalProfile: ${JSON.parse(options.personalProfile)}`);
    this.setData({
      personalProfile: JSON.parse(options.personalProfile),
    });
  },
  // 回退
  goBack() {
    wx.navigateBack({
      delta: 1,
    });
  },
});
