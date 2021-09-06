<template>
  <div
    v-show="callingFlag"
    class="calling-container">
    <trtc-calling
      id="TRTCCalling-component"
      class="calling-component"
      :config="config"
      :pusherAvatar="pusherAvatar"
      :avatarList="avatarList"
    ></trtc-calling>
    <div v-if="incomingCallFlag" class="incoming-call">
      <img :src="inviter.avatar" />
      <div class="tips">{{invitation.inviter}}</div>
      <div class="tips" >{{'邀请你' + (invitation.callType === 1 ? '语音' : '视频') + '通话'}}</div>
      <div class="btn-operate">
        <div class="call-operate" style="background-color: red" @click="handleOnReject">
          <img src="../../static/images/hangup.png" />
        </div>
        <div class="call-operate" style="background-color: #07c160" @click="handleOnAccept">
          <img src="../../static/images/hangup.png" style="transform: rotate(-135deg)" />
        </div>
      </div>
    </div>
    <div v-if="inviteCallFlag" class="invite-call">
      <img :src="invitee.avatar" />
      <div v-if="action === 'call'" class="tips" >{{'等待' + invitee.userID + '接受邀请'}}</div>
      <div v-if="action === 'groupCall'" class="tips" >{{'正在发起通话'}}</div>
      <div class="btn-operate">
        <div class="call-operate" style="background-color: red" @click="handleOnCancel">
          <img src="../../static/images/hangup.png" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import defaultImg from '../../static/images/default_calling_icon.png'
export default {
  name: 'calling',
  data () {
    return {
      action: '',
      callingFlag: false,
      pusherAvatar: '',
      invitee: {},
      inviter: {},
      invitation: {},
      incomingCallFlag: false,
      inviteCallFlag: false,
      config: {
        sdkAppID: '',
        userID: '',
        userSig: '',
        type: 0
      },
      defaultAvatar: defaultImg,
      userIDList: [],
      avatarList: [], // 通话成员的头像
      groupID: '' // 发起群组通话的群组D
    }
  },
  created () {
    const { sdkAppID, userID, userSig } = this.rtcConfig
    this.config = {
      sdkAppID,
      userID,
      userSig,
      type: 0
    }
  },
  onShow () {
    console.warn('callData--->show', this.callData)
    const { action, sponsor, to, userIDList, inviteData } = this.callData
    // 防止某些手机初始化加载时触发onshow
    if (!action) { return }
    this.setCallingUserInfo()
    this.config.type = inviteData.callType
    this.userIDList = [...userIDList]
    switch (action) {
      case 'call':
        this.callingFlag = true
        this.inviteCallFlag = true
        this.action = action
        this.$parent.hideChatContainer()
        this.call()
        break
      case 'groupCall':
        this.callingFlag = true
        this.inviteCallFlag = true
        this.action = action
        this.groupID = to
        this.$parent.hideChatContainer()
        this.groupCall()
        break
      case 'invited':
        this.invitation = {
          inviter: sponsor,
          ...inviteData
        }
        this.incomingCallFlag = true
        this.$parent.hideChatContainer()
        break
      default:
        break
    }
  },
  mounted () {
    // 对方接受邀请
    this.$bus.$on('user-enter', (data) => {
      const { inviteCallFlag = false } = data
      this.inviteCallFlag = inviteCallFlag
    })
    // 对方拒绝邀请
    this.$bus.$on('call-reject', (data) => {
      const { callingFlag = false } = data
      this.callingFlag = callingFlag
      this.$parent.showChatContainer()
      this.$store.commit('setCallData', { action: '', data: {} })
      this.onBack()
    })
    // 发起方取消通话
    this.$bus.$on('call-cancel', (data) => {
      const { incomingCallFlag = false } = data
      this.incomingCallFlag = incomingCallFlag
      this.$parent.showChatContainer()
      // this.$store.commit('setCalling', false)
      this.$store.commit('setCallData', { action: '', data: {} })
      this.onBack()
    })
    // 监听挂断操作
    this.$bus.$on('call-end', (data) => {
      const { callingFlag = false, incomingCallFlag = false } = data
      this.callingFlag = callingFlag
      this.incomingCallFlag = incomingCallFlag
      this.$parent.showChatContainer()
      // this.$store.commit('setCalling', false)
      this.$store.commit('setCallData', { action: '', data: {} })
      this.onBack()
    })
    // 忙线中
    this.$bus.$on('line-busy', (data) => {
      const { callingFlag = false, incomingCallFlag = false } = data
      this.callingFlag = callingFlag
      this.incomingCallFlag = incomingCallFlag
      this.$parent.showChatContainer()
      // this.$store.commit('setCalling', false)
      this.$store.commit('setCallData', { action: '', data: {} })
      this.onBack()
    })
  },
  onUnload () {
    console.warn('component start to destroy')
    this.$bus.$off('user-enter')
    this.$bus.$off('call-reject')
    this.$bus.$off('call-cancel')
    this.$bus.$off('call-end')
    this.$bus.$off('no-resp')
    this.$bus.$off('line-busy')
    this.$bus.$off('call-timeout')
  },
  computed: {
    ...mapState({
      rtcConfig: state => state.global.rtcConfig,
      callData: state => state.global.callData,
      currentPage: state => state.global.currentPage,
      myInfo: state => state.user.myInfo
    })
  },
  methods: {
    // 设置通话双方用户信息
    setCallingUserInfo () {
      const { action, sponsor, to, avatarList = {} } = this.callData
      console.warn('avatarList--calling', avatarList)
      this.avatarList = {...avatarList}
      if (action === 'call') {
        this.inviter.userID = sponsor
        this.pusherAvatar = this.myInfo.avatar || this.defaultAvatar
        this.inviter.avatar = ''
        this.invitee.userID = to
        this.invitee.avatar = avatarList[this.invitee.userID]
      }
      if (action === 'groupCall') {
        this.inviter.userID = sponsor
        this.pusherAvatar = this.myInfo.avatar || this.defaultAvatar
        this.inviter.avatar = ''
        this.invitee.userID = to
        this.invitee.avatar = this.defaultAvatar
      }
      if (action === 'invited') {
        this.inviter.userID = sponsor
        this.pusherAvatar = this.myInfo.avatar || this.defaultAvatar
        this.inviter.avatar = avatarList[this.inviter.userID]
        this.invitee.userID = this.myInfo.userID
        this.invitee.avatar = ''
      }
    },
    // 1v1通话
    async call () {
      const message = await wx.$TRTCCallingComponent.call({ userID: this.invitee.userID, type: this.config.type })
      this.$store.commit('sendMessage', message)
    },
    // 群通话
    async groupCall () {
      const message = await wx.$TRTCCallingComponent.groupCall({
        groupID: this.groupID,
        userIDList: this.userIDList,
        type: this.config.type
      })
      this.$store.commit('sendMessage', message)
    },
    // 接受邀请
    async handleOnAccept () {
      // this.config.type = this.invitation.type
      this.callingFlag = true
      this.incomingCallFlag = false
      const message = await wx.$TRTCCallingComponent.accept()
      this.$store.commit('sendMessage', message)
    },
    // 拒绝邀请
    async handleOnReject () {
      const message = await wx.$TRTCCallingComponent.reject()
      this.$store.commit('sendMessage', message)
      console.warn('handleOnReject--->', message)
      this.incomingCallFlag = false
      this.$parent.showChatContainer()
      // this.$store.commit('setCalling', false)
      this.$store.commit('setCallData', { action: '', data: {} })
      this.onBack()
    },
    // 取消通话
    async handleOnCancel () {
      wx.$TRTCCallingComponent.hangup()
      // this.inviteCallFlag = false
      // this.$parent.showChatContainer()
      // this.$store.commit('setCalling', false)
      // this.$store.commit('setCallData', { action: '', data: {} })
      // this.onBack()
    },
    handleInvited () {
      console.warn('handleInvited---------->')
      const { sponsor, inviteData } = this.callData
      this.setCallingUserInfo()
      this.invitation = {
        inviter: sponsor,
        ...inviteData
      }
      this.incomingCallFlag = true
    },
    onBack () {
      if (!this.$store.getters.isCalling) {
        return
      }
      this.$store.commit('setCalling', false)
      if (this.currentPage.indexOf('?') === -1 && (this.currentPage.indexOf('index') > -1 || this.currentPage.indexOf('contact') > -1 || this.currentPage.indexOf('own') > -1)) {
        wx.switchTab({url: this.currentPage})
      } else {
        wx.navigateTo({url: this.currentPage})
      }
    }
  }
}
</script>

<style lang='stylus' scoped>
.calling-container {
  width 100vw;
	height 100vh;
	overflow hidden;
	background-image url('https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png');
	margin 0;
  display inline !important;
}
.calling-component {
  width 100%
  height 100%
  overflow hidden
  background-image url('https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png')
  margin 0
  z-index 99
}

.btn-operate {
  display: flex;
  justify-content: space-between;
  position: absolute;
  bottom: 5vh;
  width: 100%;
}

.call-operate {
	width: 15vw;
	height: 15vw;
	border-radius: 15vw;
	padding: 5px;
	margin: 0 15vw;
}

.tips {
	width: 100%;
	height: 40px;
	line-height: 40px;
	text-align: center;
	color: seashell;
}

.invite-call {
	background-image: url('https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png');
	position: absolute;
	top: 0;
	z-index: 100;
	width: 100vw;
	height: 100vh;
}

.invite-call > .btn-operate{
	display: flex;
	justify-content: center;
	position: absolute;
	bottom: 5vh;
	width: 100%;
}

.incoming-call {
  background-image: url('https://mc.qcloudimg.com/static/img/7da57e0050d308e2e1b1e31afbc42929/bg.png');
	position: absolute;
	top: 0;
	z-index: 200;
  width: 100vw;
  height: 100vh;
}

.incoming-call > image {
	width: 40vw;
	height: 40vw;
	display: block;
	margin: 20vw 30vw;
	margin-top: 40vw;
}

.invite-call > image {
	width: 40vw;
	height: 40vw;
	display: block;
	margin: 20vw 30vw;
	margin-top: 40vw;
}
</style>
