import { emojiName, emojiUrl, emojiMap } from '../../../base/emojiMap';
// eslint-disable-next-line no-undef
Component({
  /**
   * 组件的属性列表
   */
  properties: {

  },

  /**
   * 组件的初始数据
   */
  data: {
    emojiList: [],
  },

  lifetimes: {
    attached() {
      for (let i = 0; i < emojiName.length; i++) {
        this.data.emojiList.push({
          emojiName: emojiName[i],
          url: emojiUrl + emojiMap[emojiName[i]],
        });
      }
      this.setData({
        emojiList: this.data.emojiList,
      });
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    handleEnterEmoji(event) {
      this.triggerEvent('enterEmoji', {
        message: event.currentTarget.dataset.name,
      });
    },
  },
});
