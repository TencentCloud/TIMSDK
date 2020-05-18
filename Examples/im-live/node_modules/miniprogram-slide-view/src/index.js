// slide-view/slide-view.js
const _windowWidth = wx.getSystemInfoSync().windowWidth
Component({
  /**
   * 组件的属性列表
   */
  options: {
    multipleSlots: true,
  },
  properties: {
    //  组件显示区域的宽度
    width: {
      type: Number,
      value: _windowWidth
    },
    //  组件显示区域的高度
    height: {
      type: Number,
      value: 0,
    },
    //  组件滑动显示区域的宽度
    slideWidth: {
      type: Number,
      value: 0
    }
  },

  /**
   * 组件的初始数据
   */
  data: {
    viewWidth: _windowWidth,
    //  movable-view偏移量
    x: 0,
    //  movable-view是否可以出界
    out: false,
  },

  /**
   * 组件的方法列表
   */
  //    获取右侧滑动显示区域的宽度
  ready() {
    const that = this
    const query = wx.createSelectorQuery().in(this)
    query.select('.right').boundingClientRect(function (res) {
      that._slideWidth = res.width
      that._threshold = res.width / 2
      that._viewWidth = that.data.width + res.width * (750 / _windowWidth)
      that.setData({
        viewWidth: that._viewWidth
      })
    }).exec()
  },
  methods: {
    onTouchStart(e) {
      this._startX = e.changedTouches[0].pageX
    },
    //  当滑动范围超过阈值自动完成剩余滑动
    onTouchEnd(e) {
      this._endX = e.changedTouches[0].pageX
      const {_endX, _startX, _threshold} = this
      if (_startX - _endX >= _threshold) {
        this.setData({
          x: -this._slideWidth
        })
      } else if (_startX - _endX < _threshold && _startX - _endX > 0) {
        this.setData({
          x: 0
        })
      } else if (_endX - _startX >= _threshold) {
        this.setData({
          x: 0
        })
      } else if (_endX - _startX < _threshold && _endX - _startX > 0) {
        this.setData({
          x: -this._slideWidth
        })
      }
    },
    //  根据滑动的范围设定是否允许movable-view出界
    onChange(e) {
      if (!this.data.out && e.detail.x < -this._threshold) {
        this.setData({
          out: true
        })
      } else if (this.data.out && e.detail.x >= -this._threshold) {
        this.setData({
          out: false
        })
      }
    }
  }
})
