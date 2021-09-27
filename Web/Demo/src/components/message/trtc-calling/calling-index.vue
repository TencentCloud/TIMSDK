<template>
    <div class="call-container" v-show="dialling || calling || isDialled">
        <div class="choose" v-show="isDialled">
            <div class="title">
                {{ sponsor }}来通话啦
            </div>
            <div class="buttons">
                <div class="accept" @click="handleDebounce(accept,500)"></div>
                <div class="refuse" @click="handleDebounce(refuse,500)"></div>
            </div>
        </div>
        <div class="call" v-show="dialling || calling">
            <div class="title" v-if="dialling && currentConversationType==='C2C'">
                正在呼叫{{toAccount}}...
            </div>
            <div class="title" v-if="dialling && currentConversationType==='GROUP'">
                正在呼叫...
            </div>

<!--            <div v-show="this.callingUserList.length < 2 && callType === TRTCCalling.CALL_TYPE.VIDEO_CALL && calling">-->
<!--                <div id="local" @click="changeMainVideo" :class="isLocalMain ? 'small' : 'big'" ></div>-->
<!--                <div v-for="userId in callingUserList" :id="`video-${userId}`" :key="`video-${userId}`" :class="isLocalMain ? 'big' : 'small'" @click="changeMainVideo"></div>-->
<!--            </div>-->
            <div v-show=" callType === TRTCCalling.CALL_TYPE.VIDEO_CALL && calling">
                <div class="small-group"  id="small-group">
                    <div  class="video-box"  id="local" ></div>
                    <div  class="video-box" v-for="userId in callingUserList" :id="`video-${userId}`" :key="`video-${userId}`">
                    </div>
                </div>
            </div>
            <div v-show="callType === TRTCCalling.CALL_TYPE.AUDIO_CALL && calling" class="audio-box">
                <div v-show="calling" class="aduio-call">
                    <img :src="myAvatar" class="audio-img">
                    <p style="text-align: center">
                        <span class="nick-text">{{myNick}}</span>
                        <i v-if="isMicOn" class="el-icon-microphone micr-icon" style="color: #006FFF;"></i>
                        <i  v-else  class="el-icon-turn-off-microphone micr-icon" ></i>
                    </p>
                </div>
                <div v-for="item in invitedUserInfo " class="aduio-call" :key="`video-${item.userID}`" >
                    <img :src="item.avatar || defaultAvatar" class="audio-img">
                    <p style="text-align: center">
                        <span class="nick-text">{{item.nick || item.userID}}</span>
                        <i v-if="item.isInvitedMicOn === true || item.isInvitedMicOn == undefined" class="el-icon-microphone micr-icon" style="color: #006FFF;"></i>
                        <i  v-else  class="el-icon-turn-off-microphone micr-icon" ></i>
                    </p>
                </div>
            </div>
            <div class="duration" v-show="calling">
                {{ formatDurationStr }}
            </div>
            <div class="buttons" v-if="callType === TRTCCalling.CALL_TYPE.VIDEO_CALL">
                <div :class="isCamOn ? 'videoOn' : 'videoOff'" @click="videoHandler"></div>
                <div class="refuse" @click="handleDebounce(leave,500)"></div>
                <div :class="isMicOn ? 'micOn' : 'micOff'" @click="micHandler"></div>
            </div>
            <div class="buttons" v-else>
<!--                <div :class="isCamOn ? 'videoOn' : 'videoOff'" @click="videoHandler"></div>-->
                <div class="refuse" @click="handleDebounce(leave,500)"></div>
                <div :class="isMicOn ? 'micOn' : 'micOff'" @click="micHandler"></div>
            </div>
<!--            <div class="mask" v-show="maskShow" :class="isLocalMain ? 'small' : 'big'" @click="changeMainVideo">-->
<!--                <div>-->
<!--                    <img class="image" src="../../../assets/image/camera-max.png"/>-->
<!--                    <p class="notice">摄像头未打开</p>-->
<!--                </div>-->
<!--            </div>-->
        </div>
    </div>
</template>

<script>
  import {mapGetters, mapState} from 'vuex'
  import { formatDuration } from '../../../utils/formatDuration'
  export default {
    name: 'CallLayer',
    data() {
      return {
        timeout:null,
        callType:1,   //1:audio，2:video
        Trtc: undefined,
        isCamOn: true,
        isMicOn: true,
        isInvitedMicOn:true,
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
        inviteID:'',
        inviteData:{},
        sponsor:'',   //发起者
        invitedUserID:[],  //被邀请者
        invitedNick:'',
        invitedUserInfo:[],
        defaultAvatar:'https://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-3.png',
        viewLocalDomID:'',
        callingUserList:[],  // 参加通话的人 ,不包括自己
        callingType:'C2C',  //区分多人和C2C通话的UI样式
        isStartLocalView:false,  //本地是否开启
        callingTips:{
          callEnd:1,   //通话结束
          callTimeout:5
        }
      }
    },
    computed: {
      ...mapGetters(['toAccount', 'currentConversationType']),
      ...mapState({
        currentConversation: state => state.conversation.currentConversation,
        currentUserProfile: state => state.user.currentUserProfile,
        callingInfo: state => state.conversation.callingInfo,
        userID: state => state.user.userID,
        userSig: state => state.user.userSig,
        videoRoom: state => state.video.videoRoom,
        sdkAppID: state => state.user.sdkAppID
      }),
      formatDurationStr() {
        return formatDuration(this.duration)
      },

      myAvatar() {
          return this.currentUserProfile.avatar || this.defaultAvatar
      },
      myNick() {

        return this.currentUserProfile.nick || this.userID
      }
    },
    created() {
      this.initListener()
    },
    watch: {
      callingUserList: {
        handler(newValue) {
          if(newValue.length < 2 && this.calling) {   //单人通话
            this.$nextTick(() => {
              let elementId = `video-${newValue[0]}`
              let element = window.document.getElementById(elementId)
              let local = window.document.getElementById('local')
              let group_element = window.document.getElementById('small-group')
              // element.addEventListener('click', this.changeMainVideo)
              // local.addEventListener('click', this.changeMainVideo)
              if (!element || !element.classList) {
                return
              }
              if (!local || !local.classList) {
                return
              }
              element && element.classList.remove('video-box')
              local && local.classList.remove('video-box')
              group_element && group_element.classList.add('small-group_box')
              this.isLocalMain ? element.classList.add('big') : element.classList.add('small')
              this.isLocalMain ? local.classList.add('small') : element.classList.add('big')
            })
            return
          }
          if (newValue.length >= 2 && this.calling) {
            let group_element = window.document.getElementById('small-group')
            group_element && group_element.classList.remove('small-group_box')
            let elements = window.document.getElementById('small-group').childNodes
              elements.forEach((item,index) => {
                if(index === 0) {
                  item.classList.remove('small')
                }
                item.classList.remove('big')
                item.classList.add('video-box')
              })
          }
        },
        deep: true,
        immediate: true
      }
    },
    destroyed() {
      this.removeListener()
      window.addEventListener('beforeunload', () => {
        this.videoCallLogOut()
      })
      window.addEventListener('leave', () => {
        this.videoCallLogOut()
      })
    },
    mounted() {
      this.$bus.$on('video-call', this.videoCalling)  // 发起通话
      this.$bus.$on('audio-call', this.audioCalling)  // 发起通话

    },
    beforeDestroy() {
      this.$bus.$off('video-call', this.videoCalling)
      this.$bus.$off('audio-call', this.audioCalling)  // 发起通话

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
      initListener() {
        // sdk内部发生了错误
        this.trtcCalling.on(this.TRTCCalling.EVENT.ERROR, this.handleError)
        // 被邀请进行通话
        this.trtcCalling.on(this.TRTCCalling.EVENT.INVITED, this.handleNewInvitationReceived)
        // 有用户同意进入通话，那么会收到此回调
        this.trtcCalling.on(this.TRTCCalling.EVENT.USER_ENTER, this.handleUserEnter)
        // 如果有用户同意离开通话，那么会收到此回调
        this.trtcCalling.on(this.TRTCCalling.EVENT.USER_LEAVE, this.handleUserLeave)
        // 用户拒绝通话
        this.trtcCalling.on(this.TRTCCalling.EVENT.REJECT, this.handleInviteeReject)
        //邀请方忙线
        this.trtcCalling.on(this.TRTCCalling.EVENT.LINE_BUSY, this.handleInviteeLineBusy)
        // 作为被邀请方会收到，收到该回调说明本次通话被取消了
        this.trtcCalling.on(this.TRTCCalling.EVENT.CALLING_CANCEL, this.handleInviterCancel)
        // 重复登陆，收到该回调说明被踢出房间
        this.trtcCalling.on(this.TRTCCalling.EVENT.KICKED_OUT, this.handleKickedOut)
        // 作为邀请方会收到，收到该回调说明本次通话超时未应答
        this.trtcCalling.on(this.TRTCCalling.EVENT.CALLING_TIMEOUT, this.handleCallTimeout)
        // 邀请用户无应答
        this.trtcCalling.on(this.TRTCCalling.EVENT.NO_RESP, this.handleNoResponse)
        // 收到该回调说明本次通话结束了
        this.trtcCalling.on(this.TRTCCalling.EVENT.CALLING_END, this.handleCallEnd)
        // 远端用户开启/关闭了摄像头, 会收到该回调
        this.trtcCalling.on(this.TRTCCalling.EVENT.USER_VIDEO_AVAILABLE, this.handleUserVideoChange)
        // 远端用户开启/关闭了麦克风, 会收到该回调
        this.trtcCalling.on(this.TRTCCalling.EVENT.USER_AUDIO_AVAILABLE, this.handleUserAudioChange)
      },
      removeListener() {
        this.trtcCalling.off(this.TRTCCalling.EVENT.ERROR, this.handleError)
        this.trtcCalling.off(this.TRTCCalling.EVENT.INVITED, this.handleNewInvitationReceived)
        this.trtcCalling.off(this.TRTCCalling.EVENT.USER_ENTER, this.handleUserEnter)
        this.trtcCalling.off(this.TRTCCalling.EVENT.USER_LEAVE, this.handleUserLeave)
        this.trtcCalling.off(this.TRTCCalling.EVENT.REJECT, this.handleInviteeReject)
        this.trtcCalling.off(this.TRTCCalling.EVENT.LINE_BUSY, this.handleInviteeLineBusy)
        this.trtcCalling.off(this.TRTCCalling.EVENT.CALLING_CANCEL, this.handleInviterCancel)
        this.trtcCalling.off(this.TRTCCalling.EVENT.KICKED_OUT, this.handleKickedOut)
        this.trtcCalling.off(this.TRTCCalling.EVENT.CALLING_TIMEOUT, this.handleCallTimeout)
        this.trtcCalling.off(this.TRTCCalling.EVENT.NO_RESP, this.handleNoResponse)
        this.trtcCalling.off(this.TRTCCalling.EVENT.CALLING_END, this.handleCallEnd)
        this.trtcCalling.off(this.TRTCCalling.EVENT.USER_VIDEO_AVAILABLE, this.handleUserVideoChange)
        this.trtcCalling.off(this.TRTCCalling.EVENT.USER_AUDIO_AVAILABLE, this.handleUserAudioChange)
      },

      handleError() {},
      // 被呼叫  接听方
      async handleNewInvitationReceived (payload) {
        const { inviteID, sponsor, inviteData, userIDList, isGroupCall } = payload
        this.inviteID = inviteID
        this.inviteData = inviteData
        this.callType = inviteData.callType
        this.sponsor = sponsor
        this.invitedUserID = JSON.parse(JSON.stringify(userIDList))//被邀请者
        this.callingInfo.type = isGroupCall ? this.TIM.TYPES.CONV_GROUP : this.TIM.TYPES.CONV_C2C
        this.changeState('isDialled', true)
      },

      accept() {
        this.trtcCalling.accept({
          inviteID: this.inviteID,
          roomID: this.inviteData.roomID,
          callType: this.inviteData.callType
        }).then((res) => {
          // this.callType = this.inviteData.callType
          this.changeState('calling', true)
          res.data.message.nick = this.currentUserProfile.nick
          this.$store.commit('pushCurrentMessageList', res.data.message)
        })
      },
      reject() {
        const { callType } = this.inviteData
        this.trtcCalling.reject({
          inviteID: this.inviteID,
          isBusy: false,
          callType
        }).then((res) =>{
          res.data.message.nick = this.currentUserProfile.nick
          this.$store.commit('pushCurrentMessageList', res.data.message)
        })
      },
      handleDebounce (func, wait) {
        let context = this
        let args = arguments
        if (this.timeout) clearTimeout(this.timeout)
        this.timeout = setTimeout(() => {
          func.apply(context, args)
        }, wait)
      },
      // 双方建立连接
      handleUserEnter({ userID }) {
        this.changeState('dialling', true)
        this.isAccept()
        // 判断是否为多人通话
        if (this.callingUserList.length >= 2) {
          this.callingType = this.TIM.TYPES.CONV_GROUP
        }
        if (this.callingUserList.indexOf(userID) === -1) {
          if (this.callType === this.TRTCCalling.CALL_TYPE.AUDIO_CALL ) {
            this.getUserAvatar(userID)
          } else {
            this.callingUserList.push(userID)
          }
        }
        if (this.callType === this.TRTCCalling.CALL_TYPE.VIDEO_CALL ) {
          this.$nextTick(() => {
            if (!this.isStartLocalView) {
              this.startLocalView()    //本地只开启一次
            }
            this.startRemoteView(userID)   //远端多次拉流
          })
        }
      },
      // 通话已建立
      handleUserLeave({ userID }) {
        if( this.callType === this.TRTCCalling.CALL_TYPE.AUDIO_CALL ) {
          // 语音通话
          const _index = this.invitedUserInfo.findIndex(item => item.userID === userID)
          if (_index >= 0) {
            this.invitedUserInfo.splice(_index, 1)
          }
          return
        }
        const index = this.callingUserList.findIndex(item => item === userID)
        if (index >= 0) {
          this.callingUserList.splice(index, 1)
        }
      },
      // 通知呼叫方，未接通
      //userID:invitee(被邀请者）
      handleInviteeReject({ userID }) {
          if (this.userID === this.sponsor) {
              // 发起者
              this.setCallingstatus(userID)
              this.$store.commit('showMessage', {
                  message: `${userID}拒绝通话`
              })
          }
      },
      setCallingstatus(userID) {
        const _index = this.invitedUserID.indexOf(userID)
        if (_index >= 0) {
          this.invitedUserID.splice(_index, 1)
        }
        if ( this.invitedUserID.length ===0 ) {
          this.changeState('isDialled', false)
          this.changeState('dialling', false)
        }
      },
      // 通知呼叫方，对方在忙碌，未接通
      handleInviteeLineBusy({ sponsor, userID }) {
        // A call B,C call A, A在忙线， 拒绝通话，对于呼叫者C收到通知，XXX在忙线
        if( sponsor === this.userID ) {
          this.setCallingstatus(userID)
          this.$store.commit('showMessage', {
            message: `${userID}忙线`
          })
        }
      },
      // 通知被呼叫方，邀请被取消，未接通
      handleInviterCancel() {
        // 邀请被取消
        this.changeState('isDialled', false)
        this.$store.commit('showMessage', {
          message: '通话已取消'
        })
      },

      handleKickedOut() {
        // //重复登陆，被踢出房间
        // this.trtcCalling.logout();
        // this.$store.commit("userLogoutSuccess");
      },
      // 当自己收到对端超时的信令时，或者当我是被邀请者但自己超时了，通知上层通话超时
      // case: A呼叫B，B在线，B超时未响应，B会触发该事件，A也会触发该事件
      handleCallTimeout({ userIDList }) {
        if(this.calling) {
          return
        }
        if (this.userID === this.sponsor) {   // 该用户是邀请者
          userIDList.forEach((userID) =>{
            this.setCallingstatus(userID)    //超时未接听
          })
          return
        }
         //用户是被邀请者
        if(userIDList.indexOf(this.userID) > -1) {   //当超时者是自己时，添加消息
          //会话列表切换后发消息
          this.toAccount && this.sendMessage(this.userID,'',this.callingTips.callTimeout)
        }
        this.changeState('isDialled', false)
      },
      // 双方，通话已建立, 通话结束
      handleCallEnd({userID, callEnd}) {
         // 自己挂断的要补充消息  被邀请者都无应答时结束
         // 历史消息中没有通话结束
        if(userID === this.userID && this.invitedUserID.length === 0 || this.callingUserList === 0) {
          this.sendMessage(userID,callEnd,this.callingTips.callEnd)
        }
        //   this.changeState('isDialled', false)
        //   this.changeState('calling', false)
          this.changeState('dialling', false)
          this.isMicOn = true
          this.isCamOn = true
          this.maskShow = false
          this.isStartLocalView = false
          // this.$store.commit('showMessage', {
          //   message: '通话已结束'
          // })

      },
      // 自己超时且是邀请发起者，需主动挂断，并通知上层对端无应答
      handleNoResponse({ sponsor, userIDList }) {  //邀请者
        if(sponsor === this.userID) {
          userIDList.forEach((userID) =>{
            this.setCallingstatus(userID)
          })
          if(userIDList.indexOf(this.userID) === -1) {   //当超时者是自己时，添加消息
            this.sendMessage(userIDList,'',this.callingTips.callTimeout)
          }
        }

      },
      handleUserVideoChange() {

      },

      handleUserAudioChange(payload) {
        const _index = this.invitedUserInfo.findIndex(item => item.userID === payload.userID)
        if (_index >= 0) {
          this.invitedUserInfo[_index].isInvitedMicOn = payload.isAudioAvailable
        }
        // this.isInvitedMicOn = payload.isAudioAvailable
      },

      // 播放本地流
      startLocalView() {
        this.trtcCalling.startLocalView({
          userID: this.userID,
          videoViewDomID: 'local'
        }).then(()=>{
          this.isStartLocalView = true
        })
      },

      // 没有用到
      stopLocalView() {
        this.trtcCalling.stopLocalView({
          userID: this.userID,
          videoViewDomID: this.viewLocalDomID
        })
      },
      // 播放远端流
      startRemoteView(userID) {
        this.trtcCalling.startRemoteView({
          userID: userID,
          videoViewDomID: `video-${userID}`
        }).then(()=>{

        })
      },
      //没有用到
      stopRemoteView(userID) {
        this.trtcCalling.stopRemoteView({
          userID: this.userID,
          videoViewDomID: `video-${userID}`
        })
      },
      //获取被呼叫者信息
      getUserAvatar(userID) {
        const _index = this.invitedUserInfo.findIndex(item => item.userID === userID)
        if (_index >= 0) {
          return
        }
        let _userIDList = [userID]
        let promise = this.tim.getUserProfile({
          userIDList:_userIDList  // 请注意：即使只拉取一个用户的资料，也需要用数组类型，例如：userIDList: ['user1']
        })
        promise.then((imResponse)=> {
          if (imResponse.data[0]) {
            this.invitedUserInfo.push(imResponse.data[0])
          }
        }).catch(()=> {
        })
      },
      changeState(state, boolean) {
        let stateList = ['dialling', 'isDialled', 'calling']
        stateList.forEach(item => {
          this[item] = item === state ? boolean : false
        })
        this.$store.commit('UPDATE_ISBUSY', stateList.some(item => this[item])) // 若stateList 中存在 true , isBusy 为 true
      },
      videoCalling() { // 发起通话
        // 初始化被邀请者
        this.invitedUserID =JSON.parse(JSON.stringify(this.callingInfo.memberList))
        this.sponsor = this.userID
        if (this.calling) { // 避免通话按钮多次快速的点击
          return
        }
        this.callType = this.TRTCCalling.CALL_TYPE.VIDEO_CALL
        this.isLocalMain = true
        // 可设置超时
        if(this.callingInfo.type === this.TIM.TYPES.CONV_C2C) {
          this.trtcCalling.call({
            userID: this.callingInfo.memberList[0],
            type: this.callType,
            timeout: 30
          }).then((res)=>{
            res.data.message.nick = this.currentUserProfile.nick
            this.$store.commit('pushCurrentMessageList', res.data.message)
            this.changeState('dialling', true)
          })
        } else {
            this.trtcCalling.groupCall({
            userIDList: this.callingInfo.memberList,
            type: this.callType,
            groupID: this.currentConversation.groupProfile.groupID,
            timeout: 30
          }).then((res)=>{
            res.data.message.nick = this.currentUserProfile.nick
            this.$store.commit('pushCurrentMessageList', res.data.message)
            this.changeState('dialling', true)
          })
        }


      },
      audioCalling() { // 发起通话
        // 初始化被邀请者
        this.invitedUserID = this.callingInfo.memberList
          this.sponsor = this.userID
        if (this.calling) { // 避免通话按钮多次快速的点击
          return
        }
        // // 发起者获取被邀约人信息
        // this.getUserAvatar()
        // 可设置超时
        this.callType = this.TRTCCalling.CALL_TYPE.AUDIO_CALL
        if(this.callingInfo.type === 'C2C') {
          this.trtcCalling.call({
            userID: this.callingInfo.memberList[0],
            type: this.callType,
            timeout: 30
          }).then((res)=>{
            this.changeState('dialling', true)
            res.data.message.nick = this.currentUserProfile.nick
            this.$store.commit('pushCurrentMessageList', res.data.message)

          })
        } else {
          this.trtcCalling.groupCall({
            userIDList: this.callingInfo.memberList,
            type: this.callType,
            groupID: this.currentConversation.groupProfile.groupID,
            timeout: 30
          }).then((res)=>{
            this.changeState('dialling', true)
            res.data.message.nick = this.currentUserProfile.nick
            this.$store.commit('pushCurrentMessageList', res.data.message)
          })
        }
      },
      leave() { // 离开房间，发起方挂断
        this.isMicOn = true
        this.isCamOn = true
        this.maskShow = false
        this.isStartLocalView = false
        if (!this.calling) { // 还没有通话，单方面挂断
          this.trtcCalling.hangup().then((res) => {
            res.data.message.nick = this.currentUserProfile.nick
            this.$store.commit('pushCurrentMessageList', res.data.message)
            this.changeState('dialling', false)
            clearTimeout(this.timer)

          })
          return
        }
        this.hangUp() // 通话一段时间之后，某一方面结束通话
      },

      refuse() { // 拒绝电话
        this.changeState('isDialled', false)
        this.reject()
      },
      resetDuration(duration) {
        this.duration = duration
        this.hangUpTimer = setTimeout(() => {
          let now = new Date()
          this.resetDuration(parseInt((now - this.start) / 1000))
        }, 1000)
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
        this.trtcCalling.hangup()
        this.$store.commit('showMessage', {
          message: '已挂断'
        })
      },
      videoHandler() { // 是否打开摄像头
        if (this.isCamOn) {
          this.isCamOn = false
          this.maskShow = true
          this.trtcCalling.closeCamera()
        } else {
          this.isCamOn = true
          this.maskShow = false
          this.trtcCalling.openCamera()
        }
      },
      micHandler() { // 是否打开麦克风
        if (this.isMicOn) {
          this.trtcCalling.setMicMute(true)
          this.isMicOn = false
        } else {
          this.trtcCalling.setMicMute(false)
          this.isMicOn = true
        }
      },
      changeMainVideo() {
        if (!this.calling) {
          return
        }
        this.isLocalMain = !this.isLocalMain
      },
     async sendMessage(userId,callEnd,callText) {
        let call_text= ''
       userId = Array.isArray(userId) ? userId.join(',') : userId
        let messageData = {
          to: this.toAccount,
          from:userId,
          conversationType: this.currentConversationType,
          payload: {
            data: '',
            description: '',
            extension: ''
          }
        }

        const message = await this.tim.createCustomMessage(messageData)
        switch (callText) {
          case this.callingTips.callEnd:
            if (this.currentConversationType === this.TIM.TYPES.CONV_GROUP) {
              call_text = '结束群聊'
              break
            } else {
              call_text = callEnd === 0 ?'取消通话' : `结束通话，通话时长：${formatDuration(callEnd || this.duration)}`
              break
            }
          case this.callingTips.callTimeout:
            call_text = '无应答'
            break
          default:
            call_text = ''
            break
        }
        if (this.currentConversationType === this.TIM.TYPES.CONV_GROUP) {
          message.groupID = this.toAccount
          let customData = {
            operationType:256,
            text:call_text,
            userIDList:[]
          }
          message.payload = customData

        }
        if (this.currentConversationType === this.TIM.TYPES.CONV_C2C) {
          let customData = {
            text:call_text
          }
          message.payload = customData

        }
        if (this.currentConversationType === this.TIM.TYPES.CONV_GROUP) {
          message.type = this.TIM.TYPES.MSG_GRP_TIP
        }
        message.callType = 'callingTips'
        this.$store.commit('pushCurrentMessageList', message)
      },
    }
  }
</script>

<style lang="stylus" scoped>
    .call-container
        background center url("data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAEEAAABACAYAAAEyrCp2AAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAkqSURBVGhD7Zp7cFxVHcedwTTNPrK77RQUplKQPqAdcAZ1mMGOMtOKDAoK8hABUR5FsSiPWvpEW0atY6XwB8gI7VgoraQC6oC0SSi2naalrRSqttkkTSL0IZKGbV7No3z9fu+5t7m7uXd3sxsTB+9nZufunnvub7/3e8895/zuuR9BHuRf6RO19daPyQ9bG8R/bLYOVqWJGZUSPzFbhwGRRt8KlC4EYndbRRYDKkVnmUoT51pFFlalaXUN1o9zV1gblC0y2/LLzdaqlIuclfKrcEFVIyLXWL9R+mWzdbAqfKbaVBi92FRILLD2WaRFCNNZVTh7qbXPYsBfRK4029iNZmtVmL6pGbFrrd+IftVsp37fbK0K2chZIR+GNsjnDjTh8q1vW9914k6zEpaFbF5L/mwXZHAyiFqSnBNOEFksFCTM65Fg67ruMVPmJmuQp3fR/jvNpVDzFGrHF95rvjtkDSKe3ZweROi6nm5fQjG0xhZD0UE+LAFWtR3FqdvrrIJHfsse8QfWV4umd3gJvwc8XmMXZGAFWN+ewqf3NFkFfgESD9kFGVgBVlPB+B3ZFSjA7LV2oYuspxC+rz/A5OUMMseUu8kaIMGu+tBhE8D6zQAzXP2ZyBogzgCRq/sDnMOuPXa7+e6QNcAzdD769f4AQgEmftv+QbIGEGGXAjHph0aVgxVgTXsrJu00I9Gjq4ExrOSwbiPP/S77h02MqsbOMN+tAMXwIQgwFAQiHNJE1Pd0Y30qhef+ncKfDrXZpcDeWmDlBrb9rWyie+xCF23twJMvcf9fuH3dLhwEaSJ0g2no003mDH9CN5uGQd1w7pHdQR2QBmjdgBrpnUE7X/K6HF4iKt40W5EpQt1pyDUPzUXBToQe5CXaZr57idCUJcSepq/P1MlGwSJkuXriZX8Eml0iNFNJ/osd7DwKYddexrKO4+YYPwoWUa4zpgjNta6hoNFf6Rch/n6IQjhgae4VYu9+9Jgp96Kohhm934jQsKL5mluE2E8hYXb2GmbC3wD+ecTekUFRIkTkNn8RolZCmFlpEln2Nd7uJpdKo2gRIsQZqp8IUSchN7AOx8zQZcDmnfYOmzQRI0UgwiEQIQIBgYBAQJqA59tSqGg5hrWHU+g58YFdCjzFecGqTZyobAe6PSYiFZXcX8UPJzI7zXOcvEkTcE5TEh9/sx7x6iSOHe//p9Ff5ODDka58PtDaZRe6OJ+DT/lNHMB+xBHTJ5X2Y8gFJH4GPMwZdb6kCbjknUZctK8JF2xrRFv3Cbt08ALCHsO0H3k1wkwBNf3TB4tMAQlO4ea/aO/MQZqA83gJJvASnPZq9kvwGlPx9a6kxktAyOOBhhcFtQEJiLlsdguI/9QIiHPmfOsqu0IWChaQWAw8Vm32uwUs5C0ZY24hAWWzc+cPRQkI2w+f3QLW/Q2YsswIiN8LXLHc1PGjKAHxe4Al69IFrGbbqGPyUv6AEVDG6Xpbpx3Ig4IEbOVdELcFRPjHmQLElKVGQOy7wMU8zo+CBIjEIiMgdgsvxcyBAurlAnNICQhx35EWU55JwQLWcr7vCIh4CBDn6skeBajOtFl2YQYFCxBxnWEWAQ1M0yJM61SnjMlOstne4aIoAb+ryS5ATGGZ6kSvB8ZfZxe6KEqASOQQ0HCY+2/mh39exgx7R8b+ogVUaJUjiwAxmSm8BCinHHupXWiTJuBTzfWYsrcBE16rR5tLQJgHJZgdxxcA72cIEGO0/1vczgWe9hDQwIQ1ci1PQoktT+alV+0dJE3ASBAICAQEAkZcwP8CgQkkMIEEJpDABBKYQAITiK8JT7a14IzG/Ri3L4n4G0lEt9Vi1Mb9mLyhASnXNNph+VMMNh045Qpg1I1AKfO0kvuBM38xcH7vRePbwKSrGWMGj+O0upS5QSnTsVOY+1/0a6bdOdYMi8HXBC12KYHRgpeSGC16KZHRwpc7mXHQIpgSGy2EKbnRYpgSHC2I5WOCVm+V/mvxVMmPFsuUAFlr2g8x9X8cONhqVx5ifE1YSRMmNNbi9P11GLenDmNqkohU1WLqxgOeLeG/aYIeypUvYfb/S+BIyj5gCPE1IXXiBBp6elDf3Y26491IdvWgtqMHBzp64XrKfZJ8TGjvNh8vcpmgdf3IItZZBtQyHx9KfE042NeDzZ0d2NLOT4qf1g5sfq8DO97rRK+HC/mYsDEJfGmltxH5mKAnpDGm8Gc+COwbQiOy9gmfZJ8wnn3Cx9gnjGOfEGOfcH4RfYKeQZbwas5kR9eecYvka4Le8ojOBc7m9nXGGwqGtWOUCXqLJMKrefFyoKX/JSRfE/Rq+Vm/Asa4TLCeFnPkGXcfsKXWDlAEI2KCnkhH5gCf5YkdPmr2+Zmg1ynWvAUsfAUI8btjgl630TPb0+4BXnnDxCiUETNBr/NE7gamcnuwhR/e434mOI/p5vyBRuiRvW2C9eR8NuvPAl7YYeoUwrCbEHKZoIfj4TuA83hFq2qAC2/2NsH9sPSBF4Ey3gonTaCR0Tv5nf/5zCa70iAZVhPebQdm/IYnzj7BMUHvVZXfwnues8T4pTz+yuwmiHkvMAaPdUywVhFup8GcqT7xsl1pEAyrCaKDw+P0R1lPV9I2wVoE0LtdM/MzQcz7vVnLc5sgMyPXAyu4bzAMuwmiRS3iEV45nUSBJoj5FfxPHW+boDh6Ca7kKmAJ9eTLiJgg9BLl539OI2zxhZgg5j/HOrexvssELayUMpFb8IRdKQcjZoI4qhbBYbKMwgs1QSxYxxgywGWC3kYsuQy4i/lGLkbUBNHBfZfwREu1IlWgCWLhs/z/b6aboFglTM3vWAr09tgVPfA1YSVNOIsmnEETTt1Tj7E1dYhWJTGt0tuEFTRhFP8wzCta/h2K0dDF8XwSZ3vZTBAptQgOex/9Am8PNuMoT6Rc9zk7z1EcSfIxQSxeQ9NoQJgjTZj9gmLp3VTFvYqzS3gkfsLXhHf7erG7qwt/7ezE7vZO7DrWhV3vd+Gt1uPo+2BgtOaDQOUujvecvVXtBar3ccsprV4Z6O1/sccX5mnYwpOt3M3jOEOs/gc/PF5J16Es7z5nspP1KxnH0qFY+lDXhu1AMuMlHgdfE/6fCEwggQkkMIEEJpDABBKYAOA/AsZRNa1jRE0AAAAASUVORK5CYII=")
        background-size cover
        position absolute
        z-index 999

    .accept, .refuse, .videoOn, .videoOff, .micOn, .micOff
        height 50px
        width 50px
        box-sizing border-box
        border-radius 50%
        cursor: pointer

    .accept
        background center no-repeat url("../../../assets/image/call.png")
        background-size 60%
        background-color $success

    .refuse
        background center no-repeat url("../../../assets/image/hangup.png")
        background-size 70%
        background-color $danger

    .videoOn
        background center no-repeat url("../../../assets/image/big-camera-on.png")

    .videoOff
        background center no-repeat url("../../../assets/image/big-camera-off.png")

    .micOn
        background center no-repeat url("../../../assets/image/big-mic-on.png")

    .micOff
        background center no-repeat url("../../../assets/image/big-mic-off.png")

    .buttons
        position absolute
        z-index 20
        width 70%
        top 75%
        display flex
        justify-content space-around
        margin 0 15% 0 15%
    .audio-box
        position absolute
        z-index 20
        width 70%
        top 200px
        display flex
        justify-content center
        margin 0 15% 0 15%
    .aduio-call
        box-sizing border-box
        width 140px
        height 100px
    .audio-img
        display block
        width 60px
        height 60px
        border-radius 50%
        margin 0 auto 13px
    .micr-icon
        cursor pointer
        font-size 28px
        /*display block*/
        /*text-align center*/
    .nick-text
        color #dddddd
        font-size 12px
        margin-right 5px
        vertical-align super

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
        color #fff
        font-size 40px
        font-weight 700

    .big
        position absolute
        height 100%
        width 100%

    .small
        position absolute
        margin-left 74.8%
        z-index 999
        border-style solid
        border-width 1px
        border-color #808080
        height 44.8%
        width 25.2%
    .big-group
        height 60vh
        width 100%

    .small-group
        display flex
        flex-wrap wrap
        position absolute
        /*z-index 999*/
        /*border-style solid*/
        /*border-width 1px*/
        /*border-color #808080*/
        /*height 30%*/
        width 100%
        /*height 100%*/
    .small-group_box {
        height 100%
    }
    .video-box
       width 33.3%
       height 25vh


</style>
