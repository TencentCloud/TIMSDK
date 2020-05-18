Component({
  options: {
    multipleSlots: true, // 在组件定义时的选项中启用多slot支持
    addGlobalClass: true
  },
  properties: {
    title: { // 标题
      type: String,
      value: ''
    },
    showCancel: {  // 是否显示取消按钮
      type: Boolean,
      value: true
    },
    cancelText: { // 取消按钮文案
      type: String,
      value: '取消'
    },
    maskClass: { // 遮罩层class
      type: String,
      value: ''
    },
    extClass: { // 弹出窗 class
      type: String,
      value: ''
    },
    maskClosable: { // 点击遮罩 关闭 actionsheet
      type: Boolean,
      value: true,
    },
    mask: { // 是否需要 遮罩层
      type: Boolean,
      value: true
    },
    show: { // 是否开启 actionsheet
      type: Boolean,
      value: false
    },
    actions: { // actions 列表
      type: Array,
      value: [], // {text, extClass}
      observer: '_groupChange'
    }
  },

  methods: {
    _groupChange(e) {
      // 支持 一维数组 写法
      if(e.length > 0 && typeof e[0] !== 'string' && !(e[0] instanceof Array)) {
        this.setData({
          actions: [this.data.actions]
        })
      }
    },
    buttonTap(e) {
      const { value, groupindex, index } = e.currentTarget.dataset
      this.triggerEvent('actiontap', { value, groupindex, index })
    },
    closeActionSheet(e) {
      const { type } = e.currentTarget.dataset
      if(this.data.maskClosable || type) {
        // 点击 action 里面的 取消
        this.setData({
          show: false
        })
        // 关闭回调事件
        this.triggerEvent('close')
      }
    }
  }
})
