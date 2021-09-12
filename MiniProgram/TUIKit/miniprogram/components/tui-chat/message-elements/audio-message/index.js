import { parseAudio } from '../../../base/message-facade'
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
          renderDom: parseAudio(newVal),
        })
      },
    },
    isMine: {
      type: Boolean,
      value: true,
    },
  },

  lifetimes: {
    attached() {
      this.audio = wx.createInnerAudioContext()
      this.audio.obeyMuteSwitch = false
      this.audio.onPlay(() => {
        console.log('开始播放')
      })
      this.audio.onEnded(() => {
        console.log('停止播放')
      })
      this.audio.onError(() => {
        // ios 音频播放无声，可能是因为系统开启了静音模式
        wx.showToast({
          icon: 'none',
          title: '该音频暂不支持播放',
        })
      })
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    renderDom: [],

  },

  /**
   * 组件的方法列表
   */
  methods: {
    handlePlayAudioMessage() {
      this.audio.src = this.data.renderDom[0].src
      this.audio.play()
    },
  },
})
