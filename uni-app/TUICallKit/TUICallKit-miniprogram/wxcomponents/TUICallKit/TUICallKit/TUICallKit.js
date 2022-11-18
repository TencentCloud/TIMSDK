import TUICallEngine, { EVENT, MEDIA_TYPE, AUDIO_PLAYBACK_DEVICE, STATUS } from '../TUICallEngine/tuicall-engine-wx.js';

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
    isSponsor: false,  // 呼叫者身份 true为呼叫者 false为被叫者
    pusher: {}, // TRTC 本地流
    playerList: [], // TRTC 远端流
    playerProcess: {}, // 经过处理的的远端流(多人通话)
    isGroup: false, // 是否为多人通话
    remoteUsers: [], // 单人通话远程用户资料(不包含自身)
    allUsers: [],   // 多人通话用户资料(包含自身)
    sponsor: '',      // 主叫方
    screen: 'pusher', // 视屏通话中，显示大屏幕的流（只限1v1聊天
    soundMode: AUDIO_PLAYBACK_DEVICE.SPEAKER, // 声音模式 听筒/扬声器
    showToatTime: 0,   // 弹窗时长
    ownUserId: '',
  },


  methods: {
    resetUI() {
      // 收起键盘
      wx.hideKeyboard();
    },
    // 新的邀请回调事件
    handleNewInvitationReceived(event) {
      this.resetUI();
      this.data.config.type = event.data.inviteData.callType;
      // 判断是否为多人通话
      if (event.data.isFromGroup) {
        this.setData({
          isGroup: true,
          sponsor: event.data.sponsor,
        });
        // 将主叫方和被叫列表合并在一起 组成全部通话人数
        const newList = [...event.data.inviteeList, event.data.sponsor];
        // 获取用户信息
        this.getUserProfile(newList);
      } else {
        this.getUserProfile([event.data.sponsor]);
      }
      this.setData({
        config: this.data.config,
        callStatus: STATUS.CALLING,
        isSponsor: false,
      });
    },

    // 用户接听
    handleUserAccept(event) {
      // 主叫方则唤起通话页面
      if (this.data.isSponsor) {
        this.setData({
          callStatus: STATUS.CONNECTED,
        });
      }
    },

    // 远端用户进入通话
    handleUserEnter(res) {
      const newList = this.data.allUsers;
      // 多人通话
      if (this.data.isGroup) {
        // 改变远端用户信息中的isEnter属性
        for (let i = 0;i < newList.length;i++) {
          if (newList[i].userID === res.data.userID) {
            newList[i].isEnter = true;
          }
        }
      }
      this.setData({
        playerList: res.playerList,
        allUsers: newList,
      });
    },
    // 远端用户离开通话
    handleUserLeave(res) {
      // 多人通话
      if (this.data.isGroup) {
        wx.showToast({
          title: `${res.data.userID}离开通话`,
        });
        this.deleteUsers(this.data.allUsers, res.data.userID);
      }
      this.setData({
        playerList: res.data.playerList,
      });
    },
    // 用户数据更新
    handleUserUpdate(res) {
      this.handleNetStatus(res.data);
      const newplayer = {};
      const newres = res.data.playerList;
      // 多人通话
      if (this.data.isGroup) {
        // 处理远端流
        for (let i = 0;i < newres.length;i++) {
          const  { userID } = newres[i];
          newplayer[userID] = newres[i];
        }
      };
      this.setData({
        pusher: res.data.pusher,
        playerList: res.data.playerList,
        playerProcess: newplayer,
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
      if (this.data.isGroup) {
        this.deleteUsers(this.data.allUsers, event.data.invitee);
      }
      wx.showToast({
        title: `${event.data.invitee}已拒绝`,
      });
    },
    // 用户不在线
    handleNoResponse(event) {
      if (this.data.isGroup) {
        this.deleteUsers(this.data.allUsers, event.data.timeoutUserList);
      }
      wx.showToast({
        icon: 'none',
        title: `${event.data.timeoutUserList}无应答`,
      });
    },
    // 用户忙线
    handleLineBusy(event) {
      if (this.data.isGroup) {
        this.deleteUsers(this.data.allUsers, event.data.invitee);
      }
      this.showToast(event.data.invitee);
    },

    showToast(event) {
      this.setData({
        showToatTime: this.data.showToatTime + 500,
      });
      setTimeout(() => {
        wx.showToast({
          title: `${event}忙线中`,
        });
      }, this.data.showToatTime);
    },

    // 用户取消
    handleCallingCancel(event) {
      if (event.data.invitee !== this.data.config.userID) {
        wx.showToast({
          title: `${event.data.invitee}取消通话`,
        });
      }
      this.reset();
    },
    // 通话超时未应答
    handleCallingTimeout(event) {
      if (this.data.isGroup) {
        // 若是自身未应答 则不弹窗
        if (this.data.config.userID === event.data.timeoutUserList[0]) {
          this.reset();
          return;
        }
        const newList = this.deleteUsers(this.data.allUsers, event.data.timeoutUserList);
        this.setData({
          allUsers: newList,
        });
      }
      if (this.data.playerList.length === 0) {
        this.reset();
      }
      wx.showToast({
        title: `${event.data.timeoutUserList[0]}超时无应答`,
      });
    },
    handleCallingUser(userIDList) {
      const remoteUsers = [...this.data.remoteUsers];
      const userProfile = remoteUsers.filter(item => userIDList.some(userItem => `${userItem}` === item.userID));
      this.setData({
        remoteUsers: remoteUsers.filter(item => userIDList.some(userItem => userItem !== item.userID)),
      });
      let nick = '';
      for (let i = 0; i < userProfile.length; i++) {
        nick += `${userProfile[i].nick}、`;
      }
      return nick.slice(0, -1);
    },
    // 通话结束
    handleCallingEnd(event) {
      wx.showToast({
        title: '通话结束',
        duration: 800,
      });
      this.reset();
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
    },

    // 删除用户列表操作
    deleteUsers(usersList, userID) {
      // 若userID不是数组,则将其转换为数组
      if (!Array.isArray(userID)) {
        userID = [userID];
      }
      const list = usersList.filter(item => !userID.includes(item.userID));
      this.setData({
        allUsers: list,
      });
    },

    // 增加用户列表操作
    addUsers(usersList, userID) {
      // 若userID不是数组,则将其转换为数组
      if (!Array.isArray(userID)) {
        userID = [userID];
      }
      const newList = [...usersList, ...userID];
      return newList;
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
      // 用户更新数据
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
      // 自己发送消息
      wx.$TUICallEngine.on(EVENT.MESSAGE_SENT_BY_ME, this.messageSentByMe, this);
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
      // 用户更新数据
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
      // 自己发送消息
      wx.$TUICallEngine.off(EVENT.MESSAGE_SENT_BY_ME, this.messageSentByMe);
    },
    /**
     * C2C邀请通话，被邀请方会收到的回调
     * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
     *
     * @param userID 被邀请方
     * @param type 0-为之， 1-语音通话，2-视频通话
     */
    async call(params) {
      this.resetUI();
      if (this.data.callStatus !== STATUS.IDLE) {
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
      // 判断是否存在groupID
      if (!params.groupID) {
        wx.showToast({
          title: '群ID为空',
        });
        return;
      }
      // 查看群是否有效
      this.getTim().searchGroupByID(params.groupID)
        .then((imResponse) => {
        })
        .catch(() => {
          wx.showToast({
            title: '未搜索到该群',
          });
          return;
        });
      this.resetUI();
      if (this.data.callStatus !== STATUS.IDLE) {
        return;
      }
      wx.$TUICallEngine.groupCall({ userIDList: params.userIDList, type: params.type, groupID: params.groupID }).then((res) => {
        this.data.config.type = params.type;
        this.setData({
          pusher: res.pusher,
          config: this.data.config,
          callStatus: STATUS.CALLING,
          isSponsor: true,
          isGroup: true,
          sponsor: this.data.config.userID,
        });
        // 将自身的userID插入到邀请列表中,组成完整的用户信息
        const list = JSON.parse(JSON.stringify(params.userIDList));
        list.unshift(this.data.config.userID);
        // 获取用户信息
        this.getUserProfile(list);
      });
    },
    /**
     * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
     */
    async accept() {
      wx.$TUICallEngine.accept().then((res) => {
        this.setData({
          pusher: res.pusher,
          callStatus: STATUS.CONNECTED,
        });
        // 多人通话需要对自身位置进行修正,将其放到首位
        if (this.data.isGroup) {
          const newList = this.data.allUsers;
          for (let i = 0;i < newList.length;i++) {
            if (newList[i].userID === this.data.config.userID) {
              newList[i].isEnter = true;
              [newList[i], newList[0]] = [newList[0], newList[i]];
            }
          }
          this.setData({
            allUsers: newList,
          });
        }
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
      wx.$TUICallEngine.reject().then((res) => {
        this.reset();
      });
    },

    messageSentByMe(event) {
      const message = event.data.data;
      this.triggerEvent('sendMessage', {
        message,
      });
    },

    // xml层，是否开启扬声器
    setSoundMode(type) {
      this.setData({
        soundMode: wx.$TUICallEngine.selectAudioPlaybackDevice(type),
      });
    },

    // xml层，挂断
    async _hangUp() {
      await wx.$TUICallEngine.hangup();
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
        isGroup: false,
        soundMode: AUDIO_PLAYBACK_DEVICE.SPEAKER,
        pusher: {}, // TRTC 本地流
        playerList: [], // TRTC 远端流
        showToatTime: 0,
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
          });
          break;
        default:
          break;
      }
    },
    // 通话中的事件处理
    handleConnectedEvent(data) {
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
      // 修正用户资料
      this.modifyUser(imResponse.data);
    },

    // 修正用户资料
    modifyUser(userIDList) {
      const { sponsor } = this.data;
      if (this.data.isGroup) {
        // 多人通话需要将呼叫者放到第一位 isEnter的作用是区分用户是否进入房间
        for (let i = 0;i < userIDList.length;i++) {
          // 主叫方的标志位设置成true
          if (userIDList[i].userID === sponsor) {
            userIDList[i].isEnter = true;
            // 对主叫方位置进行修正 将其放到首位
            [userIDList[i], userIDList[0]] = [userIDList[0], userIDList[i]];
          } else {
          // 其他用户默认未进入房间 设置为false
            userIDList[i].isEnter = false;
          }
        }
        this.setData({
          allUsers: userIDList,
        });
      }
      this.setData({
        remoteUsers: userIDList,
      });
    },

    // 获取 tim 实例
    getTim() {
      return wx.$TUICallEngine.getTim();
    },
    // 初始化TRTCCalling
    async init() {
      this._addTSignalingEvent();
      const res = await wx.$TUICallEngine.init({
        userID: this.data.config.userID,
        userSig: this.data.config.userSig,
      });
      return res;
    },
    // 销毁 TUICallEngine
    destroyed() {
      this._removeTSignalingEvent();
      TUICallEngine.destroyInstance();
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
      this.setData({
        ownUserId: this.data.config.userID,
      });
      wx.$TUICallEngine = TUICallEngine.createInstance({
        tim: this.data.config.tim,
        sdkAppID: this.data.config.sdkAppID,
      });
      this.reset();
    },
    detached() {
      this.destroyed();
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
