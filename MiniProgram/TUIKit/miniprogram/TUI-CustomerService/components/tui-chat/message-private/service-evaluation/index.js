import constant from '../../../../utils/constant';

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
    displayTag: false,
    scoreList: [1, 2, 3, 4, 5],
    score: 5,
    comment: '',
  },

  /**
   * 组件的方法列表
   */
  methods: {
    handleClose() {
      this.triggerEvent('close', {
        key: '2',
      });
    },
    handleScore(e) {
      let { score } = e.currentTarget.dataset;
      if (score === this.data.score) {
        score = 0;
      }
      this.setData({
        score,
      });
    },
    bindTextAreaInput(e) {
      this.setData({
        comment: e.detail.value,
      });
    },
    sendMessage() {
      const { businessID_text, STRING_TEXT, FEAT_NATIVE_CODE } = constant;
      this.triggerEvent('sendCustomMessage', {
        payload: {
          // data 字段作为表示，可以自定义
          data: JSON.stringify({
            businessID: businessID_text.typeEvaluation,
            version: FEAT_NATIVE_CODE.NATIVE_VERSION,
            score: this.data.score,
            comment: this.data.comment,
          }),
          description: STRING_TEXT.TYPETEXT, // 获取骰子点数
          extension: STRING_TEXT.TYPETEXT,
        },
      });

      this.setData({
        score: 0,
        comment: '',
      });
      this.handleClose();
    },
  },

  pageLifetimes: {
    show() {
      this.setData({
        score: 0,
        comment: '',
      });
    },
  },
});
