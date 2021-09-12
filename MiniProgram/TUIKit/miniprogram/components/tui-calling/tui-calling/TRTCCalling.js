import EventEmitter from './utils/event.js'
import * as ENV from './utils/environment.js'
import { EVENT, TRTC_EVENT, ACTION_TYPE, BUSINESS_ID, CALL_STATUS, CMD_TYPE_LIST, OPERATE_EVENT } from './common/constants.js'
import UserController from './controller/user-controller'
import formateTime from './utils/formate-time'
import TSignaling from './utils/tsignaling-wx'

// TODO 组件挂载和模版方式分离，目前使用的方式，只能把TRTCCalling挂载在index页面上

const TAG_NAME = 'TRTCCalling-Component'

// 在trtc-calling中只维护一个tsignaling实例，否则的话可能会引起信令层状态的混乱，上层的多个Tsignal信令会同时处理底层的IM消息
let tsignaling = null
let tim = wx.$TUIKit

// 组件旨在跨终端维护一个通话状态管理机，以事件发布机制驱动上层进行管理，并通过API调用进行状态变更。
// 组件设计思路将UI和状态管理分离。您可以通过修改`template`文件夹下的文件，适配您的业务场景，
// 在UI展示上，您可以通过属性的方式，将上层的用户头像，名称等数据传入组件内部，`static`下的用户头像图片，
// 只是为了展示基础的效果，您需要根据业务场景进行修改。
Component({
  properties: {
    config: {
      type: Object,
      value: {
        sdkAppID: 0,
        userID: '',
        userSig: '',
        type: 0,
      },
    },
    backgroundMute: {
      type: Boolean,
      value: false,
    },
  },
  observers: {
    streamList(streamList) {
      for (let i = 0; i < streamList.length; i++) {
        if (!streamList[i].avatar && !streamList[i].nick) {
          console.log(`observers ${streamList[i].userID} has not avatar and nick`, streamList[i])
          tim.getUserProfile({ userIDList: [streamList[i].userID] }).then((imResponse) => {
            console.log(`get ${streamList[i].userID}`, imResponse)
            streamList[i].avatar = imResponse.data[0].avatar
            streamList[i].nick = imResponse.data[0].nick
          })
        }
      }
    },
  },

  data: {
    callStatus: CALL_STATUS.IDLE, // 用户当前的通话状态
    soundMode: 'speaker', // 声音模式 听筒/扬声器
    active: false,
    pusherConfig: { // 本地上行状态管理
      pushUrl: '',
      frontCamera: 'front',
      enableMic: true,
      enableCamera: true,
      volume: 0,
    },
    playerList: [], // 通话成员列表
    streamList: [],
    invitation: { // 接收到的邀请
      inviteID: '',
    },
    invitationAccept: { // 发出的邀请，以及返回的状态
      inviteID: '',
      rejectFlag: false,
    },
    startTalkTime: 0, // 开始通话的时间，用于计算1v1通话时长
    _historyUserList: [], // 房间内进过房的成员列表，用于发送call_end
    _isGroupCall: false, // 当前通话是否是群通话
    _groupID: '', // 群组ID
    _unHandledInviteeList: [], // 未处理的被邀请着列表
    tim: null, // TIM实例
    localUser: null, // 本地用户资料
    remoteUsers: [], // 远程用户资料
    isSponsor: true, // true:呼叫者，false:被呼叫对象
    timer: null, // 聊天时长定时器
    chatTimeNum: 0, // 聊天时长
    chatTime: '00:00:00', // 聊天时长格式化
    screen: 'pusher', // 视屏通话中，显示大屏幕的流（只限1v1聊天
    lastCall: false, // 是否为最后一位离开通话
  },

  methods: {
    _initEventEmitter() {
      // 监听TSignaling事件
      tsignaling.off(TSignaling.EVENT.NEW_INVITATION_RECEIVED)
      tsignaling.off(TSignaling.EVENT.INVITEE_ACCEPTED)
      tsignaling.off(TSignaling.EVENT.INVITATION_CANCELLED)
      tsignaling.off(TSignaling.EVENT.INVITEE_REJECTED)
      tsignaling.off(TSignaling.EVENT.INVITATION_TIMEOUT)
      tsignaling.off(TSignaling.EVENT.SDK_READY)
      tsignaling.off(TSignaling.EVENT.SDK_NOT_READY)
      tsignaling.off(TSignaling.EVENT.TEXT_MESSAGE_RECEIVED)
      tsignaling.off(TSignaling.EVENT.CUSTOM_MESSAGE_RECEIVED)
      tsignaling.off(TSignaling.EVENT.REMOTE_USER_JOIN)
      tsignaling.off(TSignaling.EVENT.REMOTE_USER_LEAVE)
      tsignaling.off(TSignaling.EVENT.KICKED_OUT)
      tsignaling.on(TSignaling.EVENT.NEW_INVITATION_RECEIVED, (event) => {
        console.log(TAG_NAME, 'onNewInvitationReceived', `callStatus：${this.data.callStatus === CALL_STATUS.CALLING || this.data.callStatus === CALL_STATUS.CONNECTED}, inviteID:${event.data.inviteID} inviter:${event.data.inviter} inviteeList:${event.data.inviteeList} data:${event.data.data}`)
        const { inviteID, inviter, inviteeList, groupID = '' } = event.data
        const data = JSON.parse(event.data.data)
        // 当前在通话中或在呼叫/被呼叫中，接收的新的邀请时，忙线拒绝
        if (this.data.callStatus === CALL_STATUS.CALLING || this.data.callStatus === CALL_STATUS.CONNECTED) {
          tsignaling.reject({
            inviteID,
            data: JSON.stringify(this.handleNewMessage({
              version: 0,
              call_type: data.call_type,
              line_busy: 'line_busy',
            }, { message: 'lineBusy' })),
          })
          // this._emitter.emit(EVENT.CALL_END)
          return
        }
        // 此处判断inviteeList.length 大于2，用于在非群组下多人通话判断
        const isGroupCall = (groupID && true) || inviteeList.length >= 2
        // 此处逻辑用于通话结束时发出的invite信令
        if (isGroupCall) {
          // 群通话已结束时，room_id 不存在或者 call_end 为 0
          if (!data.room_id || data.call_end === 0) {
            // 群通话中收到最后挂断的邀请信令通知其他成员通话结束
            this._emitter.emit(EVENT.CALL_END, {
              sponsor: inviter,
              call_end: 0,
            })
            return
          }
        } else {
          if (data.call_end > 0) {
            // 1v1通话挂断时，通知对端的通话结束和通话时长
            this._emitter.emit(EVENT.CALL_END, {
              sponsor: inviter,
              call_end: data.call_end,
            })
            this.setData({
              lastCall: true,
            })
            return
          }
        }
        if (isGroupCall) {
          this._initGroupCallInfo({
            _isGroupCall: true,
            _groupID: groupID,
            _unHandledInviteeList: [...inviteeList],
          })
        }
        this.data.config.type = data.call_type
        this.data.invitation.inviteID = inviteID
        this.data.invitation.inviter = inviter
        this.data.invitation.type = data.call_type
        this.data.invitation.roomID = data.room_id
        this.data.invitationAccept.inviteID = inviteID
        // 被邀请人进入calling状态
        // 当前invitation未处理完成时，下一个invitation都将会忙线
        this._getUserProfile([inviter])
        this._setCallStatus(CALL_STATUS.CALLING)
        this.setData({
          config: this.data.config,
          invitation: this.data.invitation,
          invitationAccept: this.data.invitationAccept,
          isSponsor: false,
        }, () => {
          console.log(`${TAG_NAME} NEW_INVITATION_RECEIVED invitation: `, this.data.callStatus, this.data.invitation)
          this._emitter.emit(EVENT.INVITED, {
            sponsor: inviter,
            inviteeList,
            isFromGroup: isGroupCall,
            inviteID,
            inviteData: {
              version: data.version,
              callType: data.call_type,
              roomID: data.room_id,
              callEnd: 0,
            },
          })
        })
      })
      tsignaling.on(TSignaling.EVENT.INVITEE_ACCEPTED, (event) => {
        // 发出的邀请收到接受的回调
        console.log(`${TAG_NAME} INVITEE_ACCEPTED inviteID:${event.data.inviteID} invitee:${event.data.invitee} data:${event.data.data}`)
        // 发起人进入通话状态从此处判断
        if (event.data.inviter === this._getUserID()) {
          this._setCallStatus(CALL_STATUS.CONNECTED)
        }
        if (this._getGroupCallFlag()) {
          this._setUnHandledInviteeList(event.data.invitee)
          return
        }
      })
      tsignaling.on(TSignaling.EVENT.INVITEE_REJECTED, (event) => {
        // 发出的邀请收到拒绝的回调
        console.log(`${TAG_NAME} INVITEE_REJECTED inviteID:${event.data.inviteID} invitee:${event.data.invitee} data:${event.data.data}`)
        // 多人通话时处于通话中的成员都可以收到此事件，此处只需要发起邀请方需要后续逻辑处理
        if (event.data.inviter !== this._getUserID()) {
          return
        }
        const data = JSON.parse(event.data.data)
        if (data.line_busy === ''
            || data.line_busy === 'line_busy'
            || (data.data && data.data.message
            && data.data.message === 'lineBusy')) {
          this._emitter.emit(EVENT.LINE_BUSY, {
            inviteID: event.data.inviteID,
            invitee: event.data.invitee,
            reason: 'line busy',
          })
        } else {
          this._emitter.emit(EVENT.REJECT, {
            inviteID: event.data.inviteID,
            invitee: event.data.invitee,
            reason: 'reject',
          })
        }
        if (this._getGroupCallFlag()) {
          this._setUnHandledInviteeList(event.data.invitee, (list) => {
            // 所有邀请的用户都已处理
            if (list.length === 0) {
              // 1、如果还在呼叫在，发出结束通话事件
              // 2、已经接受邀请，远端没有用户，发出结束通话事件
              if (this.data.callStatus === CALL_STATUS.CALLING || (this.data.callStatus === CALL_STATUS.CONNECTED && this.data.streamList.length === 0)) {
                this._emitter.emit(EVENT.CALL_END, {
                  inviteID: event.data.inviteID,
                  call_end: 0,
                })
                this._reset()
              }
            }
          })
        } else {
          this._reset()
        }
      })
      tsignaling.on(TSignaling.EVENT.INVITATION_CANCELLED, (event) => {
        // 收到的邀请收到该邀请取消的回调
        console.log(TAG_NAME, 'onInvitationCancelled', `inviteID:${event.data.inviteID} inviter:${event.data.invitee} data:${event.data.data}`)
        this._setCallStatus(CALL_STATUS.IDLE)
        this._emitter.emit(EVENT.CALLING_CANCEL, {
          inviteID: event.data.inviteID,
          invitee: event.data.invitee,
        })
        this._reset()
      })
      tsignaling.on(TSignaling.EVENT.INVITATION_TIMEOUT, (event) => {
        console.log(TAG_NAME, 'onInvitationTimeout', `data:${JSON.stringify(event)} inviteID:${event.data.inviteID} inviteeList:${event.data.inviteeList}`)
        const { groupID = '', inviteID, inviter, inviteeList, isSelfTimeout } = event.data
        if (this.data.lastCall) {
          return
        };
        if (this.data.callStatus !== CALL_STATUS.CONNECTED) {
          // 自己发起通话且先超时，即对方不在线，isSelfTimeout是对方是否在线的标识
          if (inviter === this._getUserID() && isSelfTimeout) {
            this._setCallStatus(CALL_STATUS.IDLE)
            this._emitter.emit(EVENT.NO_RESP, {
              groupID,
              inviteID,
              sponsor: inviter,
              timeoutUserList: inviteeList,
            })
            this._emitter.emit(EVENT.CALL_END, {
              inviteID,
              sponsor: inviter,
              call_end: 0,
            })
            return
          }
        }
        // 被邀请方在线超时接入侧序监听此事件做相应的业务逻辑处理,多人通话时，接入侧需要通过此事件处理某个用户超时逻辑
        this._emitter.emit(EVENT.CALLING_TIMEOUT, {
          groupID,
          inviteID,
          sponsor: inviter,
          timeoutUserList: inviteeList,
        })
        if (this._getGroupCallFlag()) {
          // 群通话逻辑处理
          const unHandledInviteeList = this._getUnHandledInviteeList()
          const restInviteeList = []
          unHandledInviteeList.forEach((invitee) => {
            if (inviteeList.indexOf(invitee) === -1) {
              restInviteeList.push(invitee)
            }
          })
          this.setData({
            _unHandledInviteeList: restInviteeList,
          })
          // restInviteeList 为空且无远端流
          if (restInviteeList.length === 0 && this.data.streamList.length === 0) {
            if (this.data.callStatus === CALL_STATUS.CONNECTED) {
              // 发消息到群组，结束本次通话
              this.lastOneHangup({
                inviteID,
                userIDList: [inviter],
                callType: this.data.config.type,
                callEnd: 0,
              })
              return
            }
            this._emitter.emit(EVENT.CALL_END, {
              inviteID,
              sponsor: inviter,
              call_end: 0,
            })
          }
        } else {
          // 1v1通话被邀请方超时
          this._emitter.emit(EVENT.CALL_END, {
            inviteID,
            sponsor: inviter,
            call_end: 0,
          })
        }
        // 用inviteeList进行判断，是为了兼容多人通话
        if (inviteeList.includes(this._getUserID())) {
          this._setCallStatus(CALL_STATUS.IDLE)
        }
      })
      tsignaling.on(TSignaling.EVENT.SDK_READY, () => {
        console.log(TAG_NAME, 'TSignaling SDK ready')
        const promise = tim.getMyProfile()
        promise.then((imResponse) => {
          this.setData({
            localUser: { ...imResponse.data },
          })
        }).catch((imError) => {
          console.warn('getMyProfile error:', imError) // 获取个人资料失败的相关信息
        })
      })
      tsignaling.on(TSignaling.EVENT.SDK_NOT_READY, () => {
        this._emitter.emit(EVENT.ERROR, {
          errorMsg: 'TSignaling SDK not ready !!! 如果想使用发送消息等功能，接入侧需驱动 SDK 进入 ready 状态',
        })
      })
      tsignaling.on(TSignaling.EVENT.TEXT_MESSAGE_RECEIVED, () => {

      })
      tsignaling.on(TSignaling.EVENT.CUSTOM_MESSAGE_RECEIVED, () => {

      })
      tsignaling.on(TSignaling.EVENT.REMOTE_USER_JOIN, () => {
        //
      })
      tsignaling.on(TSignaling.EVENT.REMOTE_USER_LEAVE, () => {
        // 离开
      })
      tsignaling.on(TSignaling.EVENT.KICKED_OUT, () => {
        // 被踢下线 TODO
        wx.showToast({
          title: '您已被踢下线',
        })
        this.hangup()
      })
      tsignaling.on(TSignaling.EVENT.NET_STATE_CHANGE, () => {

      })
      // 监听TRTC SDK抛出的事件
      this.userController.on(TRTC_EVENT.REMOTE_USER_JOIN, (event) => {
        console.log(TAG_NAME, 'REMOTE_USER_JOIN', event, event.data.userID)
        this.setData({
          playerList: event.data.userList,
        }, () => {
          if (!this.data.startTalkTime) {
            this.setData({
              startTalkTime: Date.now(),
            })
          }
          this._emitter.emit(EVENT.USER_ENTER, {
            userID: event.data.userID,
          })
          // if (this.data._historyUserList.indexOf(event.data.userID) === -1) {
          //   this.data._historyUserList.push(event.data.userID)
          // }
        })
        console.log(TAG_NAME, 'REMOTE_USER_JOIN', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 远端用户离开
      this.userController.on(TRTC_EVENT.REMOTE_USER_LEAVE, (event) => {
        console.log(TAG_NAME, 'REMOTE_USER_LEAVE', event, event.data.userID)
        if (event.data.userID) {
          this.setData({
            playerList: event.data.userList,
            streamList: event.data.streamList,
          }, () => {
            this._emitter.emit(EVENT.USER_LEAVE, {
              userID: event.data.userID,
            })
            // 群组或多人通话时需要从列表中删掉离开的用户
            // const index = this.data._historyUserList.indexOf(event.data.userID)
            // if (index > -1) {
            //   this.data._historyUserList.splice(index, 1)
            // }
            // 群组或多人通话模式下，有用户离开时，远端还有用户，则只下发用户离开事件
            if (event.data.streamList.length > 0 && this._getGroupCallFlag()) {
              this._emitter.emit(EVENT.USER_LEAVE, {
                userID: event.data.userID,
              })
              return
            }
            // 无远端流，需要发起最后一次邀请信令， 此处逻辑是为与native对齐，正确操作应该放在hangup中处理
            if (this.data.streamList.length === 0) {
              this.lastOneHangup({
                inviteID: this.data.invitationAccept.inviteID,
                userIDList: [event.data.userID],
                callType: this.data.config.type,
                callEnd: Math.round((Date.now() - this.data.startTalkTime) / 1000),
              })
              this.setData({
                startTalkTime: 0,
              })
            }
          })
        }
        console.log(TAG_NAME, 'REMOTE_USER_LEAVE', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 视频状态 true
      this.userController.on(TRTC_EVENT.REMOTE_VIDEO_ADD, (event) => {
        console.log(TAG_NAME, 'REMOTE_VIDEO_ADD', event, event.data.stream.userID)
        const { stream } = event.data
        this.setData({
          playerList: event.data.userList,
          streamList: this._handleUserProfile(event.data.streamList),
        }, () => {
          stream.playerContext = wx.createLivePlayerContext(stream.streamID, this)
        })
        console.log(TAG_NAME, 'REMOTE_VIDEO_ADD', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 视频状态 false
      this.userController.on(TRTC_EVENT.REMOTE_VIDEO_REMOVE, (event) => {
        console.log(TAG_NAME, 'REMOTE_VIDEO_REMOVE', event, event.data.stream.userID)
        const { stream } = event.data
        this.setData({
          playerList: event.data.userList,
          streamList: this._handleUserProfile(event.data.streamList),
        }, () => {
          // 有可能先触发了退房事件，用户名下的所有stream都已清除
          if (stream.userID && stream.streamType) {
            // this._emitter.emit(EVENT.REMOTE_VIDEO_REMOVE, { userID: stream.userID, streamType: stream.streamType })
          }
        })
        console.log(TAG_NAME, 'REMOTE_VIDEO_REMOVE', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 音频可用
      this.userController.on(TRTC_EVENT.REMOTE_AUDIO_ADD, (event) => {
        console.log(TAG_NAME, 'REMOTE_AUDIO_ADD', event)
        const { stream } = event.data
        this.setData({
          playerList: event.data.userList,
          streamList: this._handleUserProfile(event.data.streamList),
        }, () => {
          stream.playerContext = wx.createLivePlayerContext(stream.streamID, this)
          // 新增的需要触发一次play 默认属性才能生效
          // stream.playerContext.play()
          // console.log(TAG_NAME, 'REMOTE_AUDIO_ADD playerContext.play()', stream)
          // this._emitter.emit(EVENT.REMOTE_AUDIO_ADD, { userID: stream.userID, streamType: stream.streamType })
        })
        console.log(TAG_NAME, 'REMOTE_AUDIO_ADD', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
      // 音频不可用
      this.userController.on(TRTC_EVENT.REMOTE_AUDIO_REMOVE, (event) => {
        console.log(TAG_NAME, 'REMOTE_AUDIO_REMOVE', event, event.data.stream.userID)
        const { stream } = event.data
        this.setData({
          playerList: event.data.userList,
          streamList: this._handleUserProfile(event.data.streamList),
        }, () => {
          // 有可能先触发了退房事件，用户名下的所有stream都已清除
          if (stream.userID && stream.streamType) {
            // this._emitter.emit(EVENT.REMOTE_AUDIO_REMOVE, { userID: stream.userID, streamType: stream.streamType })
          }
        })
        console.log(TAG_NAME, 'REMOTE_AUDIO_REMOVE', 'streamList:', this.data.streamList, 'userList:', this.data.userList)
      })
    },
    _handleUserProfile(data) {
      const streamList = data
      for (let i = 0; i < streamList.length; i++) {
        this.data.remoteUsers.map((item) => {
          if (item.userID === streamList[i].userID) {
            streamList[i].avatar = streamList[i].avatar || item.avatar
            streamList[i].nick = streamList[i].nick || item.nick
          }
          return item
        })
      }
      return streamList
    },
    /**
     * 登录IM接口，所有功能需要先进行登录后才能使用
     *
     */
    login() {
      return new Promise((resolve, reject) => {
        tsignaling.setLogLevel(0)
        tsignaling.login({
          userID: this.data.config.userID,
          userSig: this.data.config.userSig,
        }).then(() => {
          console.log(TAG_NAME, 'login', 'IM login success')
          this._initEventEmitter()
          resolve()
        })
      })
    },
    /**
     * 登出接口，登出后无法再进行拨打操作
     */
    async logout() {
      if (this.data.callStatus === CALL_STATUS.CALLING) {
        if (this.data.isSponsor) {
          await this.hangup()
        } else {
          await this.reject()
        }
      }
      this._reset()
      tsignaling.logout({
        userID: this.data.config.userID,
        userSig: this.data.config.userSig,
      }).then((res) => {
        console.log(TAG_NAME, 'logout', 'IM logout success')
        return res
      })
        .catch((err) => {
          console.error(TAG_NAME, 'logout', 'IM logout failure')
          return err
        })
    },
    /**
     * 监听事件
     *
     * @param eventCode 事件名
     * @param handler 事件响应回调
     */
    on(eventCode, handler, context) {
      this._emitter.on(eventCode, handler, context)
    },

    off(eventCode, handler) {
      this._emitter.off(eventCode, handler)
    },
    /**
     * C2C邀请通话，被邀请方会收到的回调
     * 如果当前处于通话中，可以调用该函数以邀请第三方进入通话
     *
     * @param userID 被邀请方
     * @param type 0-为之， 1-语音通话，2-视频通话
     */
    call({ userID, type }) {
      // 生成房间号，拼接URL地址
      const roomID = Math.floor(Math.random() * 100000000 + 1) // 随机生成房间号
      this._getPushUrl(roomID)
      this._enterTRTCRoom()
      tsignaling.invite({
        userID,
        data: JSON.stringify(this.handleNewMessage({
          version: 0,
          call_type: type,
          room_id: roomID,
        })),
        timeout: 30,
      }).then((res) => {
        console.log(`${TAG_NAME} call(userID: ${userID}, type: ${type}) success, ${res}`)
        // 发起人进入calling状态
        this.data.config.type = type
        this._setCallStatus(CALL_STATUS.CALLING)
        this._getUserProfile([userID])
        this.data.invitationAccept.inviteID = res.inviteID
        this.setData({
          config: this.data.config,
          invitationAccept: this.data.invitationAccept,
          isSponsor: true,
          lastCall: false,
        })
        this._emitter.emit(OPERATE_EVENT.CALL, {
          message: res.data.message,
        })
        return res.data.message
      })
        .catch((error) => {
          console.log(`${TAG_NAME} call(userID:${userID},type:${type}) failed', error: ${error}`)
        })
    },
    /**
     * IM群组邀请通话，被邀请方会收到的回调
     * 如果当前处于通话中，可以继续调用该函数继续邀请他人进入通话，同时正在通话的用户会收到的回调
     *
     * @param userIDList 邀请列表
     * @param type 1-语音通话，2-视频通话
     * @param groupID IM群组ID
     */
    groupCall(params) {
      // 生成房间号，拼接URL地址
      const roomID = Math.floor(Math.random() * 100000000 + 1) // 随机生成房间号
      this._getPushUrl(roomID)
      this._enterTRTCRoom()
      this._initGroupCallInfo({
        _isGroupCall: true,
        _groupID: params.groupID,
        _unHandledInviteeList: [...params.userIDList],
      })
      tsignaling.inviteInGroup({
        groupID: params.groupID,
        inviteeList: params.userIDList,
        timeout: 30,
        data: JSON.stringify(this.handleNewMessage({
          version: 0,
          call_type: params.type,
          room_id: roomID,
        })),
      }).then((res) => {
        console.log(TAG_NAME, 'inviteInGroup OK', res)
        // 发起人进入calling状态
        this.data.config.type = params.type
        this._setCallStatus(CALL_STATUS.CALLING)
        this._getUserProfile(params.userIDList)
        this.data.invitationAccept.inviteID = res.inviteID
        this.setData({
          config: this.data.config,
          invitationAccept: this.data.invitationAccept,
          isSponsor: true,
          lastCall: false,
        })
        this._emitter.emit(OPERATE_EVENT.CALL, {
          message: res.data.message,
        })
        return res.data.message
      })
        .catch((error) => {
          console.log(TAG_NAME, 'inviteInGroup failed', error)
        })
    },
    /**
     * 当您作为被邀请方收到 {@link TRTCCallingDelegate#onInvited } 的回调时，可以调用该函数接听来电
     */
    async accept() {
      // 拼接pusherURL进房
      console.log(TAG_NAME, 'accept() inviteID: ', this.data.invitation.inviteID)
      const acceptRes = await tsignaling.accept({
        inviteID: this.data.invitation.inviteID,
        data: JSON.stringify(this.handleNewMessage({
          version: 0,
          call_type: this.data.config.type,
        })),
      })
      console.log('trtccaling accept------', acceptRes)
      if (acceptRes.code === 0) {
        console.log(TAG_NAME, 'accept OK')
        // 被邀请人进入通话状态
        this._setCallStatus(CALL_STATUS.CONNECTED)
        if (this._getGroupCallFlag()) {
          this._setUnHandledInviteeList(this._getUserID())
        }
        this._getPushUrl(this.data.invitation.roomID)
        this._enterTRTCRoom()
        this._emitter.emit(OPERATE_EVENT.ACCEPT, {
          message: acceptRes.data.message,
        })
        return acceptRes.data.message
      }
      console.error(TAG_NAME, 'accept failed', acceptRes)
      return acceptRes
    },
    /**
     * 当您作为被邀请方收到的回调时，可以调用该函数拒绝来电
     */
    async reject() {
      if (this.data.invitation.inviteID) {
        const rejectRes = await tsignaling.reject({
          inviteID: this.data.invitation.inviteID,
          data: JSON.stringify(this.handleNewMessage({
            version: 0,
            call_type: this.data.config.type,
          })),
        })
        if (rejectRes.code === 0) {
          console.log(TAG_NAME, 'reject OK', rejectRes)
          this._reset()
          this._emitter.emit(OPERATE_EVENT.ACCEPT, {
            message: rejectRes.data.message,
          })
          return rejectRes.data.message
        }
        console.log(TAG_NAME, 'reject failed', rejectRes)
        return rejectRes
      }
      console.warn(`${TAG_NAME} 未收到邀请，无法拒绝`)
      return '未收到邀请，无法拒绝'
    },
    /**
     * 当您处于通话中，可以调用该函数挂断通话
     * 当您发起通话时，可用去了取消通话
     */
    async hangup() {
      const inviterFlag = !this.data.invitation.inviteID && this.data.invitationAccept.inviteID // 是否是邀请者
      console.log('挂断inviterFlag', inviterFlag)
      console.log('挂断invitation', this.data.invitation.inviteID)
      console.log('挂断invitationAccept', this.data.invitationAccept.inviteID)
      let cancelRes = null
      if (inviterFlag && this.data.callStatus === CALL_STATUS.CALLING) {
        console.log(TAG_NAME, 'cancel() inviteID: ', this.data.invitationAccept.inviteID)
        try {
          const res = await tsignaling.cancel({
            inviteID: this.data.invitationAccept.inviteID,
            data: JSON.stringify(this.handleNewMessage({
              version: 0,
              call_type: this.data.config.type,
            })),
          })
          cancelRes = res
        } catch (error) {
          console.log(TAG_NAME, 'inviteInGroup failed', error)
        }
      }
      // 发起方取消通话时需要携带消息实例
      if (cancelRes) {
        this._emitter.emit(EVENT.CALL_END, {
          message: cancelRes.data.message,
        })
      }
      // console.warn('hangup', this._getGroupCallFlag(), this.data.streamList.length > 1, this.data._unHandledInviteeList)
      // 群组或多人通话时，如果远端流大于1，则不是最后一个挂断的用户，某用户挂断需要下发call_end用于处理上层UI,因为小程序此处的挂断操作在模版中进行，与web不同
      // if (this._getGroupCallFlag() && this.data.streamList.length > 1 && this.data._unHandledInviteeList.length === 0) {
      //   this._emitter.emit(EVENT.CALL_END)
      // }
      // if (this._getGroupCallFlag() && this.data._unHandledInviteeList.length > 0) {
      //   this._emitter.emit(EVENT.CALL_END)
      // }
      this._reset()
      return cancelRes
    },
    // 最后一位离开房间的用户发送该信令 (http://tapd.oa.com/Qcloud_MLVB/markdown_wikis/show/#1210146251001590857)
    async lastOneHangup(params) {
      const { userIDList, callType, callEnd } = params
      let res = null
      // 群组通话
      if (this._getGroupCallFlag()) {
        res = await tsignaling.inviteInGroup({
          groupID: this.data._groupID,
          inviteeList: userIDList,
          data: JSON.stringify(this.handleNewMessage({
            version: 0,
            call_type: callType,
            call_end: 0, // 群call_end 目前设置为0
          }, { cmd: 'hangup' })),
          timeout: 30,
        })
      } else {
        // 1v1 通话
        res = await tsignaling.invite({
          userID: userIDList[0],
          data: JSON.stringify(this.handleNewMessage({
            version: 0,
            call_type: callType,
            call_end: callEnd,
          }, { cmd: 'hangup' })),
        })
      }
      this.setData({
        lastCall: true,
      })
      this._emitter.emit(EVENT.CALL_END, {
        message: res.data.message,
      })
      this._reset()
    },

    _initGroupCallInfo(options) {
      this.setData({
        _isGroupCall: options._isGroupCall,
        _groupID: options._groupID,
        _unHandledInviteeList: options._unHandledInviteeList,
      })
    },
    _getGroupCallFlag() {
      return this.data._isGroupCall
    },
    _setUnHandledInviteeList(userID, callback) {
      // 使用callback防御列表更新时序问题
      const list = [...this._getUnHandledInviteeList()]
      const unHandleList = list.filter((item) => item !== userID)
      this.setData({
        _unHandledInviteeList: unHandleList,
      }, () => {
        callback && callback(unHandleList)
      })
    },
    _getUnHandledInviteeList() {
      return this.data._unHandledInviteeList
    },
    _getUserID() {
      return this.data.config.userID
    },
    _setCallStatus(status) {
      this.setData({
        callStatus: status,
      })
      switch (status) {
        case CALL_STATUS.CONNECTED:
          this.data.timer = setInterval(() => {
            this.data.chatTimeNum++
            this.setData({
              chatTime: formateTime(this.data.chatTimeNum),
              chatTimeNum: this.data.chatTimeNum,
            })
          }, 1000)
          break
        case CALL_STATUS.IDLE:
          this.data.timer && clearInterval(this.data.timer)
          this.setData({
            chatTime: '00:00:00',
            chatTimeNum: 0,
          })
          break
      }
    },
    _reset() {
      return new Promise((resolve, reject) => {
        console.log(TAG_NAME, ' _reset()')
        const result = this.userController.reset()
        this.data.pusherConfig = {
          pushUrl: '',
          frontCamera: 'front',
          enableMic: true,
          enableCamera: true,
          volume: 0,
        },
        this._setCallStatus(CALL_STATUS.IDLE)
        wx.createLivePusherContext().setMICVolume({ volume: 1 })
        this.data.config.type = 0
        // 存在定时器，清除定时器
        this.data.timer && clearInterval(this.data.timer)
        // 清空状态
        this.setData({
          pusherConfig: this.data.pusherConfig,
          soundMode: 'speaker',
          invitation: {
            inviteID: '',
          },
          playerList: result.userList,
          streamList: result.streamList,
          _historyUserList: [],
          active: false,
          invitationAccept: {
            inviteID: '',
          },
          startTalkTime: 0,
          _isGroupCall: false,
          _groupID: '',
          _unHandledInviteeList: [],
          chatTimeNum: 0,
          chatTime: '00:00:00',
          config: this.data.config,
        }, () => {
          resolve()
        })
      })
    },
    /**
     *
     * @param userID 远端用户id
     */
    startRemoteView(userID) {
      this.data.streamList.forEach((stream) => {
        if (stream.userID === userID) {
          stream.muteVideo = false
          this.setData({
            streamList: this.data.streamList,
          }, () => {
            console.log(`${TAG_NAME}, startRemoteView(${userID})`)
          })
          return
        }
      })
    },
    /**
     * 当您收到 onUserVideoAvailable 回调为false时，可以停止渲染数据
     *
     * @param userID 远端用户id
     */
    stopRemoteView(userID) {
      this.data.streamList.forEach((stream) => {
        if (stream.userID === userID) {
          stream.muteVideo = true
          this.setData({
            streamList: this.data.streamList,
          }, () => {
            console.log(`${TAG_NAME}, stopRemoteView(${userID})`)
          })
          return
        }
      })
    },
    /**
     * 您可以调用该函数开启摄像头
     */
    openCamera() {
      this.data.pusherConfig.enableCamera = true
      this.setData({
        pusherConfig: this.data.pusherConfig,
      }, () => {
        console.log(`${TAG_NAME}, closeCamera() pusherConfig: ${this.data.pusherConfig}`)
      })
    },
    /**
     * 您可以调用该函数关闭摄像头
     * 处于通话中的用户会收到回调
     */
    closeCamera() {
      this.data.pusherConfig.enableCamera = false
      this.setData({
        pusherConfig: this.data.pusherConfig,
      }, () => {
        console.log(`${TAG_NAME}, closeCamera() pusherConfig: ${this.data.pusherConfig}`)
      })
    },
    /**
     * 是否静音mic
     *
     * @param isMute true:麦克风关闭 false:麦克风打开
     */
    // setMicMute(isMute) {
    //   this.data.pusherConfig.enableMic = !isMute
    //   this.setData({
    //     pusherConfig: this.data.pusherConfig,
    //   }, () => {
    //     console.log(`${TAG_NAME}, setMicMute(${isMute}) enableMic: ${this.data.pusherConfig.enableMic}`)
    //   })
    // },
    setMicMute(isMute) {
      this.data.pusherConfig.enableMic = !isMute
      this.setData({
        pusherConfig: this.data.pusherConfig,
      }, () => {
        console.log(`${TAG_NAME}, setMicMute(${isMute}) enableMic: ${this.data.pusherConfig.enableMic}`)
        // enableMic 会有一个 native 向客户端拿 audio 权限的一个过程，所以会导致开麦慢
        wx.createLivePusherContext().setMICVolume({ volume: isMute ? 0 : 1 })
      })
    },

    switchCamera(isFrontCamera) {
      const targetPos = isFrontCamera ? 'front' : 'back'
      if (this.data.pusherConfig.frontCamera !== targetPos) {
        this.data.pusherConfig.frontCamera = targetPos
        wx.createLivePusherContext().switchCamera()
        this.setData({
          pusherConfig: this.data.pusherConfig,
        }, () => {
          console.log(`${TAG_NAME}, switchCamera(), frontCamera${this.data.pusherConfig.frontCamera}`)
        })
      }
    },
    setHandsFree(isHandsFree) {
      this.data.soundMode = isHandsFree ? 'speaker' : 'ear'
      this.setData({
        soundMode: this.data.soundMode,
      }, () => {
        console.log(`${TAG_NAME}, setHandsFree() result: ${this.data.soundMode}`)
      })
    },

    _toggleSwitchCamera() {
      const isFront = this.data.pusherConfig.frontCamera !== 'front'
      this.switchCamera(isFront)
    },

    _toggleCamera() {
      if (!this.data.pusherConfig.enableCamera) {
        this.openCamera()
      } else {
        this.closeCamera()
      }
    },

    _toggleAudio() {
      if (this.data.pusherConfig.enableMic) {
        this.setMicMute(true)
      } else {
        this.setMicMute(false)
      }
    },

    _toggleSoundMode() {
      if (this.data.soundMode === 'speaker') {
        this.setHandsFree(false)
      } else {
        this.setHandsFree(true)
      }
    },

    _getPushUrl(roomId) {
      // 拼接 puhser url rtmp 方案
      console.log(TAG_NAME, '_getPushUrl', roomId)
      // TODO: 解注释
      if (ENV.IS_TRTC) {
        // 版本高于7.0.8，基础库版本高于2.10.0 使用新的 url
        return new Promise((resolve, reject) => {
          this.setData({
            active: true,
          })
          let roomID = ''
          if (/^\d+$/.test(roomId)) {
            // 数字房间号
            roomID = `&roomid=${roomId}`
          } else {
            // 字符串房间号
            roomID = `&strroomid=${roomId}`
          }
          setTimeout(() => {
            const pushUrl = `room://cloud.tencent.com/rtc?sdkappid=${this.data.config.sdkAppID
            }${roomID
            }&userid=${this.data.config.userID
            }&usersig=${this.data.config.userSig
            }&appscene=videocall`
                            + '&cloudenv=PRO' // ios此参数必填
            console.warn(TAG_NAME, 'getPushUrl result:', pushUrl)
            this.data.pusherConfig.pushUrl = pushUrl
            this.setData({
              pusherConfig: this.data.pusherConfig,
            })
            resolve(pushUrl)
          }, 0)
        })
      }
      console.error(TAG_NAME, '组件仅支持微信 App iOS >=7.0.9, Android >= 7.0.8, 小程序基础库版 >= 2.10.0')
      console.error(TAG_NAME, '需要真机运行，开发工具不支持实时音视频')
    },

    _enterTRTCRoom() {
      // 开始推流
      wx.createLivePusherContext().start()
    },

    _hangUp() {
      this.hangup()
    },

    _pusherStateChangeHandler(event) {
      const { code } = event.detail
      const { message } = event.detail
      const TAG_NAME = 'TRTCCalling pusherStateChange: '
      switch (code) {
        case 0: // 未知状态码，不做处理
          console.log(TAG_NAME, message, code)
          break
        case 1001:
          console.log(TAG_NAME, '已经连接推流服务器', code)
          break
        case 1002:
          console.log(TAG_NAME, '已经与服务器握手完毕,开始推流', code)
          break
        case 1003:
          console.log(TAG_NAME, '打开摄像头成功', code)
          break
        case 1005:
          console.log(TAG_NAME, '推流动态调整分辨率', code)
          break
        case 1006:
          console.log(TAG_NAME, '推流动态调整码率', code)
          break
        case 1007:
          console.log(TAG_NAME, '首帧画面采集完成', code)
          break
        case 1008:
          console.log(TAG_NAME, '编码器启动', code)
          break
        case 1018:
          console.log(TAG_NAME, '进房成功', code)
          break
        case 1019:
          console.log(TAG_NAME, '退出房间', code)
          // 20200421 iOS 仍然没有1019事件通知退房，退房事件移动到 exitRoom 方法里，但不是后端通知的退房成功
          // this._emitter.emit(EVENT.LOCAL_LEAVE, { userID: this.data.pusher.userID })
          break
        case 2003:
          console.log(TAG_NAME, '渲染首帧视频', code)
          break
        case 1020:
        case 1031:
        case 1032:
        case 1033:
        case 1034:
          // 通过 userController 处理 1020 1031 1032 1033 1034
          this.userController.userEventHandler(event)
          break
        case -1301:
          console.error(TAG_NAME, '打开摄像头失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1302:
          console.error(TAG_NAME, '打开麦克风失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1303:
          console.error(TAG_NAME, '视频编码失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1304:
          console.error(TAG_NAME, '音频编码失败: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -1307:
          console.error(TAG_NAME, '推流连接断开: ', code)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case -100018:
          console.error(TAG_NAME, '进房失败: userSig 校验失败，请检查 userSig 是否填写正确', code, message)
          this._emitter.emit(EVENT.ERROR, { code, message })
          break
        case 5000:
          console.log(TAG_NAME, '小程序被挂起: ', code)
          // 20200421 iOS 微信点击胶囊圆点会触发该事件
          // 触发 5000 后，底层SDK会退房，返回前台后会自动进房
          break
        case 5001:
          // 20200421 仅有 Android 微信会触发该事件
          console.log(TAG_NAME, '小程序悬浮窗被关闭: ', code)
          this.hangup()
          break
        case 1021:
          console.log(TAG_NAME, '网络类型发生变化，需要重新进房', code)
          break
        case 2007:
          console.log(TAG_NAME, '本地视频播放loading: ', code)
          break
        case 2004:
          console.log(TAG_NAME, '本地视频播放开始: ', code)
          break
        default:
          console.log(TAG_NAME, message, code)
      }
    },

    _playerStateChange(event) {
      // console.log(TAG_NAME, '_playerStateChange', event)
      this._emitter.emit(EVENT.REMOTE_STATE_UPDATE, event)
    },

    _playerAudioVolumeNotify(event) {
      const userID = event.target.dataset.userid
      const { volume } = event.detail
      const stream = this.userController.getStream({
        userID,
        streamType: 'main',
      })
      if (stream) {
        stream.volume = volume
      }
      this.setData({
        streamList: this.data.streamList,
      }, () => {
        this._emitter.emit(EVENT.USER_VOICE_VOLUME, {
          userID,
          volume,
        })
      })
    },
    _pusherAudioVolumeNotify(event) {
      this.data.pusherConfig.volume = event.detail.volume
      this._emitter.emit(EVENT.USER_VOICE_VOLUME, {
        userID: this.data.config.userID,
        volume: event.detail.volume,
      })
      this.setData({
        pusherConfig: this.data.pusherConfig,
      })
    },
    /**
   * 从消息对象中提取通话相关的信息
   * @param message
   */
    extractCallingInfoFromMessage(message) {
      if (!message || message.type !== 'TIMCustomElem') {
        return ''
      }
      const signalingData = JSON.parse(message.payload.data)
      if (signalingData.businessID !== BUSINESS_ID.SIGNAL) {
        return ''
      }
      switch (signalingData.actionType) {
        case ACTION_TYPE.INVITE: {
          const objectData = JSON.parse(signalingData.data)
          if (objectData.call_end > 0 && !signalingData.groupID) {
            return `结束通话，通话时长：${formateTime(objectData.call_end)}`
          }
          if (objectData.call_end === 0 || !objectData.room_id) {
            return '结束群聊'
          }
          return '发起通话'
        }
        case ACTION_TYPE.CANCEL_INVITE:
          return '取消通话'
        case ACTION_TYPE.ACCEPT_INVITE:
          return '已接听'
        case ACTION_TYPE.REJECT_INVITE:
          return '拒绝通话'
        case ACTION_TYPE.INVITE_TIMEOUT:
          return '无应答'
        default:
          return ''
      }
    },
    /**
   * 信令数据处理
   * @param data 第一层数据
   * @param params 第二层数据
   * @returns 处理后的数据
   * {@link https://iwiki.woa.com/pages/viewpage.action?pageId=820079397}
   */
    handleNewMessage(data, params) {
      const info =  {
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
      }
      return info
    },
    switchAudioCall() {
      // const message = {
      //   call_type: this.data.config.type,
      //   room_id: roomID,
      //   switch_to_audio_call: 'switch_to_audio_call'
      // }
      // const otherMessage = {
      //   cmd: 'switchToAudio',
      // }

      // tsignaling.invite({
      //   userID:'',
      //   data: JSON.stringify(
      //     this.handleNewSignaling(message, otherMessage)),
      //   timeout: 0,
      // });
    },
    switchVideoCall() {
      // const message = {
      //   call_type: this.data.config.type,
      //   room_id: roomID
      // }
      // const otherMessage = {
      //   cmd: 'switchToVideo',
      // }
      // tsignaling.invite({
      //   userID:'',
      //   data: JSON.stringify(
      //     this.handleNewSignaling(message, otherMessage)),
      //   timeout: 0,
      // });
    },
    // 获取用户信息
    _getUserProfile(userList) {
      const promise = tim.getUserProfile({ userIDList: userList })
      promise.then((imResponse) => {
        console.log('getUserProfile success', imResponse)
        console.log(imResponse.data)
        this.setData({
          remoteUsers: imResponse.data,
        })
      }).catch((imError) => {
        console.warn('getUserProfile error:', imError) // 获取其他用户资料失败的相关信息
      })
    },
    // 呼叫用户图像解析不出来的缺省图设置
    _handleErrorImage() {
      const { remoteUsers } = this.data
      remoteUsers[0].avatar = './static/avatar2_100.png'
      this.setData({
        remoteUsers,
      })
    },
    // 通话中图像解析不出来的缺省图设置
    _handleConnectErrorImage(e) {
      const data = e.target.dataset.value
      this.data.streamList = this.data.streamList.map((item) => {
        if (item.userID === data.userID) {
          item.avatar = './static/avatar2_100.png'
        }
        return item
      })
    },
    // pusher 的网络状况
    _pusherNetStatus(e) {
      const data = e.detail.info
      console.log('local network', data)
      if (data.netQualityLevel > 4) {
        wx.showToast({
          icon: 'none',
          title: '您当前网络不佳',
        })
      }
    },
    // player 的网络状况
    _playNetStatus(e) {
      const data = e.detail.info
      console.log('remote network', data)
      const userId = e.target.dataset.userid
      let name = '对方'
      if (this.data.streamList > 1) {
        this.data.remoteUsers.map((item) => {
          if (item.userId === userId) {
            name = `用户${item.nick}`
          }
        })
      }

      if (data.netQualityLevel > 4) {
        wx.showToast({
          icon: 'none',
          title: `${name}当前网络不佳`,
        })
      }
    },
    //  切换大小屏 (仅支持1v1聊天)
    _toggleViewSize(e) {
      const { screen } = e.currentTarget.dataset
      console.log('get screen', screen, e)
      if (this.data.streamList.length === 1 && screen !== this.data.screen) {
        this.setData({
          screen,
        })
      }
    },
  },

  /**
   * 生命周期方法
   */
  lifetimes: {
    created() {
      // 在组件实例刚刚被创建时执行
      console.log(TAG_NAME, 'created', ENV, this.data.config)
    },
    attached() {
      // 在组件实例进入页面节点树时执行
      console.log(TAG_NAME, 'attached')
      this.EVENT = EVENT
      this.OPERATE_EVENT = OPERATE_EVENT
      this._emitter = new EventEmitter()
      this.userController = new UserController()
    },
    ready() {
      // 在组件在视图层布局完成后执行
      console.log(TAG_NAME, 'ready', ENV, this.data.config)
      if (!tsignaling) {
        // tsignaling = new TSignaling({ SDKAppID: this.data.config.sdkAppID, tim: wx.$app })
        // tim为非必填参数，如果您的小程序中已存在IM实例，可以通过这个参数将其传入，避免IM实例的重复创建
        tim = wx.$TUIKit
        tsignaling = new TSignaling({ SDKAppID: this.data.config.sdkAppID, tim })
      }
      wx.setKeepScreenOn({
        keepScreenOn: true,
      })
    },
    detached() {
      // 在组件实例被从页面节点树移除时执行
      console.log(TAG_NAME, 'detached')
      this._reset()
    },
    error(error) {
      // 每当组件方法抛出错误时执行
      console.log(TAG_NAME, 'error', error)
    },
  },
  pageLifetimes: {
    show() {},
    hide() {
      // 组件所在的页面被隐藏时执行
      console.log(TAG_NAME, 'hide')
      if (!this.data.backgroundMute) {
        if (this.data.callStatus === CALL_STATUS.CALLING) {
          this._hangUp()
        }
        this._reset()
      }
    },
    resize(size) {
      // 组件所在的页面尺寸变化时执行
      console.log(TAG_NAME, 'resize', size)
    },
  },
})
