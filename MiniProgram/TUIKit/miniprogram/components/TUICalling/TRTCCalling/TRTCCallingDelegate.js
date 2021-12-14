import { EVENT } from './common/constants.js';

// const TAG_NAME = 'TRTCCallingDelegate'


class TRTCCallingDelegate {
  constructor(options) {
    this._emitter = options.emitter;
  }

  // 抛出结束事件
  onCallEnd(params) {
    const { userID, callEnd, message } = params;
    this._emitter.emit(EVENT.CALL_END, {
      userID,
      callEnd,
      message,
    });
  }

  // 抛出邀请事件
  onInvited(params) {
    const { sponsor, inviteeList, isFromGroup, inviteData, inviteID } = params;
    this._emitter.emit(EVENT.INVITED, {
      sponsor,
      inviteeList,
      isFromGroup,
      inviteID,
      inviteData,
    });
  }

  // 抛出忙线事件
  onLineBusy(params) {
    const { inviteID, invitee } = params;
    this._emitter.emit(EVENT.LINE_BUSY, {
      inviteID,
      invitee,
      reason: 'line busy',
    });
  }

  // 抛出拒绝事件
  onReject(params) {
    const { inviteID, invitee } = params;
    this._emitter.emit(EVENT.REJECT, {
      inviteID,
      invitee,
      reason: 'reject',
    });
  }

  // 抛出无人应答事件
  onNoResp(params) {
    const { groupID = '', inviteID, sponsor, timeoutUserList } = params;
    this._emitter.emit(EVENT.NO_RESP, {
      groupID,
      inviteID,
      sponsor,
      timeoutUserList,
    });
  }

  // 抛出取消事件
  onCancel(params) {
    const { inviteID, invitee } = params;
    this._emitter.emit(EVENT.CALLING_CANCEL, {
      inviteID,
      invitee,
    });
  }

  // 抛出超时事件
  onTimeout(params) {
    const { inviteID, groupID, sponsor, timeoutUserList } = params;
    this._emitter.emit(EVENT.CALLING_TIMEOUT, {
      groupID,
      inviteID,
      sponsor,
      timeoutUserList,
    });
  }

  // 抛出用户接听
  onUserAccept(userID) {
    this._emitter.emit(EVENT.USER_ACCEPT, {
      userID,
    });
  }

  // 抛出用户进入房间
  onUserEnter(userID, playerList) {
    this._emitter.emit(EVENT.USER_ENTER, {
      userID,
      playerList,
    });
  }

  // 抛出用户离开房间
  onUserLeave(userID, playerList) {
    this._emitter.emit(EVENT.USER_LEAVE, {
      userID,
      playerList,
    });
  }

  // 抛出用户更新
  onUserUpdate(params) {
    const { pusher, playerList } = params;
    this._emitter.emit(EVENT.USER_UPDATE, {
      pusher,
      playerList,
    });
  }

  // 抛出用户已ready
  onSdkReady(params) {
    this._emitter.emit(EVENT.SDK_READY, params);
  }

  // 抛出用户被踢下线
  onKickedOut(params) {
    this._emitter.emit(EVENT.KICKED_OUT, params);
  }

  // 抛出切换通话模式
  onCallMode(params) {
    this._emitter.emit(EVENT.CALL_MODE, params);
  }
  // 销毁实例，防止影响外部应用
  destroyed() {
    this._emitter = null;
  }
}

export default TRTCCallingDelegate;
