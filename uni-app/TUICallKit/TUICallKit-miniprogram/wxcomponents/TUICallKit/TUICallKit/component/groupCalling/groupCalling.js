// components/tui-calling/TUICalling/component/calling.js
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    isSponsor: {
      type: Boolean,
    },
    pusher: {
      type: Object,
    },
    callType: {
      type: Number,
    },
    allUsers: {
      type: Array,
    },
    isGroup: {
      type: Boolean,
    },
    ownUserId: {
      type: String,
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    userID: null,
    isClick: true,
  },

  /**
   * 生命周期方法
   */
  lifetimes: {
    created() {
    },
    attached() {
    },
    ready() {

    },
    detached() {

    },
    error() {
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    accept(event) {
      this.setData({
        isClick: false,
      });
      const data = {
        name: 'accept',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    hangup(event) {
      const data = {
        name: 'hangup',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    reject(event) {
      const data = {
        name: 'reject',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    handleErrorImage(e) {
      const { id } = e.target;
      const allUsers = this.data.allUsers.map((item) => {
        if (item.userID === id) {
          item.avatar = '../../static/default_avatar.png';
        }
        return item;
      });
      this.setData({
        allUsers,
      });
    },
    toggleSwitchCamera(event) {
      const data = {
        name: 'toggleSwitchCamera',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
    switchAudioCall(event) {
      const data = {
        name: 'switchAudioCall',
        event,
      };
      this.triggerEvent('callingEvent', data);
    },
  },
});
