Component({
  /**
   * 组件的属性列表
   */
  properties: {
    message: {
      type: Object,
      value: '',
      observer(newVal) {
        this.setData({
          message: newVal,
          renderDom: this.parseCustom(newVal),
        })
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


  },

  /**
   * 组件的方法列表
   */
  methods: {
    parseCustom(message) {
      // 约定自定义消息的 data 字段作为区分，不解析的不进行展示
      if (message.payload.data === 'order') {
        const extension = JSON.parse(message.payload.extension)
        const renderDom = [{
          type: 'order',
          name: 'custom',
          title: extension.title || '',
          imageUrl: extension.imageUrl || '',
          price: extension.price || 0,
          description: message.payload.description,
        }]
        return renderDom
      }
      // 客服咨询
      if (message.payload.data === 'consultion') {
        const extension = JSON.parse(message.payload.extension)
        const renderDom = [{
          type: 'consultion',
          title: extension.title || '',
          item: extension.item || 0,
          description: extension.description,
        }]
        return renderDom
      }
      // 服务评价
      if (message.payload.data === 'evaluation') {
        const extension = JSON.parse(message.payload.extension)
        const renderDom = [{
          type: 'evaluation',
          title: message.payload.description,
          score: extension.score,
          description: extension.comment,
        }]
        return renderDom
      }
      // 群消息解析
      if (message.payload.data === 'group_create') {
        const renderDom = [{
          type: 'group_create',
          text: message.payload.extension,
        }]
        return renderDom
      }
      return [{
        type: 'notSupport',
        text: '[自定义消息]',
      }]
    },
  },
})
