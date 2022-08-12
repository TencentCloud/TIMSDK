import TUICallEngine, { EVENT, MEDIA_TYPE, AUDIO_PLAYBACK_DEVICE, STATUS } from '../TUICallEngine/tuicall-engine-wx.js';

const TAG_NAME = 'TUICallKit';
// 组件旨在跨终端维护一个通话状态管理机，以事件发布机制驱动上层进行管理，并通过API调用进行状态变更。
// 组件设计思路将UI和状态管理分离。您可以通过修改`component`文件夹下的文件，适配您的业务场景，
// 在UI展示上，您可以通过属性的方式，将上层的用户头像，名称等数据传入组件内部，`static`下的icon和默认头像图片，
// 只是为了展示基础的效果，您需要根据业务场景进行修改。

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
    callStatus: STATUS.IDLE, // idle、calling、connection
    isSponsor: false,
    pusher: {}, // TRTC 本地流
    playerList: [], // TRTC 远端流
    remoteUsers: [], // 远程用户资料
    screen: 'pusher', // 视屏通话中，显示大屏幕的流（只限1v1聊天
    soundMode: AUDIO_PLAYBACK_DEVICE.SPEAKER, // 声音模式 听筒/扬声器
    userList: null, // 接受邀请的用户信息
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
        callStatus: STATUS.CALLING,
        isSponsor: false,
      });
    },

    // 用户接听
    handleUserAccept(event) {
      console.log(`${TAG_NAME}, handleUserAccept, event${JSON.stringify(event)}`);
      this.setData({
        callStatus: STATUS.CONNECTED,
        userList: event.data.userList,
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
      if (this.data.playerList.length === 0) {
        this.reset();
      }
      wx.showToast({
        title: `${this.handleCallingUser([event.data.invitee])}已拒绝`,
      });
    },
    // 用户不在线
    handleNoResponse(event) {
      console.log(`${TAG_NAME}, handleNoResponse, event${JSON.stringify(event)}`);
      if (this.data.playerList.length === 0) {
        this.reset();
      }
      wx.showToast({
        title: `${this.handleCallingUser(event.data.timeoutUserList)}不在线`,
      });
    },
    // 用户忙线
    handleLineBusy(event) {
      console.log(`${TAG_NAME}, handleLineBusy, event${JSON.stringify(event)}`);
      if (this.data.playerList.length === 0) {
        this.reset();
      }
      wx.showToast({
        title: `${this.handleCallingUser([event.data.invitee])}忙线中`,
      });
    },
    // 用户取消
    handleCallingCancel(event) {
      console.log(`${TAG_NAME}, handleCallingCancel, event${JSON.stringify(event)}`);
      if (this.data.playerList.length === 0) {
        this.reset();
      }
      wx.showToast({
        title: `${this.handleCallingUser([event.data.invitee])}取消通话`,
      });
    },
    // 通话超时未应答
    handleCallingTimeout(event) {
      console.log(`${TAG_NAME}, handleCallingTimeout, event${JSON.stringify(event)}`);
      if (this.data.playerList.length === 0) {
        this.reset();
      }
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
      this.setSoundMode(AUDIO_PLAYBACK_DEVICE.EAR);
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
      wx.$TUICallEngine.on(EVENT.INVITED, this.handleNewInvitationReceived, this);
      // 用户接听
      wx.$TUICallEngine.on(EVENT.USER_ACCEPT, this.handleUserAccept, this);
      // 用户进入通话
      wx.$TUICallEngine.on(EVENT.USER_ENTER, this.handleUserEnter, this);
      // 用户离开通话
      wx.$TUICallEngine.on(EVENT.USER_LEAVE, this.handleUserLeave, this);
      // 用户离开通话
      wx.$TUICallEngine.on(EVENT.USER_UPDATE, this.handleUserUpdate, this);
      // 用户拒绝通话
      wx.$TUICallEngine.on(EVENT.REJECT, this.handleInviteeReject, this);
      // 用户无响应
      wx.$TUICallEngine.on(EVENT.NO_RESP, this.handleNoResponse, this);
      // 用户忙线
      wx.$TUICallEngine.on(EVENT.LINE_BUSY, this.handleLineBusy, this);
      // 通话被取消
      wx.$TUICallEngine.on(EVENT.CALLING_CANCEL, this.handleCallingCancel, this);
      // 通话超时未应答
      wx.$TUICallEngine.on(EVENT.CALLING_TIMEOUT, this.handleCallingTimeout, this);
      // 通话结束
      wx.$TUICallEngine.on(EVENT.CALL_END, this.handleCallingEnd, this);
      // SDK Ready 回调
      wx.$TUICallEngine.on(EVENT.SDK_READY, this.handleSDKReady, this);
      // 被踢下线
      wx.$TUICallEngine.on(EVENT.KICKED_OUT, this.handleKickedOut, this);
      // 切换通话模式
      wx.$TUICallEngine.on(EVENT.CALL_MODE, this.handleCallMode, this);
    },
    // 取消 tsignaling 事件监听
    _removeTSignalingEvent() {
      // 被邀请通话
      wx.$TUICallEngine.off(EVENT.INVITED, this.handleNewInvitationReceived);
      // 用户接听
      wx.$TUICallEngine.off(EVENT.USER_ACCEPT, this.handleUserAccept);
      // 用户进入通话
      wx.$TUICallEngine.off(EVENT.USER_ENTER, this.handleUserEnter);
      // 用户离开通话
      wx.$TUICallEngine.off(EVENT.USER_LEAVE, this.handleUserLeave);
      // 用户离开通话
      wx.$TUICallEngine.off(EVENT.USER_UPDATE, this.handleUserUpdate);
      // 用户拒绝通话
      wx.$TUICallEngine.off(EVENT.REJECT, this.handleInviteeReject);
      // 用户无响应
      wx.$TUICallEngine.off(EVENT.NO_RESP, this.handleNoResponse);
      // 用户忙线
      wx.$TUICallEngine.off(EVENT.LINE_BUSY, this.handleLineBusy);
      // 通话被取消
      wx.$TUICallEngine.off(EVENT.CALLING_CANCEL, this.handleCallingCancel);
      // 通话超时未应答
      wx.$TUICallEngine.off(EVENT.CALLING_TIMEOUT, this.handleCallingTimeout);
      // 通话结束
      wx.$TUICallEngine.off(EVENT.CALL_END, this.handleCallingEnd);
      // SDK Ready 回调
      wx.$TUICallEngine.off(EVENT.SDK_READY, this.handleSDKReady);
      // 被踢下线
      wx.$TUICallEngine.off(EVENT.KICKED_OUT, this.handleKickedOut);
      // 切换通话模式
      wx.$TUICallEngine.off(EVENT.CALL_MODE, this.handleCallMode);
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
      if (this.data.callStatus !== STATUS.IDLE) {
        console.warn(`${TAG_NAME}, call callStatus isn't idle`);
        return;
      }

      await wx.$TUICallEngine.call({ userID: params.userID, type: params.type }).then((res) => {
        this.data.config.type = params.type;
        this.getUserProfile([params.userID]);
        this.setData({
          pusher: res.pusher,
          config: this.data.config,
          callStatus: STATUS.CALLING,
          isSponsor: true,
        });
        this.setSoundMode(this.data.config.type === MEDIA_TYPE.AUDIO ? AUDIO_PLAYBACK_DEVICE.EAR : AUDIO_PLAYBACK_DEVICE.SPEAKER);
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
      if (this.data.callStatus !== STATUS.IDLE) {
        console.warn(`${TAG_NAME}, groupCall callStatus isn't idle`);
        return;
      }
      wx.$TUICallEngine.groupCall({ userIDList: params.userIDList, type: params.type, groupID: params.groupID }).then((res) => {
        this.data.config.type = params.type;
        this.getUserProfile(params.userIDList);
        this.setData({
          pusher: res.pusher,
          config: this.data.config,
          callStatus: STATUS.CALLING,
          isSponsor: true,
        });
      });
    },
    /**
     * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
     */
    async accept() {
      wx.$TUICallEngine.accept().then((res) => {
        console.log('accept', res);
        this.setData({
          pusher: res.pusher,
          callStatus: STATUS.CONNECTED,
        });
        this.triggerEvent('sendMessage', {
          message: res.message,
        });
      })
        .catch((error) => {
          wx.showModal({
            icon: 'none',
            title: 'error',
            content: error.message,
            showCancel: false,
          });
        });
    },
    /**
     * 当您作为被邀请方收到的回调时，可以调用该函数拒绝来电
     */
    async reject() {
      console.log(`${TAG_NAME}, reject`);
      wx.$TUICallEngine.reject().then((res) => {
        this.triggerEvent('sendMessage', {
          message: res.data.message,
        });
      });
      this.reset();
    },

    // xml层，是否开启扬声器
    setSoundMode(type) {
      this.setData({
        soundMode: wx.$TUICallEngine.selectAudioPlaybackDevice(type),
      });
    },

    // xml层，挂断
    _hangUp() {
      console.log(`${TAG_NAME}, hangup`);
      wx.$TUICallEngine.hangup();
      this.reset();
    },

    //  切换大小屏 (仅支持1v1聊天)
    toggleViewSize(event) {
      this.setData({
        // FIXME _toggleViewSize 不应该为TUICallEngine的方法 后续修改
        screen: wx.$TUICallEngine._toggleViewSize(event),
      });
    },
    // 数据重置
    reset() {
      this.setData({
        callStatus: STATUS.IDLE,
        isSponsor: false,
        soundMode: AUDIO_PLAYBACK_DEVICE.SPEAKER,
        pusher: {}, // TRTC 本地流
        playerList: [], // TRTC 远端流
      });
    },
    // 呼叫中的事件处理
    handleCallingEvent(data) {
      const { name } = data.detail;
      switch (name) {
        case 'accept':
          this.setSoundMode(this.data.config.type === MEDIA_TYPE.AUDIO ? AUDIO_PLAYBACK_DEVICE.EAR : AUDIO_PLAYBACK_DEVICE.SPEAKER);
          this.accept();
          break;
        case 'hangup':
          this._hangUp();
          break;
        case 'reject':
          this.reject();
          break;
        case 'toggleSwitchCamera':
          wx.$TUICallEngine.switchCamera();
          break;
        case 'switchAudioCall':
          wx.$TUICallEngine.switchCallMediaType(MEDIA_TYPE.AUDIO).then((res) => {
            this.data.config.type = MEDIA_TYPE.AUDIO;
            this.setSoundMode(AUDIO_PLAYBACK_DEVICE.EAR);
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
          wx.$TUICallEngine._pusherNetStatus(event);
          break;
        case 'playNetStatus':
          wx.$TUICallEngine._playNetStatus(event);
          break;
        case 'pusherStateChangeHandler':
          wx.$TUICallEngine._pusherStateChangeHandler(event);
          break;
        case 'pusherAudioVolumeNotify':
          wx.$TUICallEngine._pusherAudioVolumeNotify(event);
          break;
        case 'playerStateChange':
          wx.$TUICallEngine._playerStateChange(event);
          break;
        case 'playerAudioVolumeNotify':
          wx.$TUICallEngine._playerAudioVolumeNotify(event);
          break;
        case 'pusherAudioHandler':
          wx.$TUICallEngine._pusherAudioHandler(event);
          break;
        case 'hangup':
          this._hangUp();
          break;
        case 'toggleSoundMode':
          this.setSoundMode(this.data.soundMode === AUDIO_PLAYBACK_DEVICE.EAR ? AUDIO_PLAYBACK_DEVICE.SPEAKER : AUDIO_PLAYBACK_DEVICE.EAR);
          break;
        case 'pusherVideoHandler':
          wx.$TUICallEngine._pusherVideoHandler(event);
          break;
        case 'toggleSwitchCamera':
          wx.$TUICallEngine.switchCamera(event);
          break;
        case 'switchAudioCall':
          wx.$TUICallEngine.switchCallMediaType(MEDIA_TYPE.AUDIO).then((res) => {
            this.data.config.type = MEDIA_TYPE.AUDIO;
            this.setData({
              config: this.data.config,
            });
            this.setSoundMode(AUDIO_PLAYBACK_DEVICE.EAR);
            this.triggerEvent('sendMessage', {
              message: res.data.message,
            });
          });
          break;
        default:
          break;
      }
    },

    // 设置用户的头像、昵称
    setSelfInfo(nickName, avatar) {
      return wx.$TUICallEngine.setSelfInfo(nickName, avatar);
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
      return wx.$TUICallEngine.getTim();
    },
    // 初始化TRTCCalling
    async init() {
      this._addTSignalingEvent();
      try {
        const res = await wx.$TUICallEngine.login({
          userID: this.data.config.userID,
          userSig: this.data.config.userSig,
        });
        return res;
      } catch (error) {
        throw new Error('TUICallEngine login failure', error);
      }
    },
    // 销毁 TUICallEngine
    destroyed() {
      this._removeTSignalingEvent();
      if (this.data.config.tim) {
        wx.$TUICallEngine.destroyed();
      } else {
        wx.$TUICallEngine.logout();
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
      wx.$TUICallEngine = TUICallEngine.createInstance({
        sdkAppID: this.data.config.sdkAppID,
      });
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
