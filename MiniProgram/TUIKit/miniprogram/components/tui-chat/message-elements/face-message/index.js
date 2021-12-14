// eslint-disable-next-line no-undef
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    message: {
      type: Object,
      value: {},
      observer(newVal) {
        this.setData({
          renderDom: this.parseFace(newVal),
        });
      },
    },
    isMine: {
      type: Boolean,
      value: true,
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    renderDom: [],
    percent: 0,
    faceUrl: 'https://web.sdk.qcloud.com/im/assets/face-elem/',
  },

  /**
   * 组件的方法列表
   */
  methods: {
    // 解析face 消息
    parseFace(message) {
      const renderDom = {
        src: `${this.data.faceUrl + message.payload.data}@2x.png`,
      };
      return renderDom;
    },

    previewImage() {
      wx.previewImage({
        current: this.data.renderDom[0].src, // 当前显示图片的http链接
        urls: [this.data.renderDom[0].src],
      });
    },
  },
});
