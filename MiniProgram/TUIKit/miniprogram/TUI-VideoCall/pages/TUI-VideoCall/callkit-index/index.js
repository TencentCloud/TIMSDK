// room.js
// eslint-disable-next-line no-undef
Page({
  data: {
    entryInfos: [
      { icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/audio-card.png', title: '语音通话', desc: '丢包率70%仍可正常语音通话', navigateTo: '../callkit-room/room?type=1' },
      { icon: 'https://web.sdk.qcloud.com/component/miniApp/resources/video-card.png', title: '视频通话', desc: '丢包率50%仍可正常视频通话', navigateTo: '../callkit-room/room?type=2' },
    ],
  },

  onLoad() {

  },
  handleEntry(e) {
    const url = this.data.entryInfos[e.currentTarget.id].navigateTo;
    wx.navigateTo({
      url,
    });
  },

  onShow() {

  },
  // 返回
  onBack() {
    wx.navigateBack({
      delta: 1,
    });
  },
});
