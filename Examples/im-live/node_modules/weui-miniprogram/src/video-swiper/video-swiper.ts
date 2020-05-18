Component({
  options: {
    addGlobalClass: true,
    pureDataPattern: /^_/ // 指定所有 _ 开头的数据字段为纯数据字段
  },
  properties: {
    duration: {
      type: Number,
      value: 500
    },
    easingFunction: {
      type: String,
      value: 'default'
    },
    loop: {
      type: Boolean,
      value: true
    },
    // {id, url, objectFit}
    videoList: {
      type: Array,
      value: [],
      observer: '_videoListChanged'
    }
  },
  data: {
    nextQueue: [], // 待播放列表
    prevQueue: [], // 已播放列表
    curQueue: [], // 当前播放列表
    circular: false, // 是否循环
    _last: 1, // 上一次显示
    _change: -1,
    _invalidUp: 0,
    _invalidDown: 0,
    _videoContexts: []
  },
  lifetimes: {
    attached() {
      this.data._videoContexts = [
        wx.createVideoContext('video_0', this),
        wx.createVideoContext('video_1', this),
        wx.createVideoContext('video_2', this)
      ]
    }
  },
  methods: {
    // 添加新的视频源
    _videoListChanged(newVal = []) {
      const data: any = this.data
      newVal.forEach(item => {
        data.nextQueue.push(item)
      })

      if (data.curQueue.length === 0) {
        this.setData({
          curQueue: data.nextQueue.splice(0, 3)
        }, () => {
          this.playCurrent(1)
        })
      }
    },

    // eslint-disable-next-line complexity
    animationfinish(e) {
      const {_last, _change, curQueue, prevQueue, nextQueue} = this.data

      const current = e.detail.current
      const diff = current - _last
      if (diff === 0) return

      this.data._last = current
      this.playCurrent(current)
      this.triggerEvent('change', {activeId: curQueue[current].id})

      const direction = (diff === 1 || diff === -2) ? 'up' : 'down'

      if (direction === 'up') {
        if (this.data._invalidDown === 0) {
          const change = (_change + 1) % 3
          const add = nextQueue.shift()
          const remove = curQueue[change]

          if (add) {
            prevQueue.push(remove)
            curQueue[change] = add
            this.data._change = change
          } else {
            this.data._invalidUp += 1
          }
        } else {
          this.data._invalidDown -= 1
        }
      }

      if (direction === 'down') {
        if (this.data._invalidUp === 0) {
          const change = _change
          const remove = curQueue[change]
          const add = prevQueue.pop()

          if (add) {
            curQueue[change] = add
            nextQueue.unshift(remove)
            this.data._change = (change - 1 + 3) % 3
          } else {
            this.data._invalidDown += 1
          }
        } else {
          this.data._invalidUp -= 1
        }
      }

      let circular = true

      if (nextQueue.length === 0 && current !== 0) {
        circular = false
      }

      if (prevQueue.length === 0 && current !== 2) {
        circular = false
      }

      this.setData({
        curQueue,
        circular,
      })
    },

    // 避免卡顿
    playCurrent(current) {
      this.data._videoContexts.forEach((ctx, index) => {
        index !== current ? ctx.pause() : ctx.play()
      })
      // setTimeout(() => ctx.play(), 100)
    },

    onPlay(e) {
     this.trigger(e, 'play')
    },

    onPause(e) {
      this.trigger(e, 'pause')
    },

    onEnded(e) {
      this.trigger(e, 'ended')
    },
    
    onError(e) {
      this.trigger(e, 'error')
    },

    onTimeUpdate(e) {
      this.trigger(e, 'timeupdate')
    },

    onWaiting(e) {
      this.trigger(e, 'wait')
    },

    onProgress(e) {
      this.trigger(e, 'progress')
    },

    onLoadedMetaData(e) {
      this.trigger(e, 'loadedmetadata')
    },
    trigger(e, type, ext = {}) {
      const detail = e.detail
      const activeId = e.target.dataset.id
      this.triggerEvent(type, Object.assign({
        ...detail,
        activeId
      }, ext))
    }
  }
})
  
