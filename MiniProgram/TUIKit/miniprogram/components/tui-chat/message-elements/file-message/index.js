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
          filePayload: newVal.payload,
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
    Show: false,
    filePayload: {},
  },

  /**
   * 组件的方法列表
   */
  methods: {
    download() {
      this.setData({
        Show: true,
      });
    },
    downloadConfirm() {
      wx.downloadFile({
        url: this.data.filePayload.fileUrl,
        success(res) {
          const filePath = res.tempFilePath;
          wx.openDocument({
            filePath,
            success() {
            },
          });
        },
      });
    },
    cancel() {
      this.setData({
        Show: false,
      });
    },
  },
});
