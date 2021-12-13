import { parseImage } from '../../../base/message-facade';
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
          renderDom: parseImage(newVal),
          percent: newVal.percent,
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
    showSave: false,
  },

  /**
   * 组件的方法列表
   */
  methods: {
    previewImage() {
      wx.previewImage({
        current: this.data.renderDom[0].src, // 当前显示图片的http链接
        urls: [this.data.renderDom[0].src],
        success: () => {
          this.setData({
            showSave: true,
          });
        },
        complete: () => {
          this.setData({
            showSave: false,
          });
        },
      });
    },
  },
});
