import { parseAudio } from '../../../base/message-facade';
// eslint-disable-next-line no-undef
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    message: {
      type: Object,
      value: {},
      observer(newVal) {
        this.setData({
          renderDom: parseAudio(newVal),
        });
      },
    },
    isMine: {
      type: Boolean,
      value: true,
    },
  },

  lifetimes: {
    attached() {
      this.audio = wx.createInnerAudioContext();
      this.audio.onPlay(() => {
        console.log('开始播放');
      });
      this.audio.onEnded(() => {
        console.log('停止播放');
      });
      // this.audio.onError(() => {
      //   // ios 音频播放无声，可能是因为系统开启了静音模式
      //   wx.showToast({
      //     icon: 'none',
      //     title: '该音频暂不支持播放',
      //   })
      // })
    },
    detached() {
      this.audio.stop();
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    renderDom: [],
    isPlay: 1,
    audioSrc: '',
  },

  /**
   * 组件的方法列表
   */
  methods: {
    // 点击切换语音播放状态
    handlePlayAudioMessage() {
      if (this.data.isPlay === 1) {
        this.audio.src = this.data.renderDom[0].src;
        this.audio.play();
        this.setData({
          isPlay: 2,
          audioSrc: this.data.renderDom[0].src,
        });
      } else if (this.data.isPlay === 2) {
        this.audio.src = this.data.renderDom[0].src;
        this.audio.stop();
        this.setData({
          isPlay: 1,
        });
      }
      if (this.data.audioSrc !== this.data.renderDom[0].src) {
        this.audio.src = this.data.audioSrc;
        this.audio.stop();
      }
    },

  },
});
