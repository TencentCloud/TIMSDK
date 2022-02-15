import { ACTION_TYPE, BUSINESS_ID, CMD_TYPE_LIST, MODE_TYPE } from './common/constants.js';

const TAG_NAME = 'TSignalingClint';


class TSignalingClint {
  constructor(options) {
    this.TSignaling = options.TSignaling;
  }

  /**
     * 信令数据处理
     * @param data 第一层数据
     * @param params 第二层数据
     * @returns 处理后的数据
     * {@link https://iwiki.woa.com/pages/viewpage.action?pageId=820079397}
   */
  handleNewSignaling(data, params) {
    const info = {
      extraInfo: '',
      ...data,
      version: 4,
      businessID: 'av_call',
      platform: 'MiniApp',
      data: {
        cmd: CMD_TYPE_LIST[data.call_type],
        room_id: data.room_id,
        message: '',
        ...params,
      },
    };
    return info;
  }
  /**
   * 从消息对象中提取通话相关的信息
   * @param message
   */
  extractCallingInfoFromMessage(message) {
    if (!message || message.type !== 'TIMCustomElem') {
      return '';
    }
    const signalingData = JSON.parse(message.payload.data);
    if (signalingData.businessID !== BUSINESS_ID.SIGNAL) {
      return '';
    }
    switch (signalingData.actionType) {
      case ACTION_TYPE.INVITE: {
        const objectData = JSON.parse(signalingData.data);
        if (objectData.call_end > 0 && !signalingData.groupID) {
          return objectData.call_end;
        }
        if (objectData.call_end === 0 || !objectData.room_id) {
          return '结束群聊';
        }
        return '发起通话';
      }
      case ACTION_TYPE.CANCEL_INVITE:
        return '取消通话';
      case ACTION_TYPE.ACCEPT_INVITE:
        return '已接听';
      case ACTION_TYPE.REJECT_INVITE:
        return '拒绝通话';
      case ACTION_TYPE.INVITE_TIMEOUT:
        return '无应答';
      default:
        return '';
    }
  }
  // 异步错误处理
  handleError(error, name) {
    console.error(`${TAG_NAME} ${name}`, error);
    return error;
  }

  // 处理单聊data数据
  _handleInviteData(params) {
    const { type, roomID, userIDList, hangup, switchMode } = params;
    // 存在 hangup，表示挂断信令
    if (hangup) {
      return JSON.stringify(this.handleNewSignaling({
        version: 0,
        call_type: type,
        call_end: hangup.callEnd,
      }, { cmd: 'hangup' }));
    }
    // 存在 switchMode 则表示为切换信令
    if (switchMode) {
      const message = {
        version: 0,
        call_type: type,
        room_id: roomID,
      };
      const otherMessage = {
        cmd: 'switchToVideo',
      };
      // switchMode: audio视频切音频；video：音频切视频
      if (switchMode === MODE_TYPE.AUDIO) {
        // 兼容native switchToAudio 老版信令
        message.switch_to_audio_call = 'switch_to_audio_call';
        otherMessage.cmd = 'switchToAudio';
      }
      return JSON.stringify(this.handleNewSignaling(message, otherMessage));
    }
    // 不存在 hangup、switchMode 为正常邀请信令
    return JSON.stringify(this.handleNewSignaling({
      version: 0,
      call_type: type,
      room_id: roomID,
    }, { userIDs: userIDList }));
  }
  // 处理群聊data数据
  _handleInviteGroupData(params) {
    const { type, roomID, hangup } = params;
    let data = null;
    // 存在 hangup 则表示为挂断信令，不存在 hangup，表示正常呼叫信令
    if (!hangup) {
      data = JSON.stringify(this.handleNewSignaling({
        version: 0,
        call_type: type,
        room_id: roomID,
      }));
    } else {
      data = JSON.stringify(this.handleNewSignaling({
        version: 0,
        call_type: type,
        call_end: hangup.call_end,
      }, { cmd: 'hangup' }));
    }
    return data;
  }
  // 群聊若没有 groupID 时，为多个 C2C 单聊
  async _inviteInGroupTRTC(params) {
    const { userIDList, roomID, type, timeout, offlinePushInfo } = params;
    const result = {
      code: 0,
      data: [],
    };
    try {
      const inviteList = userIDList.map(item => this.invite({ userID: item, type, roomID, timeout, offlinePushInfo, userIDList }));
      const inviteListRes = await Promise.all(inviteList);
      result.data = inviteListRes;
    } catch (error) {
      result.code = 1;
      result.error = error;
      this.handleError(error, 'inviteGroup TRTC');
    }
    return result;
  }

  // 单聊
  async invite(params) {
    const { userID, offlinePushInfo, hangup, switchMode } = params;
    try {
      // 若不是IM的群聊时，需新增 userIDs 字段，对齐 native
      return await this.TSignaling.invite({
        userID,
        data: this._handleInviteData(params),
        timeout: hangup ? 0 : 30,
        offlinePushInfo,
      });
    } catch (error) {
      if (hangup) {
        return this.handleError(error, 'hangup C2C');
      }
      if (switchMode) {
        return this.handleError(error, switchMode);
      }
      return this.handleError(error, 'invite');
    }
  }
  // 群聊
  async inviteGroup(params) {
    const { groupID, userIDList, offlinePushInfo, hangup } = params;
    if (!groupID) {
      return await this._inviteInGroupTRTC(params);
    }
    try {
      return await this.TSignaling.inviteInGroup({
        groupID,
        inviteeList: userIDList,
        timeout: hangup ? 0 : 30,
        data: this._handleInviteGroupData(params),
        offlinePushInfo,
      });
    } catch (error) {
      if (hangup) {
        return this.handleError(error, 'hangup group');
      }
      return this.handleError(error, 'inviteGroup');
    }
  }
  // 接受邀请
  async accept(params, supportParams) {
    const { inviteID, type, ...otherParams } = params;
    try {
      return await this.TSignaling.accept({
        inviteID,
        data: JSON.stringify(this.handleNewSignaling({
          version: 0,
          call_type: type,
          ...otherParams,
        }, supportParams)),
      });
    } catch (error) {
      return this.handleError(error, 'accept');
    }
  }
  // 拒绝邀请
  async reject(params) {
    const { inviteID, type, lineBusy } = params;
    const message = {
      version: 0,
      call_type: type,
    };
    let data = null;
    if (lineBusy) {
      // 忙线时，需增加 line_busy 字段
      message.line_busy = lineBusy;
      data = JSON.stringify(this.handleNewSignaling(message, { message: 'lineBusy' }));
    } else {
      data = JSON.stringify(this.handleNewSignaling(message));
    }
    try {
      return await this.TSignaling.reject({
        inviteID,
        data,
      });
    } catch (error) {
      if (lineBusy) {
        return this.handleError(error, 'line_busy');
      }
      return this.handleError(error, 'reject');
    }
  }
  // 取消通话
  async cancel(params) {
    const { inviteIDList, callType } = params;
    const res = [];
    try {
      for (let i = 0; i < inviteIDList.length; i++) {
        const inviteID = inviteIDList[i];
        const result = await this.TSignaling.cancel({
          inviteID,
          data: JSON.stringify(this.handleNewSignaling({
            version: 0,
            call_type: callType,
          })),
        });
        res.push(result);
      }
      return res;
    } catch (error) {
      return this.handleError(error, 'cancel');
    }
  }
  // 挂断信令
  async lastOneHangup(params) {
    const { userIDList, callType, callEnd, groupID, isGroup } = params;
    // 群组通话
    if (isGroup) {
      return await this.inviteGroup({
        groupID,
        userIDList,
        type: callType,
        hangup: {
          call_end: groupID ? 0 : callEnd, // 群call_end 目前设置为0
        },
      });
    }
    // 1v1 通话
    return await this.invite({
      userID: userIDList[0],
      type: callType,
      hangup: {
        callEnd,
      },
    });
  }
  /**
       * 切换通话模式
       * @param params.mode 第一层数据
     */
  async switchCallMode(params) {
    const { userID, callType, roomID, mode } = params;
    return this.invite({
      userID,
      type: callType,
      roomID,
      switchMode: mode,
    });
  }

  // 销毁实例，防止影响外部应用
  destroyed() {
    this.TSignaling = null;
  }
}

export default TSignalingClint;
