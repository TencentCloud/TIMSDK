import EventEmitter from './utils/event.js';
import { EVENT, CALL_STATUS, MODE_TYPE, CALL_TYPE } from './common/constants.js';
import formateTime from './utils/formate-time';
import TSignaling from './node_module/tsignaling-wx';
import TRTC from './node_module/trtc-wx';
import TIM from './node_module/tim-wx-sdk';
import TSignalingClient from './TSignalingClient';
import TRTCCallingDelegate from './TRTCCallingDelegate';
import TRTCCallingInfo from './TRTCCallingInfo';

// TODO 组件挂载和模版方式分离，目前使用的方式，只能把TRTCCalling挂载在index页面上

const TAG_NAME = 'TRTCCalling';

class TRTCCalling {
  constructor(params) {
    this.data = {
      config: {
        sdkAppID: params.sdkAppID,
        userID: '',
        userSig: '',
        type: 1,
      },
    };

    this.initData();
    this.EVENT = EVENT;
    this.CALL_TYPE = CALL_TYPE;
    this._emitter = new EventEmitter();
    this.TRTC = new TRTC();
    if (params.tim) {
      this.tim = params.tim;
    } else {
      this.tim = TIM.create({
        SDKAppID: params.sdkAppID,
      });
    }
    if (!wx.$TSignaling) {
      wx.$TSignaling = new TSignaling({ SDKAppID: params.sdkAppID, tim: this.tim });
    }
    this.TSignalingClient = new TSignalingClient({ TSignaling: wx.$TSignaling });
    this.TRTCCallingDelegate = new TRTCCallingDelegate({ emitter: this._emitter });
    console.info(`${TAG_NAME} SDK Version:${TRTCCallingInfo.version}, SDKAppID:${params.sdkAppID}`);
  }

  initData() {
    const data = {
      callStatus: CALL_STATUS.IDLE, // 用户当前的通话状态
      soundMode: 'speaker', // 声音模式 听筒/扬声器
      active: false,
      invitation: { // 接收到的邀请
        inviteID: '',
        inviter: '',
        type: '',
        roomID: '',
      },
      startTalkTime: 0, // 开始通话的时间，用于计算1v1通话时长
      localUser: null, // 本地用户资料
      remoteUsers: [], // 远程用户资料
      timer: null, // 聊天时长定时器
      chatTimeNum: 0, // 聊天时长
      chatTime: '00:00:00', // 聊天时长格式化
      screen: 'pusher', // 视屏通话中，显示大屏幕的流（只限1v1聊天
      pusher: {}, // TRTC 本地流
      playerList: [], // TRTC 远端流
      roomID: '', // 房间ID
      groupInviteID: [], // 群聊无groupID时 多个C2C的 inviteID
      isSponsor: true, // true:呼叫者，false:被呼叫对象
      _unHandledInviteeList: [], // 未处理的被邀请着列表
      _connectUserIDList: [], // 通话中的用户ID（不包括自己）
      _isGroupCall: false, // 当前通话是否是群通话
      _groupID: '', // 群组ID
      _switchCallModeStatus: true, // 是否可以进行模式切换
    };
    this.data = { ...this.data, ...data };
  }

  // 收到视频与语音互相切换信令，处理逻辑
  async handleSwitchCallModeTSignaling(inviteID, inviteData) {
    const message = {
      inviteID,
      type: inviteData.call_type,
    };
    const otherMessage = {
      cmd: 'switchToVideo',
    };

    if (inviteData.call_type === CALL_TYPE.VIDEO) {
      // 兼容native switchToAudio 老版信令
      message.switch_to_audio_call = 'switch_to_audio_call';
      otherMessage.cmd = 'switchToAudio';
    }
    const callModeMessage = await this.TSignalingClient.accept(message, otherMessage);
    this.setSwitchCallModeStatus(false);
    this.handleCallMode(inviteData.call_type, callModeMessage);
  }

  // 音视频切换
  handleCallMode(callType, callModeMessage) {
    console.log(`${TAG_NAME}.handleCallMode - type`, callType);
    const enableCamera = callType !== CALL_TYPE.VIDEO;
    this.setPusherAttributesHandler({ enableCamera });
    if (enableCamera) {
      this.data.invitation.type = this.data.config.type = CALL_TYPE.VIDEO;
    } else {
      this.data.invitation.type = this.data.config.type = CALL_TYPE.AUDIO;
    }
    this.TRTCCallingDelegate.onCallMode({ type: this.data.config.type, message: callModeMessage.data.message });
    this.setSwitchCallModeStatus(true);
  }

  // 判断是否为音视频切换
  judgeSwitchCallMode(inviteData) {
    const isSwitchCallMode = (inviteData.switch_to_audio_call
                              && inviteData.switch_to_audio_call === 'switch_to_audio_call')
                              || inviteData.data && inviteData.data.cmd === 'switchToAudio'
                              || inviteData.data && inviteData.data.cmd === 'switchToVideo';
    return isSwitchCallMode;
  }

  // 新的邀请回调事件
  handleNewInvitationReceived(event) {
    console.log(TAG_NAME, 'onNewInvitationReceived', `callStatus：${this.data.callStatus === CALL_STATUS.CALLING || this.data.callStatus === CALL_STATUS.CONNECTED}, inviteID:${event.data.inviteID} inviter:${event.data.inviter} inviteeList:${event.data.inviteeList} data:${event.data.data}`);
    const { data: { inviter, inviteeList, data, inviteID, groupID } } = event;
    const inviteData = JSON.parse(data);

    // 此处判断inviteeList.length 大于2，用于在非群组下多人通话判断
    // userIDs 为同步 native 在使用无 groupID 群聊时的判断依据
    const isGroupCall = !!(groupID || inviteeList.length >= 2 || inviteData.data && inviteData.data.userIDs && inviteData.data.userIDs.length >= 2);
    let callEnd = false;
    // 此处逻辑用于通话结束时发出的invite信令
    // 群通话已结束时，room_id 不存在或者 call_end 为 0
    if (isGroupCall && (!inviteData.room_id || (inviteData.call_end && inviteData.call_end === 0))) {
      callEnd = true;
    }
    // 1v1通话挂断时，通知对端的通话结束和通话时长
    if (!isGroupCall && inviteData.call_end >= 0) {
      callEnd = true;
    }
    // 判断新的信令是否为结束信令
    if (callEnd) {
      // 群通话中收到最后挂断的邀请信令通知其他成员通话结束
      this.TRTCCallingDelegate.onCallEnd({ userID: inviter, callEnd: isGroupCall ? 0 : inviteData.call_end });
      this._reset();
      return;
    }

    // 收到音视频切换信令
    if (!this.data._isGroupCall && this.judgeSwitchCallMode(inviteData)) {
      this.handleSwitchCallModeTSignaling(inviteID, inviteData);
      return;
    }

    // 当前在通话中或在呼叫/被呼叫中，接收的新的邀请时，忙线拒绝
    if (this.data.callStatus === CALL_STATUS.CALLING || this.data.callStatus === CALL_STATUS.CONNECTED) {
      this.TSignalingClient.reject({ inviteID, type: data.call_type, lineBusy: 'line_busy' });
      return;
    }

    const callInfo = {
      _isGroupCall: !!isGroupCall,
      _groupID: groupID || '',
      _unHandledInviteeList: [...inviteeList, inviter],
    };
    if (isGroupCall && !groupID) {
      callInfo._unHandledInviteeList = [...inviteData.data.userIDs];
    }

    this.data.config.type = inviteData.call_type;
    this.data.invitation.inviteID = inviteID;
    this.data.invitation.inviter = inviter;
    this.data.invitation.type = inviteData.call_type;
    this.data.invitation.roomID = inviteData.room_id;
    this.data.isSponsor = false;
    this.data._connectUserIDList = [inviter];
    this.data._isGroupCall = callInfo._isGroupCall;
    this.data._groupID = callInfo._groupID;
    this.data._unHandledInviteeList = callInfo._unHandledInviteeList;
    // 被邀请人进入calling状态
    // 当前invitation未处理完成时，下一个invitation都将会忙线
    this._getUserProfile([inviter]);
    this._setCallStatus(CALL_STATUS.CALLING);
    console.log(`${TAG_NAME} NEW_INVITATION_RECEIVED invitation: `, this.data.callStatus, this.data.invitation);
    const newReceiveData = {
      sponsor: inviter,
      inviteeList,
      isFromGroup: isGroupCall,
      inviteID,
      inviteData: {
        version: inviteData.version,
        callType: inviteData.call_type,
        roomID: inviteData.room_id,
        callEnd: 0,
      },
    };
    this.TRTCCallingDelegate.onInvited(newReceiveData);
  }

  // 更新已进入的 inviteID 列表
  setInviteIDList(inviteID) {
    if (this.data.invitation.inviteID === inviteID || this.data.invitation.inviteID === '') {
      this.data.invitation.inviteID = '';
      return;
    }
    const list = [...this.data.groupInviteID];
    this.data.groupInviteID = list.filter(item => item !== inviteID);
  }

  // 发出的邀请收到接受的回调
  handleInviteeAccepted(event) {
    console.log(`${TAG_NAME} INVITEE_ACCEPTED inviteID:${event.data.inviteID} invitee:${event.data.invitee} data:`, event.data);
    const inviteData = JSON.parse(event.data.data);
    // 防止取消后，接收到远端接受信令
    if (this.data.callStatus === CALL_STATUS.IDLE) {
      this._reset();
      return;
    }
    // 收到邀请方接受音视频切换信令
    if (!this.data._isGroupCall && this.judgeSwitchCallMode(inviteData) && !this.data._switchCallModeStatus) {
      this.handleCallMode(this.data.invitation.type);
      return;
    }
    // 发起人进入通话状态从此处判断
    if (event.data.inviter === this._getUserID() && this.data.callStatus === CALL_STATUS.CALLING) {
      this._setCallStatus(CALL_STATUS.CONNECTED);
      this.TRTCCallingDelegate.onUserAccept(event.data.invitee);
    }
    this.setInviteIDList(event.data.inviteID);
    if (this._getGroupCallFlag()) {
      this._setUnHandledInviteeList(event.data.invitee);
      return;
    }
  }

  // 发出的邀请收到拒绝的回调
  handleInviteeRejected(event) {
    console.log(`${TAG_NAME} INVITEE_REJECTED inviteID:${event.data.inviteID} invitee:${event.data.invitee} data:${event.data.data}`);
    // 防止切换音视频对方不可用时，返回数据流向onLineBusy或onReject
    if (!this.data._isGroupCall && !this.data._switchCallModeStatus) {
      console.log(`${TAG_NAME}.onInviteeRejected - Audio and video switching is not available`);
      this.setSwitchCallModeStatus(true);
    }
    // 多人通话时处于通话中的成员都可以收到此事件，此处只需要发起邀请方需要后续逻辑处理
    if (event.data.inviter !== this._getUserID()) {
      return;
    }
    // 判断被呼叫方已经接入，后续拒绝不影响正常通话
    if (this.data.callStatus === CALL_STATUS.CONNECTED) {
      const userInPlayerListFlag = this.data.playerList.some(item => (item.userID === event.data.invitee));
      if (userInPlayerListFlag) {
        return;
      }
    }
    this.setInviteIDList(event.data.inviteID);
    const rejectData = JSON.parse(event.data.data);
    // 旧版信令判断忙线
    const oldLineBusy = rejectData.line_busy === '' || rejectData.line_busy === 'line_busy';
    // 新版信令判断忙线
    const newLineBusy = rejectData.data && rejectData.data.message && rejectData.data.message === 'lineBusy';
    if (oldLineBusy || newLineBusy) {
      this.TRTCCallingDelegate.onLineBusy({ inviteID: event.data.inviteID, invitee: event.data.invitee });
    } else {
      this.TRTCCallingDelegate.onReject({ inviteID: event.data.inviteID, invitee: event.data.invitee });
    }
    if (this._getGroupCallFlag()) {
      this._setUnHandledInviteeList(event.data.invitee, (list) => {
        // 所有邀请的用户都已处理
        if (list.length === 0) {
          // 1、如果还在呼叫在，发出结束通话事件
          const isCalling = this.data.callStatus === CALL_STATUS.CALLING;
          // 2、已经接受邀请，远端没有用户，发出结束通话事件
          const isPlayer = this.data.callStatus === CALL_STATUS.CONNECTED && this.data.playerList.length === 0;
          if (isCalling || isPlayer) {
            this.TRTCCallingDelegate.onCallEnd({ userID: this.data.config.userID, callEnd: 0 });
            this._reset();
          }
        }
      });
    } else {
      this.TRTCCallingDelegate.onCallEnd({ userID: this.data.config.userID, callEnd: 0 });
      this._reset();
    }
  }

  // 收到的邀请收到该邀请取消的回调
  handleInvitationCancelled(event) {
    // 防止用户已挂断，但接收到取消事件
    if (this.data.callStatus === CALL_STATUS.IDLE) {
      this._reset();
      return;
    }
    console.log(TAG_NAME, 'onInvitationCancelled', `inviteID:${event.data.inviteID} inviter:${event.data.invitee} data:${event.data.data}`);
    this._setCallStatus(CALL_STATUS.IDLE);
    this.TRTCCallingDelegate.onCancel({ inviteID: event.data.inviteID, invitee: event.data.invitee });
    this.TRTCCallingDelegate.onCallEnd({ userID: this.data.config.userID, callEnd: 0 });
    this.setInviteIDList(event.data.inviteID);
    this._reset();
  }

  // 收到的邀请收到该邀请超时的回调
  handleInvitationTimeout(event) {
    console.log(TAG_NAME, 'onInvitationTimeout', `data:${JSON.stringify(event)} inviteID:${event.data.inviteID} inviteeList:${event.data.inviteeList}`);
    const { groupID = '', inviteID, inviter, inviteeList, isSelfTimeout } = event.data;
    // 防止用户已挂断，但接收到超时事件后的，抛出二次超时事件
    if (this.data.callStatus === CALL_STATUS.IDLE) {
      this._reset();
      return;
    }
    this.setInviteIDList(event.data.inviteID);
    // 自己发起通话且先超时，即对方不在线，isSelfTimeout是对方是否在线的标识
    if (isSelfTimeout && inviter === this._getUserID()) {
      this.TRTCCallingDelegate.onNoResp({
        groupID,
        inviteID,
        sponsor: inviter,
        timeoutUserList: inviteeList,
      });
      // 若在呼叫中，且全部用户都无应答
      if (this.data.callStatus !== CALL_STATUS.CONNECTED) {
        this.TRTCCallingDelegate.onCallEnd({ userID: inviter, callEnd: 0 });
        this._reset();
      }
      return;
    }

    // 被邀请方在线超时接入侧序监听此事件做相应的业务逻辑处理,多人通话时，接入侧需要通过此事件处理某个用户超时逻辑
    this.TRTCCallingDelegate.onTimeout({
      groupID,
      inviteID,
      sponsor: inviter,
      timeoutUserList: inviteeList,
    });
    if (this._getGroupCallFlag()) {
      // 群通话逻辑处理
      const unHandledInviteeList = this.data._unHandledInviteeList;
      const restInviteeList = [];
      unHandledInviteeList.forEach((invitee) => {
        if (inviteeList.indexOf(invitee) === -1) {
          restInviteeList.push(invitee);
        }
      });
      this.data._unHandledInviteeList = restInviteeList;
      // restInviteeList 为空且无远端流
      if (restInviteeList.length === 0 && this.data.playerList.length === 0) {
        if (this.data.callStatus === CALL_STATUS.CONNECTED) {
          // 发消息到群组，结束本次通话
          this.lastOneHangup({
            userIDList: [inviter],
            callType: this.data.config.type,
            callEnd: 0,
          });
          return;
        }
        this.TRTCCallingDelegate.onCallEnd({ userID: inviter, callEnd: 0 });
        this._reset();
      }
    } else {
      // 1v1通话被邀请方超时
      this.TRTCCallingDelegate.onCallEnd({ userID: inviter, callEnd: 0 });
      this._reset();
    }
    // 用inviteeList进行判断，是为了兼容多人通话
    if (inviteeList.includes(this._getUserID())) {
      this._setCallStatus(CALL_STATUS.IDLE);
    }
  }

  // SDK Ready 回调
  handleSDKReady() {
    console.log(TAG_NAME, 'TSignaling SDK ready');
    this.TRTCCallingDelegate.onSdkReady({ message: 'SDK ready' });
    const promise = this.tim.getMyProfile();
    promise.then((imResponse) => {
      this.data.localUser = imResponse.data;
    }).catch((imError) => {
      console.warn('getMyProfile error:', imError); // 获取个人资料失败的相关信息
    });
  }

  // 被踢下线
  handleKickedOut() {
    this.hangup();
    this.TRTCCallingDelegate.onKickedOut({ message: 'kicked out' });
  }

  // 增加 tsignaling 事件监听
  _addTSignalingEvent() {
    // 新的邀请回调事件
    wx.$TSignaling.on(TSignaling.EVENT.NEW_INVITATION_RECEIVED, this.handleNewInvitationReceived, this);
    // 发出的邀请收到接受的回调
    wx.$TSignaling.on(TSignaling.EVENT.INVITEE_ACCEPTED, this.handleInviteeAccepted, this);
    // 发出的邀请收到拒绝的回调
    wx.$TSignaling.on(TSignaling.EVENT.INVITEE_REJECTED, this.handleInviteeRejected, this);
    // 收到的邀请收到该邀请取消的回调
    wx.$TSignaling.on(TSignaling.EVENT.INVITATION_CANCELLED, this.handleInvitationCancelled, this);
    // 收到的邀请收到该邀请超时的回调
    wx.$TSignaling.on(TSignaling.EVENT.INVITATION_TIMEOUT, this.handleInvitationTimeout, this);
    // SDK Ready 回调
    wx.$TSignaling.on(TSignaling.EVENT.SDK_READY, this.handleSDKReady, this);
    // 被踢下线
    wx.$TSignaling.on(TSignaling.EVENT.KICKED_OUT, this.handleKickedOut, this);
  }

  // 取消 tsignaling 事件监听
  _removeTSignalingEvent() {
    // 新的邀请回调事件
    wx.$TSignaling.off(TSignaling.EVENT.NEW_INVITATION_RECEIVED);
    // 发出的邀请收到接受的回调
    wx.$TSignaling.off(TSignaling.EVENT.INVITEE_ACCEPTED);
    // 发出的邀请收到拒绝的回调
    wx.$TSignaling.off(TSignaling.EVENT.INVITEE_REJECTED);
    // 收到的邀请收到该邀请取消的回调
    wx.$TSignaling.off(TSignaling.EVENT.INVITATION_CANCELLED);
    // 收到的邀请收到该邀请超时的回调
    wx.$TSignaling.off(TSignaling.EVENT.INVITATION_TIMEOUT);
    // SDK Ready 回调
    wx.$TSignaling.off(TSignaling.EVENT.SDK_READY);
    // 被踢下线
    wx.$TSignaling.off(TSignaling.EVENT.KICKED_OUT);
  }

  // 远端用户加入此房间
  async onRemoteUserJoin(event) {
    // userID 是加入的用户 ID
    const { userID, userList, playerList } = event.data;
    console.log(TAG_NAME, 'REMOTE_USER_JOIN', event, userID);
    this.data.playerList = playerList.length > 0 ? await this.getUserProfile(playerList) : this.data.playerList;
    this.data._connectUserIDList = [...this.data._connectUserIDList, userID];
    if (!this.data.startTalkTime) {
      this.data.startTalkTime = Date.now();
    }
    this.TRTCCallingDelegate.onUserEnter({ userID: event.data.userID, playerList: this.data.playerList });
    console.log(TAG_NAME, 'REMOTE_USER_JOIN', 'playerList:', this.data.playerList, 'userList:', userList);
  }

  // 远端的用户离开
  async onRemoteUserLeave(event) {
    // userID 是离开的用户 ID
    const { userID, userList, playerList } = event.data;
    console.log(TAG_NAME, 'REMOTE_USER_LEAVE', event, event.data.userID);
    if (userID) {
      // this.data.playerList = await this.getUserProfile(playerList)
      this.data.playerList = this.data.playerList.filter(item => item.userID !== userID);
      // 群组或多人通话模式下，有用户离开时，远端还有用户，则只下发用户离开事件
      if (playerList.length > 0) {
        this.TRTCCallingDelegate.onUserLeave({ userID, playerList: this.data.playerList });
        return;
      }
      // 无远端流，需要发起最后一次邀请信令， 此处逻辑是为与native对齐，正确操作应该放在hangup中处理
      this.lastOneHangup({
        userIDList: [event.data.userID],
        callType: this.data.config.type,
        callEnd: Math.round((Date.now() - this.data.startTalkTime) / 1000),
      });
      this.data.startTalkTime = 0;
    }
    console.log(TAG_NAME, 'REMOTE_USER_LEAVE', 'playerList:', playerList, 'userList:', userList);
  }

  // 本地网络相关状态变更。
  onLocalNetStateUpdate(event) {
    // 这里会返回更新后的 pusherAttributes，上面有个属性是 netStatus 对应网络状态的对象
    // 其中 netQualityLevel 对应网络状态的好坏，1 代表最好，数字越大代表网络越差
    const { netStatus } = event.data.pusher;
    console.log(TAG_NAME, 'onLocalNetStateUpdate', netStatus);
    this.data.pusher = event.data.pusher;
    this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
  }

  // 远端用户网络相关状态变更。
  async onRemoteNetStateUpdate(event) {
    // 这里会返回更新后的 playerList，上面有个属性是 netStatus 对应网络状态的对象
    // 其中 netQualityLevel 对应网络状态的好坏，1 代表最好，数字越大代表网络越差
    const { playerList } = event.data;
    console.log(TAG_NAME, 'onRemoteNetStateUpdate', playerList);
    // this.data.playerList = await this.getUserProfile(playerList)
    this.data.playerList = this._updateUserProfile(this.data.playerList, playerList);
    this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
  }

  // 本地推流出现错误、渲染错误事件等。
  onError(event) {
    // 您可以监听一些预期之外的错误信息
    console.log(TAG_NAME, 'onError', event);
  }

  // 远端用户推送视频
  onRemoteVideoAdd(event) {
    console.log('* room REMOTE_VIDEO_ADD', event);
    const { player } = event.data;
    // 开始播放远端的视频流，默认是不播放的
    this.setPlayerAttributesHandler(player, { muteVideo: false });
  }

  // 远端用户取消推送视频
  onRemoteVideoRemove(event) {
    console.log('* room REMOTE_VIDEO_REMOVE', event);
    const { player } = event.data;
    this.setPlayerAttributesHandler(player, { muteVideo: true });
  }

  // 远端用户推送音频
  async onRemoteAudioAdd(event) {
    console.log('* room REMOTE_AUDIO_ADD', event);
    const players = await this.getUserProfile([event.data.player]);
    this.setPlayerAttributesHandler(players[0], { muteAudio: false });
  }

  // 远端用户取消推送音频
  onRemoteAudioRemove(event) {
    console.log('* room REMOTE_AUDIO_REMOVE', event);
    const { player } = event.data;
    this.setPlayerAttributesHandler(player, { muteAudio: true });
  }

  // 远端用户更新音频
  async onRemoteAudioVolumeUpdate(event) {
    console.log('* room REMOTE_AUDIO_VOLUME_UPDATE', event);
    const { playerList } = event.data;
    // this.data.playerList = await this.getUserProfile(playerList)
    this.data.playerList = this._updateUserProfile(this.data.playerList, playerList);
    this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
  }

  // 本地更新音频
  onLocalAudioVolumeUpdate(event) {
    // console.log('* room LOCAL_AUDIO_VOLUME_UPDATE', event)
    const { pusher } = event.data;
    this.data.pusher = pusher;
    this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
  }

  // 增加 TRTC 事件监听
  _addTRTCEvent() {
    // 远端用户进入房间
    this.TRTC.on(this.TRTC.EVENT.REMOTE_USER_JOIN, this.onRemoteUserJoin, this);
    // 远端的用户离开
    this.TRTC.on(this.TRTC.EVENT.REMOTE_USER_LEAVE, this.onRemoteUserLeave, this);
    // 本地网络相关状态变更
    this.TRTC.on(this.TRTC.EVENT.LOCAL_NET_STATE_UPDATE, this.onLocalNetStateUpdate, this);
    // 远端用户网络相关状态变更
    this.TRTC.on(this.TRTC.EVENT.REMOTE_NET_STATE_UPDATE, this.onRemoteNetStateUpdate, this);
    // 本地推流出现错误、渲染错误事件等。
    this.TRTC.on(this.TRTC.EVENT.ERROR, this.onError, this);
    // 远端用户推送视频
    this.TRTC.on(this.TRTC.EVENT.REMOTE_VIDEO_ADD, this.onRemoteVideoAdd, this);
    // 远端用户取消推送视频
    this.TRTC.on(this.TRTC.EVENT.REMOTE_VIDEO_REMOVE, this.onRemoteVideoRemove, this);
    // 远端用户推送音频
    this.TRTC.on(this.TRTC.EVENT.REMOTE_AUDIO_ADD, this.onRemoteAudioAdd, this);
    // 远端用户取消推送音频
    this.TRTC.on(this.TRTC.EVENT.REMOTE_AUDIO_REMOVE, this.onRemoteAudioRemove, this);
    // 远端用户更新音频
    this.TRTC.on(this.TRTC.EVENT.REMOTE_AUDIO_VOLUME_UPDATE, this.onRemoteAudioVolumeUpdate, this);
    // 本地更新音频
    this.TRTC.on(this.TRTC.EVENT.LOCAL_AUDIO_VOLUME_UPDATE, this.onLocalAudioVolumeUpdate, this);
  }

  // 取消 TRTC 事件监听
  _removeTRTCEvent() {
    // 远端用户进入房间
    this.TRTC.off(this.TRTC.EVENT.REMOTE_USER_JOIN, this.onRemoteUserJoin);
    // 远端的用户离开
    this.TRTC.off(this.TRTC.EVENT.REMOTE_USER_LEAVE, this.onRemoteUserLeave);
    // 本地网络相关状态变更
    this.TRTC.off(this.TRTC.EVENT.LOCAL_NET_STATE_UPDATE, this.onLocalNetStateUpdate);
    // 远端用户网络相关状态变更
    this.TRTC.off(this.TRTC.EVENT.REMOTE_NET_STATE_UPDATE, this.onRemoteNetStateUpdate);
    // 本地推流出现错误、渲染错误事件等。
    this.TRTC.off(this.TRTC.EVENT.ERROR, this.onError);
    // 远端用户推送视频
    this.TRTC.off(this.TRTC.EVENT.REMOTE_VIDEO_ADD, this.onRemoteVideoAdd);
    // 远端用户取消推送视频
    this.TRTC.off(this.TRTC.EVENT.REMOTE_VIDEO_REMOVE, this.onRemoteVideoRemove);
    // 远端用户推送音频
    this.TRTC.off(this.TRTC.EVENT.REMOTE_AUDIO_ADD, this.onRemoteAudioAdd);
    // 远端用户取消推送音频
    this.TRTC.off(this.TRTC.EVENT.REMOTE_AUDIO_REMOVE, this.onRemoteAudioRemove);
    // 远端用户更新音频
    this.TRTC.off(this.TRTC.EVENT.REMOTE_AUDIO_VOLUME_UPDATE, this.onRemoteAudioVolumeUpdate);
    // 本地更新音频
    this.TRTC.off(this.TRTC.EVENT.LOCAL_AUDIO_VOLUME_UPDATE, this.onLocalAudioVolumeUpdate);
  }

  // TRTC 初始化
  initTRTC() {
    // pusher 初始化参数
    const pusherConfig = {
      beautyLevel: 5,
    };
    const pusher = this.TRTC.createPusher(pusherConfig);
    this.data.pusher = pusher.pusherAttributes;
  }

  // 进入房间
  enterRoom(options) {
    const { roomID } = options;
    const config = Object.assign(this.data.config, {
      roomID,
      enableMic: true,
      autopush: true,
      enableAgc: true,
      enableAns: true,
      enableCamera: options.callType === CALL_TYPE.VIDEO, // 进房根据呼叫类型判断是否开启摄像头
    });
    if (this.data._unHandledInviteeList.length > 0) {
      this._setUnHandledInviteeList(this.data.config.userID);
    }
    this.data.pusher = this.TRTC.enterRoom(config);
    this.TRTC.getPusherInstance().start(); // 开始推流
  }

  // 退出房间
  exitRoom() {
    const result = this.TRTC.exitRoom();
    this.data.pusher = result.pusher;
    this.data.playerList = result.playerList;
    this.data._unHandledInviteeList = [];
    this.initTRTC();
  }

  // 设置 pusher 属性
  setPusherAttributesHandler(options) {
    this.data.pusher = this.TRTC.setPusherAttributes(options);
    this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
  }

  // 设置某个 player 属性
  async setPlayerAttributesHandler(player, options) {
    const playerList = this.TRTC.setPlayerAttributes(player.streamID, options);
    console.warn('setPlayerAttributesHandler', playerList);
    // this.data.playerList = await this.getUserProfile(playerList)
    this.data.playerList = playerList.length > 0 ? this._updateUserProfile(this.data.playerList, playerList) : this.data.playerList;
    this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
  }

  // 是否订阅某一个player Audio
  _mutePlayerAudio(event) {
    const player = event.currentTarget.dataset.value;
    if (player.hasAudio && player.muteAudio) {
      this.setPlayerAttributesHandler(player, { muteAudio: false });
      return;
    }
    if (player.hasAudio && !player.muteAudio) {
      this.setPlayerAttributesHandler(player, { muteAudio: true });
      return;
    }
  }

  // 订阅 / 取消订阅某一个player Audio
  _mutePlayerVideo(event) {
    const player = event.currentTarget.dataset.value;
    if (player.hasVideo && player.muteVideo) {
      this.setPlayerAttributesHandler(player, { muteVideo: false });
      return;
    }
    if (player.hasVideo && !player.muteVideo) {
      this.setPlayerAttributesHandler(player, { muteVideo: true });
      return;
    }
  }

  // 订阅 / 取消订阅 Audio
  _pusherAudioHandler() {
    if (this.data.pusher.enableMic) {
      this.setPusherAttributesHandler({ enableMic: false });
      this.TRTC.getPusherInstance().setMICVolume({ volume: 0 });
    } else {
      this.setPusherAttributesHandler({ enableMic: true });
      this.TRTC.getPusherInstance().setMICVolume({ volume: 100 });
    }
  }

  // 订阅 / 取消订阅 Video
  _pusherVideoHandler() {
    if (this.data.pusher.enableCamera) {
      this.setPusherAttributesHandler({ enableCamera: false });
    } else {
      this.setPusherAttributesHandler({ enableCamera: true });
    }
  }

  /**
   * 登录IM接口，所有功能需要先进行登录后才能使用
   *
   */
  async login(data) {
    wx.$TSignaling.setLogLevel(0);
    this.data.config.userID = data.userID;
    this.data.config.userSig = data.userSig;
    return wx.$TSignaling.login({
      userID: data.userID,
      userSig: data.userSig,
    }).then((res) => {
      console.log(TAG_NAME, 'login', 'IM login success', res);
      this._reset();
      this._addTSignalingEvent();
      this._addTRTCEvent();
      this.initTRTC();
    });
  }

  /**
   * 登出接口，登出后无法再进行拨打操作
   */
  async logout() {
    if (this.data.callStatus === CALL_STATUS.CALLING || this.data.callStatus === CALL_STATUS.CONNECTED) {
      if (this.data.isSponsor) {
        await this.hangup();
      } else {
        await this.reject();
      }
    }
    this._reset();
    wx.$TSignaling.logout({
      userID: this.data.config.userID,
      userSig: this.data.config.userSig,
    }).then((res) => {
      console.log(TAG_NAME, 'logout', 'IM logout success');
      this._removeTSignalingEvent();
      this._removeTRTCEvent();
      return res;
    })
      .catch((err) => {
        console.error(TAG_NAME, 'logout', 'IM logout failure');
        throw new Error(err);
      });
  }

  /**
   * 监听事件
   *
   * @param eventCode 事件名
   * @param handler 事件响应回调
   */
  on(eventCode, handler, context) {
    this._emitter.on(eventCode, handler, context);
  }

  /**
   * 取消监听事件
   *
   * @param eventCode 事件名
   * @param handler 事件响应回调
   */
  off(eventCode, handler) {
    this._emitter.off(eventCode, handler);
  }

  /**
   * C2C邀请通话，被邀请方会收到的回调
   * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
   *
   * @param userID 被邀请方
   * @param type 0-为之， 1-语音通话，2-视频通话
   */
  async call(params) {
    const { userID, type } = params;
    // 生成房间号，拼接URL地址 TRTC-wx roomID 超出取值范围1～4294967295
    const roomID = Math.floor(Math.random() * 4294967294 + 1); // 随机生成房间号
    this.enterRoom({ roomID, callType: type });
    try {
      const res = await this.TSignalingClient.invite({ roomID, ...params });
      console.log(`${TAG_NAME} call(userID: ${userID}, type: ${type}) success, ${res}`);
      // 发起人进入calling状态
      this.data.config.type = type;
      this.data.invitation.inviteID = res.inviteID;
      this.data.invitation.inviter = this.data.config.userID;
      this.data.invitation.type = type;
      this.data.invitation.roomID = roomID;
      this.data.isSponsor = true;
      this.data._unHandledInviteeList = [userID];
      this._setCallStatus(CALL_STATUS.CALLING);
      this._getUserProfile([userID]);
      return {
        data: res.data,
        pusher: this.data.pusher,
      };
    } catch (error) {
      console.log(`${TAG_NAME} call(userID:${userID},type:${type}) failed', error: ${error}`);
    }
  }

  /**
   * IM群组邀请通话，被邀请方会收到的回调
   * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到的回调
   *
   * @param userIDList 邀请列表
   * @param type 1-语音通话，2-视频通话
   * @param groupID IM群组ID
   */
  async groupCall(params) {
    const { type } = params;
    // 生成房间号，拼接URL地址 TRTC-wx roomID 超出取值范围1～4294967295
    const roomID = this.data.roomID || Math.floor(Math.random() * 4294967294 + 1); // 随机生成房间号
    this.enterRoom({ roomID, callType: type });
    try {
      let inviterInviteID = [...this.data.invitation.inviteID];
      const res = await this.TSignalingClient.inviteGroup({ roomID, ...params });
      if (!params.groupID) {
        if (res.code === 0) {
          res.data.map((item) => {
            inviterInviteID = [...inviterInviteID, item.inviteID];
            return item;
          });
        }
      }
      this.data.config.type = params.type;
      if (params.groupID) {
        this.data.invitation.inviteID = res.inviteID;
      } else {
        this.data.groupInviteID = inviterInviteID;
      }
      this.data.invitation.inviter = this.data.config.userID;
      this.data.invitation.type = type;
      this.data.invitation.roomID = roomID;
      this.data.isSponsor = true;
      this.data._isGroupCall = true;
      this.data._groupID = params.groupID || '';
      this.data._unHandledInviteeList = [...params.userIDList];

      this._setCallStatus(CALL_STATUS.CALLING);
      this._getUserProfile(params.userIDList);

      console.log(TAG_NAME, 'inviteInGroup OK', res);
      return {
        data: res.data,
        pusher: this.data.pusher,
      };
    } catch (error) {
      console.log(TAG_NAME, 'inviteInGroup failed', error);
    }
  }

  /**
   * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
   */
  async accept() {
    // 拼接pusherURL进房
    console.log(TAG_NAME, 'accept() inviteID: ', this.data.invitation.inviteID);
    if (this.data.callStatus === CALL_STATUS.IDLE) {
      throw new Error('The call was cancelled');
    }
    if (this.data.callStatus === CALL_STATUS.CALLING) {
      this.enterRoom({ roomID: this.data.invitation.roomID, callType: this.data.config.type });
      // 被邀请人进入通话状态
      this._setCallStatus(CALL_STATUS.CONNECTED);
    }

    const acceptRes = await this.TSignalingClient.accept({
      inviteID: this.data.invitation.inviteID,
      type: this.data.config.type,
    });
    if (acceptRes.code === 0) {
      console.log(TAG_NAME, 'accept OK');
      if (this._getGroupCallFlag()) {
        this._setUnHandledInviteeList(this._getUserID());
      }
      return {
        message: acceptRes.data.message,
        pusher: this.data.pusher,
      };
    }
    console.error(TAG_NAME, 'accept failed', acceptRes);
    return acceptRes;
  }

  /**
   * 当您作为被邀请方收到的回调时，可以调用该函数拒绝来电
   */
  async reject() {
    if (this.data.invitation.inviteID) {
      const rejectRes = await this.TSignalingClient.reject({
        inviteID: this.data.invitation.inviteID,
        type: this.data.config.type,
      });
      if (rejectRes.code === 0) {
        console.log(TAG_NAME, 'reject OK', rejectRes);
        this._reset();
      }
      console.log(TAG_NAME, 'reject failed', rejectRes);
      return rejectRes;
    }
    console.warn(`${TAG_NAME} 未收到邀请，无法拒绝`);
    return '未收到邀请，无法拒绝';
  }

  /**
   * 当您处于通话中，可以调用该函数挂断通话
   * 当您发起通话时，可用去了取消通话
   */
  async hangup() {
    console.log(TAG_NAME, 'hangup.isSponsor', this.data.isSponsor); // 是否是邀请者
    let cancelRes = null;
    if (this.data.isSponsor && this.data.callStatus === CALL_STATUS.CALLING) {
      const cancelInvite = [...this.data.groupInviteID];
      if (this.data.invitation.inviteID) {
        cancelInvite.push(this.data.invitation.inviteID);
      }
      console.log(TAG_NAME, 'cancel() inviteID: ', cancelInvite);
      cancelRes = await this.TSignalingClient.cancel({
        inviteIDList: cancelInvite,
        callType: this.data.invitation.type,
      });
      this.TRTCCallingDelegate.onCallEnd({ message: cancelRes[0].data.message });
    }
    this.exitRoom();
    this._reset();
    return cancelRes;
  }

  // 最后一位离开房间的用户发送该信令 (http://tapd.oa.com/Qcloud_MLVB/markdown_wikis/show/#1210146251001590857)
  async lastOneHangup(params) {
    const isGroup = this._getGroupCallFlag();
    const res = await this.TSignalingClient.lastOneHangup({ isGroup, groupID: this.data._groupID, ...params });
    this.TRTCCallingDelegate.onCallEnd({ message: res.data.message });
    this._reset();
  }

  // 获取是否为群聊
  _getGroupCallFlag() {
    return this.data._isGroupCall;
  }

  // 更新未进入房间用户列表
  _setUnHandledInviteeList(userID, callback) {
    // 使用callback防御列表更新时序问题
    const list = [...this.data._unHandledInviteeList];
    const unHandleList = list.filter(item => item !== userID);
    this.data._unHandledInviteeList = unHandleList;
    callback && callback(unHandleList);
  }

  // 获取用户ID
  _getUserID() {
    return this.data.config.userID;
  }

  // 设置通话状态，若在通话中开启计时器
  _setCallStatus(status) {
    console.log('进入callStatus', status);
    this.data.callStatus = status;
    switch (status) {
      case CALL_STATUS.CONNECTED:
        if (this.data.timer) {
          return;
        }
        this.data.timer = setInterval(() => {
          this.data.chatTime = formateTime(this.data.chatTimeNum);
          this.data.chatTimeNum += 1;
          this.data.pusher.chatTime = this.data.chatTime;
          this.data.pusher.chatTimeNum = this.data.chatTimeNum;
          this.TRTCCallingDelegate.onUserUpdate({ pusher: this.data.pusher, playerList: this.data.playerList });
        }, 1000);
        break;
      case CALL_STATUS.IDLE:
        clearInterval(this.data.timer);
        this.data.timer = null;
        this.data.chatTime = '00:00:00';
        this.data.chatTimeNum = 0;
        break;
    }
  }

  // 通话结束，重置数据
  _reset() {
    console.log(TAG_NAME, ' _reset()');
    this._setCallStatus(CALL_STATUS.IDLE);
    this.data.config.type = 1;
    // 清空状态
    this.initData();
  }

  /**
   *
   * @param userID 远端用户id
   */
  startRemoteView(userID) {
    this.data.playerList.forEach((stream) => {
      if (stream.userID === userID) {
        stream.muteVideo = false;
        console.log(`${TAG_NAME}, startRemoteView(${userID})`);
        return;
      }
    });
  }

  /**
   * 当您收到 onUserVideoAvailable 回调为false时，可以停止渲染数据
   *
   * @param userID 远端用户id
   */
  stopRemoteView(userID) {
    this.data.playerList.forEach((stream) => {
      if (stream.userID === userID) {
        stream.muteVideo = true;
        console.log(`${TAG_NAME}, stopRemoteView(${userID})`);
        return;
      }
    });
  }

  /**
   * 您可以调用该函数开启摄像头
   */
  openCamera() {
    if (!this.data.pusher.enableCamera) {
      this._pusherVideoHandler();
    }
    console.log(`${TAG_NAME}, openCamera() pusher: ${this.data.pusher}`);
  }

  /**
   * 您可以调用该函数关闭摄像头
   * 处于通话中的用户会收到回调
   */
  closeCamera() {
    if (this.data.pusher.enableCamera) {
      this._pusherVideoHandler();
    }
    console.log(`${TAG_NAME}, closeCamera() pusher: ${this.data.pusher}`);
  }

  /**
   * 切换前后置摄像头
   */
  switchCamera() {
    if (this.data.callStatus !== CALL_STATUS.CONNECTED) {
      const targetPos = this.data.pusher.frontCamera === 'front' ? 'back' : 'front';
      this.setPusherAttributesHandler({ frontCamera: targetPos });
    } else {
      this.TRTC.getPusherInstance().switchCamera();
    }
    console.log(`${TAG_NAME}, switchCamera(), frontCamera${this.data.pusher.frontCamera}`);
  }

  /**
   * 是否开启扬声器
   *
   * @param isHandsFree true:扬声器 false:听筒
   */
  setHandsFree(isHandsFree) {
    this.data.soundMode = isHandsFree ? 'speaker' : 'ear';
    console.log(`${TAG_NAME}, setHandsFree() result: ${this.data.soundMode}`);
    return this.data.soundMode;
  }

  /**
     *  视频通话切换语音通话
     */
  async switchAudioCall() {
    if (this._isGroupCall) {
      console.warn(`${TAG_NAME}.switchToAudioCall is not applicable to groupCall.`);
      return;
    }
    if (this.data.invitation.type === CALL_TYPE.AUDIO) {
      console.warn(`${TAG_NAME} Now the call mode is audio call.`);
      return;
    }
    if (!this.data._switchCallModeStatus) {
      console.warn(`${TAG_NAME} audio and video call switching.`);
      return;
    }
    this.setSwitchCallModeStatus(false);
    this.setPusherAttributesHandler({ enableCamera: false });
    return this.TSignalingClient.switchCallMode({
      userID: this.data._unHandledInviteeList[0] || this.data.playerList[0].userID,
      callType: this.data.invitation.type,
      roomID: this.data.invitation.roomID,
      mode: MODE_TYPE.AUDIO,
    });
  }

  // 设置切换通话模式状态
  setSwitchCallModeStatus(value) {
    this.data._switchCallModeStatus = value;
  }

  /**
   *  音频通话切换视频通话
   */
  async switchVideoCall() {
    if (this._isGroupCall) {
      console.warn(`${TAG_NAME}.switchToVideoCall is not applicable to groupCall.`);
      return;
    }
    if (this.data.invitation.type === CALL_TYPE.VIDEO) {
      console.warn(`${TAG_NAME} Now the call mode is video call.`);
      return;
    }
    if (!this.data._switchCallModeStatus) {
      console.warn(`${TAG_NAME} audio and video call switching.`);
      return;
    }
    this.setSwitchCallModeStatus(false);
    this.setPusherAttributesHandler({ enableCamera: true });
    return this.TSignalingClient.switchCallMode({
      userID: this.data.playerList[0].userID,
      callType: this.data.invitation.type,
      roomID: this.data.invitation.roomID,
      mode: MODE_TYPE.VIDEO,
    });
  }

  // xml层，是否开启扬声器
  _toggleSoundMode() {
    let soundMode = '';
    if (this.data.soundMode === 'speaker') {
      soundMode = this.setHandsFree(false);
    } else {
      soundMode = this.setHandsFree(true);
    }
    return soundMode;
  }

  // xml层，挂断
  _hangUp() {
    this.hangup();
  }

  // live-pusher 改变状态事件处理
  _pusherStateChangeHandler(event) {
    this.TRTC.pusherEventHandler(event);
  }

  // live-player 状态事件处理
  _playerStateChange(event) {
    // console.log(TAG_NAME, '_playerStateChange', event)
    this._emitter.emit(EVENT.REMOTE_STATE_UPDATE, event);
  }

  // live-player 麦克风采集的音量大小事件处理
  _playerAudioVolumeNotify(event) {
    if (this.data.playerList.length > 0) {
      this.TRTC.playerAudioVolumeNotify(event);
    }
  }

  // live-pusher 麦克风采集的音量大小事件处理
  _pusherAudioVolumeNotify(event) {
    this.TRTC.pusherAudioVolumeNotify(event);
  }
  // 更新用户信息
  _updateUserProfile(userList, newUserList) {
    if (newUserList.length === 0 || userList.length === 0) {
      return newUserList;
    }
    const playerList = newUserList.map((item) => {
      const newItem = item;
      const itemProfile = userList.filter(imItem => imItem.userID === item.userID);
      newItem.avatar = itemProfile[0] && itemProfile[0].avatar ? itemProfile[0].avatar : '';
      newItem.nick = itemProfile[0] && itemProfile[0].nick ? itemProfile[0].nick : '';
      return newItem;
    });
    return playerList;
  }
  // 获取用户信息
  _getUserProfile(userList) {
    const promise = this.tim.getUserProfile({ userIDList: userList });
    promise.then((imResponse) => {
      console.log('getUserProfile success', imResponse);
      console.log(imResponse.data);
      this.data.remoteUsers = imResponse.data;
    }).catch((imError) => {
      console.warn('getUserProfile error:', imError); // 获取其他用户资料失败的相关信息
    });
  }
  // 获取用户信息
  async getUserProfile(userList) {
    if (userList.length === 0) {
      return [];
    }
    const list = userList.map(item => item.userID);
    const imResponse = await this.tim.getUserProfile({ userIDList: list });
    const newUserList = userList.map((item) => {
      const newItem = item;
      const itemProfile = imResponse.data.filter(imItem => imItem.userID === item.userID);
      newItem.avatar = itemProfile[0] && itemProfile[0].avatar ? itemProfile[0].avatar : '';
      newItem.nick = itemProfile[0] && itemProfile[0].nick ? itemProfile[0].nick : '';
      return newItem;
    });
    return newUserList;
  }

  // 呼叫用户图像解析不出来的缺省图设置
  _handleErrorImage() {
    const { remoteUsers } = this.data;
    remoteUsers[0].avatar = './static/avatar2_100.png';
    this.data.remoteUsers = remoteUsers;
  }

  // 通话中图像解析不出来的缺省图设置
  _handleConnectErrorImage(e) {
    const data = e.target.dataset.value;
    this.data.playerList = this.data.playerList.map((item) => {
      if (item.userID === data.userID) {
        item.avatar = './static/avatar2_100.png';
      }
      return item;
    });
  }

  // pusher 的网络状况
  _pusherNetStatus(event) {
    this.TRTC.pusherNetStatusHandler(event);
  }

  // player 的网络状况
  _playNetStatus(event) {
    this.TRTC.playerNetStatus(event);
  }

  //  切换大小屏 (仅支持1v1聊天)
  _toggleViewSize(e) {
    const { screen } = e.currentTarget.dataset;
    console.log('get screen', screen, e);
    if (this.data.playerList.length === 1 && screen !== this.data.screen && this.data.invitation.type === CALL_TYPE.VIDEO) {
      this.data.screen = screen;
    }
    return this.data.screen;
  }

  // tim实例
  getTim() {
    return this.tim;
  }

  // 销毁实例，防止影响外部应用
  destroyed() {
    if (this.data.callStatus === CALL_STATUS.CALLING || this.data.callStatus === CALL_STATUS.CONNECTED) {
      if (this.data.isSponsor) {
        this.hangup();
      } else {
        this.reject();
      }
    }
    this._reset();
    this._removeTSignalingEvent();
    this._removeTRTCEvent();
  }
}

export default TRTCCalling;

