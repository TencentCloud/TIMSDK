// import { genTestUserSig } from '../../../debug/GenerateTestUserSig'
import logger from  '../../../utils/logger'
const app = getApp()
Component({
  /**
   * 组件的初始数据
   */
  data: {
    callingConfig: {
      sdkAppID: '',
      userID: '',
      userSig: '',
      type: 1,
    },

  },
  lifetimes: {
    created() {
      const { callingConfig } = this.data
      callingConfig.sdkAppID = app.globalData.SDKAppID
      callingConfig.userID = app.globalData.userInfo.userID
      callingConfig.userSig = app.globalData.userInfo.userSig
      this.setData({
        callingConfig,
      }, () => {
        // 将初始化后到TRTCCalling实例注册到this.TRTCCalling中，this.TRTCCalling 可使用TRTCCalling所以方法功能。
        this.TRTCCalling = this.selectComponent('#TRTCCalling-component')
        this.bindTRTCCallingOperateEvent()
        this.bindTRTCCallingRoomEvent()
        // 登录TRTCCalling
        this.TRTCCalling.login()
        logger.log(` TRTCCalling| calling-index login |ok | callingConfig:${JSON.stringify(this.data.callingConfig)}`)
      })
    },
  },

  /**
   * 组件的方法列表
   */
  methods: {
    handleCall({ userID, type }) {
      this.TRTCCalling.call({ userID, type })
    },
    invitedEvent() {},
    hangupEvent() {},
    rejectEvent() {
      this.TRTCCalling.hangup()
    },
    userLeaveEvent() {},
    onRespEvent() {
      this.TRTCCalling.hangup()
    },
    callingTimeoutEvent() {
      this.TRTCCalling.hangup()
    },
    lineBusyEvent() {
      this.TRTCCalling.hangup()
    },
    callingCancelEvent() {},
    userEnterEvent() {},
    callEndEvent(message) {
      console.error(message, 'callEndEvent')
      this.TRTCCalling.hangup()
      this.triggerEvent('sendMessage', {
        message: message.data.message,
      })
    },
    bindTRTCCallingRoomEvent() {
      const TRTCCallingEvent = this.TRTCCalling.EVENT
      this.TRTCCalling.on(TRTCCallingEvent.INVITED, this.invitedEvent)
      this.TRTCCalling.on(TRTCCallingEvent.HANG_UP, this.hangupEvent)
      this.TRTCCalling.on(TRTCCallingEvent.REJECT, this.rejectEvent, this)
      this.TRTCCalling.on(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
      this.TRTCCalling.on(TRTCCallingEvent.NO_RESP, this.onRespEvent, this)
      this.TRTCCalling.on(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent, this)
      this.TRTCCalling.on(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent, this)
      this.TRTCCalling.on(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
      this.TRTCCalling.on(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
      this.TRTCCalling.on(TRTCCallingEvent.CALL_END, this.callEndEvent, this)
    },
    unbindTRTCCallingRoomEvent() {
      const TRTCCallingEvent = this.TRTCCalling.EVENT
      this.TRTCCalling.off(TRTCCallingEvent.INVITED, this.invitedEvent)
      this.TRTCCalling.off(TRTCCallingEvent.HANG_UP, this.hangupEvent)
      this.TRTCCalling.off(TRTCCallingEvent.REJECT, this.rejectEvent)
      this.TRTCCalling.off(TRTCCallingEvent.USER_LEAVE, this.userLeaveEvent)
      this.TRTCCalling.off(TRTCCallingEvent.NO_RESP, this.onRespEvent)
      this.TRTCCalling.off(TRTCCallingEvent.CALLING_TIMEOUT, this.callingTimeoutEvent)
      this.TRTCCalling.off(TRTCCallingEvent.LINE_BUSY, this.lineBusyEvent)
      this.TRTCCalling.off(TRTCCallingEvent.CALLING_CANCEL, this.callingCancelEvent)
      this.TRTCCalling.off(TRTCCallingEvent.USER_ENTER, this.userEnterEvent)
      this.TRTCCalling.off(TRTCCallingEvent.CALL_END, this.callEndEvent)
    },
    callOperateEvent(message) {
      this.triggerEvent('sendMessage', {
        message: message.data.message,
      })
    },
    acceptOperateEvent(message) {
      this.triggerEvent('sendMessage', {
        message: message.data.message,
      })
    },
    rejectOperateEvent(message) {
      this.triggerEvent('sendMessage', {
        message: message.data.message,
      })
    },
    bindTRTCCallingOperateEvent() {
      const TRTCCallingOperateEvent = this.TRTCCalling.OPERATE_EVENT
      this.TRTCCalling.on(TRTCCallingOperateEvent.CALL, this.callOperateEvent, this)
      this.TRTCCalling.on(TRTCCallingOperateEvent.ACCEPT, this.acceptOperateEvent, this)
      this.TRTCCalling.on(TRTCCallingOperateEvent.REJECT, this.rejectOperateEvent, this)
    },
    unbindTRTCCallingOperateEvent() {
      const TRTCCallingOperateEvent = this.TRTCCalling.OPERATE_EVENT
      this.TRTCCalling.off(TRTCCallingOperateEvent.CALL, this.callOperateEvent)
      this.TRTCCalling.off(TRTCCallingOperateEvent.ACCEPT, this.acceptOperateEvent)
      this.TRTCCalling.off(TRTCCallingOperateEvent.REJECT, this.rejectOperateEvent)
    },
  },
})
