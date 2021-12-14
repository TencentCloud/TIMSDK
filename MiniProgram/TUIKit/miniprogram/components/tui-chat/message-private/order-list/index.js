const orderList = [
  {
    orderNum: 1,
    time: '2021-7-20 20:45',
    title: '[天博检验]新冠核酸检测/预约',
    description: '专业医学检测，电子报告',
    imageUrl: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/miles.jpeg',
    price: '80元',
  },
  {
    orderNum: 2,
    time: '2021-7-20 22:45',
    title: '[路边]新冠核酸检测/预约',
    description: '专业医学检测，电子报告',
    imageUrl: 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/miles.jpeg',
    price: '7000元',
  },
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
    conversation: {
      type: Object,
      value: {},
      observer(newVal) {
        this.setData({
          conversation: newVal,
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
    orderMatch: orderList,
  },

  /**
   * 组件的方法列表
   */
  methods: {
    handleClose() {
      this.triggerEvent('close', {
        key: '1',
      });
    },
    wordsInput(e) {
      this.data.orderMatch = [],
      orderList.forEach((item) => {
        if (item.title.indexOf(e.detail.value) > -1 || item.orderNum === ~~e.detail.value) {
          this.data.orderMatch.push(item);
        }
      });
      this.setData({
        words: e.detail.value,
        orderMatch: this.data.orderMatch,
      });
    },
    sendMessage(e) {
      const { order } = e.currentTarget.dataset;
      this.triggerEvent('sendCustomMessage', { // 传递给父组件，在父组件处调用SDK的接口，来进行自定消息的发送
        payload: {
          data: 'order', // data字段用于标识该消息类型
          description: order.description, // 获取自定义消息的具体描述
          extension: JSON.stringify({
            title: order.title,
            imageUrl: order.imageUrl,
            price: order.price }), // 自定义消息的具体内容
        },
      });
    },
  },
});
