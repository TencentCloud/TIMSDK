<template>
  <div class="call-container" v-if="dialling || calling || isDialled">
    <div class="choose" v-if="isDialled">
      <div class="title">
        {{ toAccount }}&nbsp;来电话了
      </div>
      <div class="buttons">
        <div class="accept" @click="accept"></div>
        <div class="refuse" @click="refuse"></div>
      </div>
    </div>
    <div class="call" v-if="dialling || calling">
      <div class="title" v-if="dialling">
        正在呼叫&nbsp;{{ toAccount }}...
      </div>
      <div id="local" @click="changeMainVideo" :class="isLocalMain ? 'big' : 'small'" v-show="calling"></div>
      <div name="remote" :class="isLocalMain ? 'small' : 'big'" @click="changeMainVideo" v-show="calling"></div>
      <div class="duration" v-show="calling">
        {{ formatDurationStr }}
      </div>
      <div class="buttons">
        <div :class="isCamOn ? 'videoOn' : 'videoOff'" @click="videoHandler"></div>
        <div class="refuse" @click="leave"></div>
        <div :class="isMicOn ? 'micOn' : 'micOff'" @click="micHandler"></div>
      </div>
      <div class="mask" v-show="maskShow" :class="isLocalMain ? 'big' : 'small'" @click="changeMainVideo">
        <div>
          <img class="image" src="../../assets/image/camera-max.png"/>
          <p class="notice">摄像头未打开</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import RtcClient from '../../utils/rtc-client'
import { ACTION, VERSION } from '../../utils/trtcCustomMessageMap'
import { mapGetters, mapState } from 'vuex'
import { formatDuration } from '../../utils/formatDuration'

export default {
  name: 'CallLayer',
  data() {
    return {
      Trtc: undefined,
      isCamOn: true,
      isMicOn: true,
      maskShow: false,
      isLocalMain: true, // 本地视频是否是主屏幕显示
      start: 0,
      end: 0,
      duration: 0,
      hangUpTimer: 0, // 通话计时id
      ready: false,
      dialling: false, // 是否拨打电话中
      calling: false, // 是否通话中
      isDialled: false, // 是否被呼叫
    }
  },
  computed: {
    ...mapGetters(['toAccount', 'currentConversationType']),
    ...mapState({
      userID: state => state.user.userID,
      userSig: state => state.user.userSig,
      videoRoom: state => state.video.videoRoom,
      sdkAppID: state => state.user.sdkAppID
    }),
    formatDurationStr() {
      return formatDuration(this.duration)
    },
  },
  created() {
    window.addEventListener('beforeunload', () => {
      this.videoCallLogOut()
    })
    window.addEventListener('leave', () => {
      this.videoCallLogOut()
    })
  },
  mounted() {
    this.$bus.$on('isCalled', this.isCalled)
    this.$bus.$on('missCall', this.missCall)
    this.$bus.$on('isRefused', this.isRefused)
    this.$bus.$on('isAccept', this.isAccept)
    this.$bus.$on('isHungUp', this.isHungUp)
    this.$bus.$on('busy', this.busy)
    this.$bus.$on('video-call', this.videoCall)
  },
  beforeDestroy() {
    this.$bus.$off('isCalled', this.isCalled)
    this.$bus.$off('missCall', this.missCall)
    this.$bus.$off('isRefused', this.isRefused)
    this.$bus.$off('isAccept', this.isAccept)
    this.$bus.$off('isHungUp', this.isHungUp)
    this.$bus.$off('busy', this.busy)
    this.$bus.$off('video-call', this.videoCall)
  },
  methods: {
    videoCallLogOut() { // 针对，刷新页面，关闭Tab，登出情况下，通话断开的逻辑
      if (this.dialling || this.calling) {
        this.leave()
      }
      if (this.isDialled) {
        this.refuse()
      }
    },
    changeState(state, boolean) {
      let stateList = ['dialling', 'isDialled', 'calling']
      stateList.forEach(item => {
        this[item] = item === state ? boolean : false
      })
      this.$store.commit('UPDATE_ISBUSY', stateList.some(item => this[item])) // 若stateList 中存在 true , isBusy 为 true
    },
    async initTrtc(options) { // 初始化 trtc 进入房间
      this.Trtc = new RtcClient(options)
      await this.Trtc.createLocalStream({ audio: true, video: true }).then(() => { // 在进房之前，判断设备
          this.Trtc.join()
          this.ready = true
          this.isCamOn = true
          this.maskShow = false
      }).catch(() => {
        alert(
          '请确认已连接摄像头和麦克风并授予其访问权限！'
        )
        this.ready = false
      })
    },
    videoCall() { // 发起通话
      if (this.calling) { // 避免通话按钮多次快速的点击
        return
      }
      this.isLocalMain = true
      this.$store.commit('GENERATE_VIDEO_ROOM') // 初始化房间号
      const options = {
        userId: this.userID,
        userSig: this.userSig,
        roomId: this.videoRoom,
        sdkAppId: this.sdkAppID
      }
      this.initTrtc(options).then(() => {
        if (!this.ready) return
        this.changeState('dialling', true)
        this.timer = setTimeout(this.timeout, process.env.NODE_ENV === 'development' ? 999999 : 60000) // 开始计时器，开发环境超时时间较长，便于调试
        this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_DIALING)
      })
    },
    leave() { // 离开房间，发起方挂断
      if (!this.calling) { // 还没有通话，单方面挂断
        this.Trtc.leave()
        clearTimeout(this.timer)
        this.changeState('dialling', false)
        this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_SPONSOR_CANCEL)
        return
      }
      this.hangUp() // 通话一段时间之后，某一方面结束通话
    },
    timeout() { // 通话超时
      this.changeState('dialling', false)
      this.Trtc.leave()
      this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_SPONSOR_TIMEOUT)
    },
    isCalled() { // 被呼叫
      this.changeState('isDialled', true)
    },
    missCall() { // 错过电话，也就是发起方的电话超时挂断或自己挂断
      this.changeState('isDialled', false)
    },
    refuse() { // 拒绝电话
      this.changeState('isDialled', false)
      this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_REJECT)
    },
    isRefused() { // 对方拒绝通话
      this.changeState('dialling', false)
      clearTimeout(this.timer)
    },
    resetDuration(duration) {
      this.duration = duration
      this.hangUpTimer = setTimeout(() => {
        let now = new Date()
        this.resetDuration(parseInt((now - this.start) / 1000))
      }, 1000)
    },
    accept() { // 接听电话
      this.changeState('calling', true)
      const options = {
       userId: this.userID,
        userSig: this.userSig,
        roomId: this.videoRoom,
        sdkAppId: this.sdkAppID
      }
      this.initTrtc(options).then(() => {
        if (!this.ready) {
          this.changeState('calling', false)
          this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_ERROR)
          return
        }
        this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_ACCEPTED)
        this.start = new Date()
        clearTimeout(this.hangUpTimer)
        this.resetDuration(0)
      })
    },
    isAccept() { // 对方接听自己发起的电话
      clearTimeout(this.timer)
      this.changeState('calling', true)
      clearTimeout(this.hangUpTimer)
      this.resetDuration(0)
      this.start = new Date()
    },
    hangUp() { // 通话一段时间之后，某一方挂断电话
      this.changeState('calling', false)
      this.Trtc.leave()
      this.end = new Date()
      const duration = parseInt((this.end - this.start) / 1000)
      this.sendVideoMessage(ACTION.VIDEO_CALL_ACTION_HANGUP, duration)
      clearTimeout(this.hangUpTimer)
    },
    isHungUp() { // 通话一段时间之后，对方挂断电话
      if (this.calling) {
        this.changeState('calling', false)
        this.Trtc.leave()
        clearTimeout(this.hangUpTimer)
      }
    },
    busy(videoPayload, messageItem) {
      videoPayload.action = ACTION.VIDEO_CALL_ACTION_LINE_BUSY
      const message = this.tim.createCustomMessage({
        to: messageItem.from,
        conversationType: this.currentConversationType,
        payload: {
          data: JSON.stringify(videoPayload),
          description: '',
          extension: ''
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim.sendMessage(message)
    },
    videoHandler() { // 是否打开摄像头
      if (this.isCamOn) {
        this.isCamOn = false
        this.maskShow = true
        this.Trtc.muteLocalVideo()
      } else {
        this.isCamOn = true
        this.maskShow = false
        this.Trtc.unmuteLocalVideo()
      }
    },
    micHandler() { // 是否打开麦克风
      if (this.isMicOn) {
        this.isMicOn = false
        this.Trtc.muteLocalAudio()
      } else {
        this.isMicOn = true
        this.Trtc.unmuteLocalAudio()
      }
    },
    sendVideoMessage(action, duration = 0) {
      const options = {
        room_id: this.videoRoom,
        call_id: '',
        action,
        version: VERSION,
        invited_list: [],
        duration
      }
      const message = this.tim.createCustomMessage({
        to: this.toAccount,
        conversationType: this.currentConversationType,
        payload: {
          data: JSON.stringify(options),
          description: '',
          extension: ''
        }
      })
      this.$store.commit('pushCurrentMessageList', message)
      this.tim.sendMessage(message)
    },
    changeMainVideo() {
      if (!this.calling) {
        return
      }
      this.isLocalMain = !this.isLocalMain
    }
  }
}
</script>

<style lang="stylus" scoped>
.call-container
  background center url("data:image/png;base64,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")
  background-size cover
  position absolute
  z-index 999
.accept, .refuse, .videoOn, .videoOff, .micOn, .micOff
  height 50px
  width 50px
  box-sizing border-box
  border-radius 50%
  cursor:pointer
.accept
  background center no-repeat url("../../assets/image/call.png")
  background-size 60%
  background-color $success
.refuse
  background center no-repeat url("../../assets/image/close.png")
  background-size 70%
  background-color $danger
.videoOn
  background center no-repeat url("../../assets/image/big-camera-on.png")
.videoOff
  background center no-repeat url("../../assets/image/big-camera-off.png")
.micOn
  background center no-repeat url("../../assets/image/big-mic-on.png")
.micOff
  background center no-repeat url("../../assets/image/big-mic-off.png")
.buttons
  position absolute
  z-index 20
  width 100%
  top 75%
  display flex
  justify-content space-around
.duration
  color #fff
  position absolute
  z-index 20
  width 100%
  top 70%
  display flex
  justify-content center
.mask
  position absolute
  z-index 10
  background #D8D8D8
  height 100%
  width 100%
  display flex
  align-items center
  justify-content center
  space
  .image
    margin-left 15%
  .notice
    color #888888
.choose, .call
  color #fff
  background-color rgba(0, 0, 0, 0.8)
  height 100%
  width 100%
.title
  margin 25% 0 0 0
  text-align center
  width 100%
  position absolute
  z-index 10
  color  #fff
  font-size 40px
  font-weight 700
.big
  position absolute
  height 100%
  width 100%
.small
  position absolute
  z-index 999
  border-style solid
  border-width 1px
  border-color #808080
  height 50%
  width 50%
</style>