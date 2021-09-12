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
]

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
        })
      },
    },
    conversation: {
      type: Object,
      value: {},
      observer(newVal) {
        this.setData({
          conversation: newVal,
        })
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
      })
    },
    wordsInput(e) {
      this.data.orderMatch = [],
      orderList.forEach((item) => {
        if (item.title.indexOf(e.detail.value) > -1 || item.orderNum === ~~e.detail.value) {
          this.data.orderMatch.push(item)
        }
      })
      this.setData({
        words: e.detail.value,
        orderMatch: this.data.orderMatch,
      })
    },
    sendMessage(e) {
      const { order } = e.currentTarget.dataset
      this.triggerEvent('sendCustomMessage', {
        payload: {
          // data 字段作为表示，可以自定义
          data: 'order',
          description: order.description, // 获取骰子点数
          extension: JSON.stringify({
            title: order.title,
            imageUrl: order.imageUrl,
            price: order.price }),
        },
      })
    },
  },
})
