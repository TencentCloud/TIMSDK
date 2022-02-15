import TRTCCalling from './TRTCCalling/TRTCCalling.js';


const TAG_NAME = 'TUICalling';
// 组件旨在跨终端维护一个通话状态管理机，以事件发布机制驱动上层进行管理，并通过API调用进行状态变更。
// 组件设计思路将UI和状态管理分离。您可以通过修改`component`文件夹下的文件，适配您的业务场景，
// 在UI展示上，您可以通过属性的方式，将上层的用户头像，名称等数据传入组件内部，`static`下的icon和默认头像图片，
// 只是为了展示基础的效果，您需要根据业务场景进行修改。

// eslint-disable-next-line no-undef
Component({
  properties: {
    config: {
      type: Object,
      value: {
        sdkAppID: 0,
        userID: '',
        userSig: '',
        type: 1,
        tim: null,
      },
    },
    backgroundMute: {
      type: Boolean,
      value: false,
    },
  },
  observers: {

  },

  data: {
    callStatus: 'idle', // idle、calling、connection
    isSponsor: false,
    pusher: {}, // TRTC 本地流
    playerList: [], // TRTC 远端流
    remoteUsers: [], // 远程用户资料
    screen: 'pusher', // 视屏通话中，显示大屏幕的流（只限1v1聊天
    soundMode: 'speaker', // 声音模式 听筒/扬声器
  },

  methods: {
    initCall() {
      // 收起键盘
      wx.hideKeyboard();
    },
    // 新的邀请回调事件
    handleNewInvitationReceived(event) {
      this.initCall();
      console.log(`${TAG_NAME}, handleNewInvitationReceived, event${JSON.stringify(event)}`);
      this.data.config.type = event.data.inviteData.callType;
      this.getUserProfile([event.data.sponsor]);
      this.setData({
        config: this.data.config,
        callStatus: 'calling',
        isSponsor: false,
      });
    },

    // 用户接听
    handleUserAccept(event) {
      console.log(`${TAG_NAME}, handleUserAccept, event${JSON.stringify(event)}`);
      this.setData({
        callStatus: 'connection',
      });
    },

    // 远端用户进入通话
    handleUserEnter(res) {
      this.setData({
        playerList: res.playerList,
      });
    },
    // 远端用户离开通话
    handleUserLeave(res) {
      this.setData({
        playerList: res.data.playerList,
      });
    },
    // 用户数据更新
    handleUserUpdate(res) {
      console.log(`${TAG_NAME}, handleUserUpdate, res`);
      console.log(res);
      this.handleNetStatus(res.data);
      this.setData({
        pusher: res.data.pusher,
        playerList: res.data.playerList,
      });
    },
    // 判断网络状态
    handleNetStatus(data) {
      if (data.pusher.netQualityLevel > 4) {
        wx.showToast({
          icon: 'none',
          title: '您当前网络不佳',
        });
      }
      data.playerList.map((item) => {
        if (item.netStatus.netQualityLevel > 4) {
          const name = data.playerList.length > 1 ? item.nick : '对方';
          wx.showToast({
            icon: 'none',
            title: `${name}当前网络不佳`,
          });
        }
        return item;
      });
    },
    // 用户拒绝
    handleInviteeReject(event) {
      console.log(`${TAG_NAME}, handleInviteeReject, event${JSON.stringify(event)}`);
      wx.showToast({
        title: `${this.handleCallingUser([event.data.invitee])}已拒绝`,
      });
    },
    // 用户不在线
    handleNoResponse(event) {
      console.log(`${TAG_NAME}, handleNoResponse, event${JSON.stringify(event)}`);
      wx.showToast({
        title: `${this.handleCallingUser(event.data.timeoutUserList)}不在线`,
      });
    },
    // 用户忙线
    handleLineBusy(event) {
      console.log(`${TAG_NAME}, handleLineBusy, event${JSON.stringify(event)}`);
      wx.showToast({
        title: `${this.handleCallingUser([event.data.invitee])}忙线中`,
      });
    },
    // 用户取消
    handleCallingCancel(event) {
      console.log(`${TAG_NAME}, handleCallingCancel, event${JSON.stringify(event)}`);
      wx.showToast({
        title: `${this.handleCallingUser([event.data.invitee])}取消通话`,
      });
    },
    // 通话超时未应答
    handleCallingTimeout(event) {
      console.log(`${TAG_NAME}, handleCallingTimeout, event${JSON.stringify(event)}`);
      wx.showToast({
        title: `${this.handleCallingUser(event.data.timeoutUserList)}超时无应答`,
      });
    },
    handleCallingUser(userIDList) {
      const remoteUsers = [...this.data.remoteUsers];
      const userProfile = remoteUsers.filter(item => userIDList.some(userItem => `${userItem}` === item.userID));
      this.setData({
        remoteUsers: remoteUsers.filter(item => userIDList.some(userItem => userItem !== item.userID)),
      });
      console.log(`${TAG_NAME}, handleCallingUser, userProfile`, userProfile);
      let nick = '';
      for (let i = 0; i < userProfile.length; i++) {
        nick += `${userProfile[i].nick}、`;
      }
      return nick.slice(0, -1);
    },
    // 通话结束
    handleCallingEnd(event) {
      console.log(`${TAG_NAME}, handleCallingEnd`);
      console.log(event);
      this.reset();
      if (event.data.message) {
        this.triggerEvent('sendMessage', {
          message: event.data.message,
        });
      }
      wx.showToast({
        title: '通话结束',
        duration: 800,
      });
    },

    // SDK Ready 回调
    handleSDKReady() {
      // 呼叫需在sdk ready之后
    },
    // 被踢下线
    handleKickedOut() {
      wx.showToast({
        title: '您已被踢下线',
      });
    },
    // 切换通话模式
    handleCallMode(event) {
      this.data.config.type = event.data.type;
      this.setData({
        config: this.data.config,
      });
      this.triggerEvent('sendMessage', {
        message: event.data.message,
      });
    },
    // 增加 tsignaling 事件监听
    _addTSignalingEvent() {
      // 被邀请通话
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.INVITED, this.handleNewInvitationReceived, this);
      // 用户接听
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.USER_ACCEPT, this.handleUserAccept, this);
      // 用户进入通话
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.USER_ENTER, this.handleUserEnter, this);
      // 用户离开通话
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.USER_LEAVE, this.handleUserLeave, this);
      // 用户离开通话
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.USER_UPDATE, this.handleUserUpdate, this);
      // 用户拒绝通话
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.REJECT, this.handleInviteeReject, this);
      // 用户无响应
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.NO_RESP, this.handleNoResponse, this);
      // 用户忙线
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.LINE_BUSY, this.handleLineBusy, this);
      // 通话被取消
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.CALLING_CANCEL, this.handleCallingCancel, this);
      // 通话超时未应答
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.CALLING_TIMEOUT, this.handleCallingTimeout, this);
      // 通话结束
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.CALL_END, this.handleCallingEnd, this);
      // SDK Ready 回调
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.SDK_READY, this.handleSDKReady, this);
      // 被踢下线
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.KICKED_OUT, this.handleKickedOut, this);
      // 切换通话模式
      wx.$TRTCCalling.on(wx.$TRTCCalling.EVENT.CALL_MODE, this.handleCallMode, this);
    },
    // 取消 tsignaling 事件监听
    _removeTSignalingEvent() {
      // 被邀请通话
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.INVITED, this.handleNewInvitationReceived);
      // 用户接听
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.USER_ACCEPT, this.handleUserAccept);
      // 用户进入通话
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.USER_ENTER, this.handleUserEnter);
      // 用户离开通话
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.USER_LEAVE, this.handleUserLeave);
      // 用户离开通话
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.USER_UPDATE, this.handleUserUpdate);
      // 用户拒绝通话
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.REJECT, this.handleInviteeReject);
      // 用户无响应
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.NO_RESP, this.handleNoResponse);
      // 用户忙线
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.LINE_BUSY, this.handleLineBusy);
      // 通话被取消
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.CALLING_CANCEL, this.handleCallingCancel);
      // 通话超时未应答
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.CALLING_TIMEOUT, this.handleCallingTimeout);
      // 通话结束
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.CALL_END, this.handleCallingEnd);
      // SDK Ready 回调
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.SDK_READY, this.handleSDKReady);
      // 被踢下线
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.KICKED_OUT, this.handleKickedOut);
      // 切换通话模式
      wx.$TRTCCalling.off(wx.$TRTCCalling.EVENT.CALL_MODE, this.handleCallMode);
    },
    /**
     * C2C邀请通话，被邀请方会收到的回调
     * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
     *
     * @param userID 被邀请方
     * @param type 0-为之， 1-语音通话，2-视频通话
     */
    async call(params) {
      this.initCall();
      wx.$TRTCCalling.call({ userID: params.userID, type: params.type }).then((res) => {
        this.data.config.type = params.type;
        this.getUserProfile([params.userID]);
        this.setData({
          pusher: res.pusher,
          config: this.data.config,
          callStatus: 'calling',
          isSponsor: true,
        });
        this.triggerEvent('sendMessage', {
          message: res.data.message,
        });
      });
    },
    /**
     * IM群组邀请通话，被邀请方会收到的回调
     * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到的回调
     *
     * @param userIDList 邀请列表
     * @param type 1-语音通话，2-视频通话
     * @param groupID IM群组ID
     */
    async groupCall(params) {
      this.initCall();
      wx.$TRTCCalling.groupCall({ userIDList: params.userIDList, type: params.type, groupID: params.groupID }).then((res) => {
        this.data.config.type = params.type;
        this.getUserProfile(params.userIDList);
        this.setData({
          pusher: res.pusher,
          config: this.data.config,
          callStatus: 'calling',
          isSponsor: true,
        });
      });
    },
    /**
     * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
     */
    async accept() {
      wx.$TRTCCalling.accept().then((res) => {
        this.setData({
          pusher: res.pusher,
          callStatus: 'connection',
        });
        this.triggerEvent('sendMessage', {
          message: res.message,
        });
      });
    },
    /**
     * 当您作为被邀请方收到的回调时，可以调用该函数拒绝来电
     */
    async reject() {
      console.log(`${TAG_NAME}, reject`);
      wx.$TRTCCalling.reject().then((res) => {
        this.triggerEvent('sendMessage', {
          message: res.data.message,
        });
      });
      this.reset();
    },

    // xml层，是否开启扬声器
    toggleSoundMode() {
      this.setData({
        soundMode: wx.$TRTCCalling._toggleSoundMode(),
      });
    },

    // xml层，挂断
    _hangUp() {
      console.log(`${TAG_NAME}, hangup`);
      wx.$TRTCCalling.hangup();
      this.reset();
    },

    //  切换大小屏 (仅支持1v1聊天)
    toggleViewSize(event) {
      this.setData({
        screen: wx.$TRTCCalling._toggleViewSize(event),
      });
    },
    // 数据重置
    reset() {
      this.setData({
        callStatus: 'idle',
        isSponsor: false,
        pusher: {}, // TRTC 本地流
        playerList: [], // TRTC 远端流
      });
    },
    // 呼叫中的事件处理
    handleCallingEvent(data) {
      const { name } = data.detail;
      switch (name) {
        case 'accept':
          this.accept();
          break;
        case 'hangup':
          this._hangUp();
          break;
        case 'reject':
          this.reject();
          break;
        case 'toggleSwitchCamera':
          wx.$TRTCCalling.switchCamera();
          break;
        case 'switchAudioCall':
          wx.$TRTCCalling.switchAudioCall().then((res) => {
            this.data.config.type = wx.$TRTCCalling.CALL_TYPE.AUDIO;
            this.setData({
              config: this.data.config,
            });
            this.triggerEvent('sendMessage', {
              message: res.data.message,
            });
          });
          break;
        default:
          break;
      }
    },
    // 通话中的事件处理
    handleConnectedEvent(data) {
      console.log(`${TAG_NAME}, handleVideoEvent--`, data);
      const { name, event } = data.detail;
      switch (name) {
        case 'toggleViewSize':
          this.toggleViewSize(event);
          break;
        case 'pusherNetStatus':
          wx.$TRTCCalling._pusherNetStatus(event);
          break;
        case 'playNetStatus':
          wx.$TRTCCalling._playNetStatus(event);
          break;
        case 'pusherStateChangeHandler':
          wx.$TRTCCalling._pusherStateChangeHandler(event);
          break;
        case 'pusherAudioVolumeNotify':
          wx.$TRTCCalling._pusherAudioVolumeNotify(event);
          break;
        case 'playerStateChange':
          wx.$TRTCCalling._playerStateChange(event);
          break;
        case 'playerAudioVolumeNotify':
          wx.$TRTCCalling._playerAudioVolumeNotify(event);
          break;
        case 'pusherAudioHandler':
          wx.$TRTCCalling._pusherAudioHandler(event);
          break;
        case 'hangup':
          this._hangUp();
          break;
        case 'toggleSoundMode':
          this.toggleSoundMode();
          break;
        case 'pusherVideoHandler':
          wx.$TRTCCalling._pusherVideoHandler(event);
          break;
        case 'toggleSwitchCamera':
          wx.$TRTCCalling.switchCamera(event);
          break;
        case 'switchAudioCall':
          wx.$TRTCCalling.switchAudioCall().then((res) => {
            this.data.config.type = 1;
            this.setData({
              config: this.data.config,
            });
            this.triggerEvent('sendMessage', {
              message: res.data.message,
            });
          });
          break;
        default:
          break;
      }
    },

    // 获取用户资料
    async getUserProfile(userList) {
      const imResponse = await this.getTim().getUserProfile({ userIDList: userList });
      this.setData({
        remoteUsers: imResponse.data,
      });
    },
    // 获取 tim 实例
    getTim() {
      return wx.$TRTCCalling.getTim();
    },
    // 初始化TRTCCalling
    async init() {
      try {
        const res = await wx.$TRTCCalling.login({
          userID: this.data.config.userID,
          userSig: this.data.config.userSig,
        });
        this._addTSignalingEvent();
        return res;
      } catch (error) {
        throw new Error('TRTCCalling login failure', error);
      }
    },
    // 销毁 TRTCCalling
    destroyed() {
      this._removeTSignalingEvent();
      if (this.data.config.tim) {
        wx.$TRTCCalling.destroyed();
      } else {
        wx.$TRTCCalling.logout();
      }
    },
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
      if (!wx.$TRTCCalling) {
        wx.$TRTCCalling = new TRTCCalling({
          sdkAppID: this.data.config.sdkAppID,
          tim: this.data.config.tim,
        });
      }
      wx.$TRTCCalling.initData();
      this.reset();
    },
    detached() {
      this.reset();
    },
    error() {
    },
  },
  pageLifetimes: {
    show() {

    },
    hide() {
    },
    resize() {
    },
  },
});
