// eslint-disable-next-line no-undef
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    playerList: {
      type: Array,
    },
    pusher: {
      type: Object,
    },
    callType: {
      type: Number,
    },
    soundMode: {
      type: String,
    },
    screen: {
      type: String,
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
    toggleViewSize(event) {
      const data = {
        name: 'toggleViewSize',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherNetStatus(event) {
      const data = {
        name: 'pusherNetStatus',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    playNetStatus(event) {
      const data = {
        name: 'playNetStatus',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherStateChangeHandler(event) {
      const data = {
        name: 'pusherStateChangeHandler',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherAudioVolumeNotify(event) {
      const data = {
        name: 'pusherAudioVolumeNotify',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    playerStateChange(event) {
      const data = {
        name: 'playerStateChange',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    playerAudioVolumeNotify(event) {
      const data = {
        name: 'playerAudioVolumeNotify',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherAudioHandler(event) {
      const data = {
        name: 'pusherAudioHandler',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    hangup(event) {
      const data = {
        name: 'hangup',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    toggleSoundMode(event) {
      const data = {
        name: 'toggleSoundMode',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    pusherVideoHandler(event) {
      const data = {
        name: 'pusherVideoHandler',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    toggleSwitchCamera(event) {
      const data = {
        name: 'toggleSwitchCamera',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    switchAudioCall(event) {
      const data = {
        name: 'switchAudioCall',
        event,
      };
      this.triggerEvent('connectedEvent', data);
    },
    handleConnectErrorImage(e) {
      const { value, flag } = e.target.dataset;
      if (flag === 'pusher') {
        this.data.pusher.avatar = '../../static/default_avatar.png';
        this.setData({
          pusher: this.data.pusher,
        });
      } else {
        const playerList = this.data.playerList.map((item) => {
          if (item.userID === value) {
            item.avatar = '../../static/default_avatar.png';
          }
          return item;
        });
        this.setData({
          playerList,
        });
      }
    },
  },
});
