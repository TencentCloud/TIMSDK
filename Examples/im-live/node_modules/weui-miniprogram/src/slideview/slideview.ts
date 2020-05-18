Component({
  /**
   * 组件的属性列表
   */
  options: {
    addGlobalClass: true,
    multipleSlots: true,
  },
  properties: {
    extClass: {
      type: String,
      value: ''
    },
    buttons: {
      type: Array,
      value: [], // type, data, text, src, extClass
      observer: function(newVal) {
        this.addClassNameForButton()
      }
    },
    disable: {
      type: Boolean,
      value: false
    },
    icon: { // 是否是icon
      type: Boolean,
      value: false
    },
    show: {
      type: Boolean,
      value: false
    },
    duration: {
      type: Number,
      value: 350, // 动画市场，单位ms
    },
    throttle: {
      type: Number,
      value: 40,
    },
    rebounce: {
      type: Number,
      value: 0, // 回弹距离
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    size: null
  },

  /**
   * 组件的方法列表
   */
  ready() {
    //@ts-ignore
    this.updateRight()
    this.addClassNameForButton()
  },
  methods: {
    updateRight() {
      // 获取右侧滑动显示区域的宽度
      const data:any = this.data
      const query = wx.createSelectorQuery().in(this)
      query.select('.left').boundingClientRect((res) => {
        console.log('right res', res)
        const btnQuery = wx.createSelectorQuery().in(this)
        btnQuery.selectAll('.btn').boundingClientRect((rects) => {
          console.log('btn rects', rects)
          this.setData({
            size: {
              buttons: rects,
              button: res,
              show: data.show,
              disable: data.disable,
              throttle: data.throttle,
              rebounce: data.rebounce
            }
          })
        }).exec()
      }).exec()
    },
    addClassNameForButton() {
      // @ts-ignore
      const {buttons, icon} = this.data
      buttons.forEach(btn => {
        if (icon) {
          btn.className = ''
        } else if (btn.type === 'warn') {
          btn.className = 'weui-slideview__btn-group_warn'
        } else {
          btn.className = 'weui-slideview__btn-group_default'
        }
      });
      this.setData({
        buttons: buttons
      })

    },
    buttonTapByWxs(data) {
      this.triggerEvent('buttontap', data, {})
    },
    hide() {
      this.triggerEvent('hide', {}, {})
    },
    show() {
      this.triggerEvent('show', {}, {})
    },
    transitionEnd() {
      console.log('transitiion end')
    }
  }
})
