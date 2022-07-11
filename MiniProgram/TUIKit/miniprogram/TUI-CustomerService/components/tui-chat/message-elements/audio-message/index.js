import { parseAudio } from '../../../base/message-facade';

// 创建audio控件
const myaudio = wx.createInnerAudioContext();
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
          message: newVal,
        });
      },
    },
    messageList: {
      type: Object,
      value: {},
      observer(newVal) {
        this.filtterAudioMessage(newVal);
        this.setData({
          audioMessageList: newVal,
        });
      },
    },
    isMine: {
      type: Boolean,
      value: true,
    },
  },

  lifetimes: {
    detached() {
      myaudio.stop();
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    message: '',
    renderDom: [],
    Audio: [],
    audioMessageList: [],
    audioSave: [],
    audKey: '',  // 当前选中的音频key
    indexAudio: Number,
    isPlay: false,
  },

  /**
   * 组件的方法列表
   */
  methods: {
    // 过滤语音消息,从消息列表里面筛选出语音消息
    filtterAudioMessage(messageList) {
      const list = [];
      for (let index = 0; index < messageList.length; index++) {
        if (messageList[index].type === 'TIMSoundElem') {
          list.push(messageList[index]);
          Object.assign(messageList[index], {
            isPlaying: false,
          }),
          this.data.audioSave = list;
          this.setData({
            audioSave: this.data.audioSave,
          });
        }
      }
    },

    // 音频播放
    audioPlay(e) {
      const  { id } = e.currentTarget.dataset;
      const { audioSave } = this.data;

      // 设置状态
      audioSave.forEach((message, index) => {
        message.isPlaying = false;
        if (audioSave[index].ID == id) {
          message.isPlaying = true;
          const indexAudio = audioSave.findIndex(value => value.ID == audioSave[index].ID);
          this.setData({
            indexAudio,
            isPlay: false,
          });
        }
      });
      this.setData({
        audioSave,
        audKey: this.data.indexAudio,
        isPlay: true,
      });
      myaudio.autoplay = true;
      const { audKey } = this.data;
      const playSrc = audioSave[audKey].payload.url;
      myaudio.src = playSrc;
      myaudio.play();
      // 开始监听
      myaudio.onPlay(() => {
        console.log('开始播放');
      });

      // 结束监听
      myaudio.onEnded(() => {
        console.log('自动播放完毕');
        audioSave[this.data.indexAudio].isPlaying = false;
        this.setData({
          audioSave,
          isPlay: false,
        });
      });

      // 错误回调
      myaudio.onError((err) => {
        console.log(err);
        audioSave[this.data.indexAudio].isPlaying = false;
        this.setData({
          audioSave,
        });
        return;
      });
    },

    // 音频停止
    audioStop(e) {
      const { key } = e.currentTarget.dataset;
      const { audioSave } = this.data;
      // 设置状态
      audioSave.forEach((message, index) => {
        message.isPlaying = false;
      });
      this.setData({
        audioSave,
        isPlay: false,
      });
      myaudio.stop();

      // 停止监听
      myaudio.onStop(() => {
        console.log('停止播放');
      });
    },
  },
});
