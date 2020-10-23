<template>
  <div class="bg-logo">
    <div class="bg">
      <div class="choose" v-if="!isCalling">
        <template v-if="type === 'call'">
          <div class="title">呼叫{{to}}中</div>
          <div class="btn">
            <div @click="handleCloseRoom" class="close">
              <image src="/static/images/close.png" class="operation"/>
            </div>
          </div>
        </template>
        <template v-if="type === 'onCall'">
          <div class="title">{{from}}正在呼叫</div>
          <div class="btn">
            <div @click="receive" class="close answer">
              <image src="/static/images/call.png" class="operation"/>
            </div>
            <div @click="handleRefuse" class="close">
              <image src="/static/images/close.png" class="operation"/>
            </div>
          </div>
        </template>
      </div>
      <div class="call" :style="isCalling ? {'display': 'flex', 'height': '100vh', 'width': '100vw'} : {'display': 'none'}">
        <div class="room">
          <webrtc-room
            id="webrtcroom"
            :autoplay="true"
            :enableCamera="true"
            :roomID="roomID"
            :userID="userID"
            :userSig="userSig"
            :sdkAppID="sdkAppID"
            :beauty="beauty"
            :muted="muted"
            @RoomEvent="onRoomEvent"
            smallViewLeft="calc(100vw - 30vw - 2vw)"
            smallViewTop="20vw"
            smallViewWidth="30vw"
            smallViewHeight="30vh">
          </webrtc-room>
          <div class="panel">
            <div class="close-btn">
              <div @click="microphone" class="normal">
                <image v-if="!muted" src="/static/images/voice.png" class="operation"/>
                <image v-else src="/static/images/voice-muted.png" class="operation"/>
              </div>
              <div @click="handleCloseRoom" class="close">
                <image src="/static/images/close.png" class="operation"/>
              </div>
              <div @click="monitor" class="normal">
                <image src="/static/images/monitor.png" class="operation"/>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import TYPES from '../../utils/types'
import {mapState} from 'vuex'
const ERROR_OPEN_CAMERA = -4 // 打开摄像头失败
const ERROR_OPEN_MIC = -5 // 打开麦克风失败
const ERROR_PUSH_DISCONNECT = -6 // 推流连接断开
const ERROR_CAMERA_MIC_PERMISSION = -7 // 获取不到摄像头或者麦克风权限
const ERROR_EXCEEDS_THE_MAX_MEMBER = -8 // 超过最大成员数
const ERROR_REQUEST_ROOM_SIG = -9 // 获取房间SIG错误
const ERROR_JOIN_ROOM = -10 // 进房失败
export default {
  data () {
    return {
      args: {},
      closeFlag: false,
      refuseFlag: false,
      isPending: true,
      isCalling: false,
      frontCamera: false,
      beauty: 0,
      muted: false,
      timeStamp: 0,
      sdkAppID: 0,
      userSig: '',
      userID: '',
      roomID: 0,
      type: '',
      from: '',
      to: '',
      timeoutId: '',
      startTime: 0
    }
  },
  computed: {
    ...mapState({
      rtcConfig: state => state.global.rtcConfig
    })
  },
  onShow () {
    // 初始化参数
    const loginOptions = this.rtcConfig
    this.userSig = loginOptions.userSig
    this.sdkAppID = loginOptions.sdkAppID
    this.userID = loginOptions.userID
    this.isCalling = false
    this.isPending = true
    if (this.userID === this.from) {
      this.timeoutId = setTimeout(() => {
        this.timeout()
      }, 60000)
    }
    wx.setKeepScreenOn({
      keepScreenOn: true
    })
    this.$store.commit('setCalling', true)
  },
  onUnload () {
    if (!(this.refuseFlag || this.closeFlag)) {
      if (this.isCalling) {
        this.closeRoom()
      } else {
        if (this.type === 'call') {
          this.closeRoom()
        } else {
          this.refuse()
        }
      }
    }
    this.refuseFlag = false
    this.closeFlag = false
    this.isCalling = false
    this.isPending = false
    clearTimeout(this.timeoutId)
    this.$store.commit('setCalling', false)
  },
  onHide () {
    this.isCalling = false
    this.isPending = false
    clearTimeout(this.timeoutId)
    this.closeRoom()
    this.$store.commit('setCalling', false)
    // 清理掉监听
    this.$bus.$off('onCall')
    this.$bus.$off('isCalling')
    this.$bus.$off('onClose')
    this.$bus.$off('onRefuse')
    this.$bus.$off('onBusy')
  },
  onLoad (options) {
    // onLoad的时候监听，在收到某些message的时候会触发的事件，可在main.js里查看事件 emit 条件
    console.log(options)
    this.args = JSON.parse(options.args)
    this.userID = this.$store.getters.myInfo.userID
    this.from = options.from
    this.to = options.to
    this.type = (this.userID === this.from) ? 'call' : 'onCall'
    this.roomID = this.args.room_id
    this.$bus.$on('onCall', () => {
      this.isCalling = true
      this.isPending = false
      this.startTime = new Date().getTime()
      clearTimeout(this.timeoutId)
      this.onCall()
    })
    this.$bus.$on('isCalling', (message) => {
      this.alreadyCalling(message)
    })
    this.$bus.$on('onClose', () => {
      this.closeFlag = true
      wx.navigateBack({
        delta: 1
      })
    })
    this.$bus.$on('onRefuse', () => {
      this.closeFlag = true
      wx.navigateBack({
        delta: 1
      })
    })
    this.$bus.$on('onBusy', () => {
      this.closeFlag = true
      wx.navigateBack({
        delta: 1
      })
    })
  },
  methods: {
    onRoomEvent (e) {
      if ([ERROR_OPEN_CAMERA,
        ERROR_OPEN_MIC,
        ERROR_PUSH_DISCONNECT,
        ERROR_CAMERA_MIC_PERMISSION,
        ERROR_EXCEEDS_THE_MAX_MEMBER,
        ERROR_REQUEST_ROOM_SIG,
        ERROR_JOIN_ROOM].includes(e.target.code)) {
        this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom')
        this.webrtcroomComponent.stop()
        this.args.action = -2
        this.args.code = e.target.code
        const data = JSON.stringify(this.args)
        // 对方发起视频，接通成功后如果是我挂断的，这时挂断消息应该发给视频发起方
        let to = (this.to === this.$store.getters.myInfo.userID) ? this.from : this.to
        const message = wx.$app.createCustomMessage({
          to: to,
          conversationType: TYPES.CONV_C2C,
          payload: {
            data: data,
            description: '',
            extension: ''
          }
        })
        this.$store.commit('sendMessage', message)
        wx.$app.sendMessage(message)
        clearTimeout(this.timeoutId)
      }
      if (e.target.tag === 'error') {
        wx.showToast({
          title: e.target.detail,
          duration: 1000
        })
      }
    },
    handleCloseRoom () {
      this.closeFlag = true
      this.closeRoom()
      wx.navigateBack({
        delta: 1
      })
    },
    handleRefuse () {
      this.refuseFlag = true
      this.refuse()
      wx.navigateBack({
        delta: 1
      })
    },
    // 发起方等待时挂断
    closeRoom () {
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom')
      this.webrtcroomComponent.stop()
      this.args.action = 5
      if (this.startTime === 0) {
        this.args.action = 1
      }
      if (this.startTime !== 0) {
        const endTime = new Date().getTime()
        this.args.duration = Math.round((endTime - this.startTime) / 1000)
        this.startTime = 0
      }
      const data = JSON.stringify(this.args)
      // 对方发起视频，接通成功后如果是我挂断的，这时挂断消息应该发给视频发起方
      let to = (this.to === this.$store.getters.myInfo.userID) ? this.from : this.to
      const message = wx.$app.createCustomMessage({
        to: to,
        conversationType: TYPES.CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      })
      this.$store.commit('sendMessage', message)
      wx.$app.sendMessage(message)
      clearTimeout(this.timeoutId)
    },
    // 发起方等待接收方超过60s
    timeout () {
      this.args.action = 3
      const data = JSON.stringify(this.args)
      const message = wx.$app.createCustomMessage({
        to: this.to,
        conversationType: TYPES.CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      })
      this.$store.commit('sendMessage', message)
      wx.$app.sendMessage(message)
      wx.navigateBack({
        delta: 1
      })
    },
    // 接受对方的请求
    receive () {
      this.args.action = 4
      const data = JSON.stringify(this.args)
      this.startTime = new Date().getTime()
      const message = wx.$app.createCustomMessage({
        to: this.from,
        conversationType: TYPES.CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      })
      this.$store.commit('sendMessage', message)
      wx.$app.sendMessage(message)
      clearTimeout(this.timeoutId)
      this.isCalling = true
      this.isPending = false
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom')
      this.webrtcroomComponent.start()
    },
    onCall () {
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom')
      this.webrtcroomComponent.start()
    },
    // 拒绝
    refuse () {
      this.args.action = 2
      const data = JSON.stringify(this.args)
      const message = wx.$app.createCustomMessage({
        to: this.from,
        conversationType: TYPES.CONV_C2C,
        payload: {
          data: data,
          description: '',
          extension: ''
        }
      })
      this.$store.commit('sendMessage', message)
      this.$store.commit('setCalling', false)
      wx.$app.sendMessage(message)
      clearTimeout(this.timeoutId)
    },
    alreadyCalling (item) {
      const options = JSON.parse(item.payload.data)
      options.action = 6
      const message = wx.$app.createCustomMessage({
        to: item.from,
        conversationType: TYPES.CONV_C2C,
        payload: {
          data: JSON.stringify(options),
          description: '',
          extension: ''
        }
      })
      this.$store.commit('sendMessage', message)
      wx.$app.sendMessage(message)
    },
    microphone () {
      this.muted = !this.muted
    },
    monitor () {
      this.webrtcroomComponent = this.$mp.page.selectComponent('#webrtcroom')
      this.webrtcroomComponent.switchCamera()
    }
  },
  destory () {}
}
</script>

<style lang='stylus' scoped>
.bg-logo
  background center / contain no-repeat url("data:image/png;base64,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")
.bg
  background-color rgba(0, 0, 0, 0.8)
  .choose
    display flex
    flex-direction column
    width 100vw
    height 100vh
.title
  height 70vh
  display flex
  align-items center
  justify-content center
  color white
  font-size 32px
  font-weight 700
.btn
  height 30vh
  width 100vw
  justify-content space-around
  display flex
.close
  background-color $danger
  height 50px
  width 50px
  padding 12px
  box-sizing border-box
  border-radius 50%
.answer
  background-color $success
.call
  display flex
  position relative
.close-btn
  z-index 999
  display flex
  width 100vw
  justify-content space-around
  box-sizing border-box
.time
  height 8vh
  width 100vw
  text-align center
  padding-top 30px
  color white
.panel
  z-index 999
  display flex
  width 100vw
  bottom 20px
  flex-direction column
  box-sizing border-box
  position absolute
.room
  position relative
  height 100vh
  width 100vw
.operation
  width 100%
  height 100%
.normal
  background-color transparent
  height 50px
  width 50px
  padding 10px
  box-sizing border-box
  border 2px solid white
  border-radius 50%
</style>
