const commonWordsList = [
  '什么时候发货',
  '发什么物流',
  '为什么物流一直没更新',
  '最新优惠',
  '包邮吗',
  '修改地址信息',
  '修改收件人信息',
  '物流一直显示正在揽收',
  '问题A',
  '问题B',
];

// eslint-disable-next-line no-undef
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    display: {
      type: Boolean,
      value: '',
      observer(newVal) {
        this.setData({
          displayTag: newVal,
        });
      },
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    displayTag: true,
    words: '',
    commonWordsMatch: commonWordsList,
  },

  /**
   * 组件的方法列表
   */
  methods: {
    handleClose() {
      this.triggerEvent('close', {
        key: '0',
      });
    },
    wordsInput(e) {
      this.data.commonWordsMatch = [],
      commonWordsList.forEach((item) => {
        if (item.indexOf(e.detail.value) > -1) {
          this.data.commonWordsMatch.push(item);
        }
      });
      this.setData({
        words: e.detail.value,
        commonWordsMatch: this.data.commonWordsMatch,
      });
    },
    sendMessage(e) {
      this.triggerEvent('sendMessage', {
        message: e.currentTarget.dataset.words,
      });
    },
  },
});
