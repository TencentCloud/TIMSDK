<template>
  <div class="container">
    <div class="info-card">
      <i-avatar i-class="avatar" :src="userProfile.avatar" />
      <div class="basic">
        <div class="username">{{userProfile.nick || '未设置'}}</div>
        <div class="user-id">用户ID：{{userProfile.userID}}</div>
      </div>
    </div>
    <i-cell-group i-class="cell-group">
      <i-cell title="个性签名">
        <div slot="footer" class="signature">
          {{userProfile.selfSignature || '暂无'}}
        </div>
      </i-cell>
    </i-cell-group>
    <i-cell-group i-class="cell-group">
      <i-cell title="加入黑名单">
        <switch slot="footer" color="#006fff" :checked="isInBlacklist" @change="handleSwitch"/>
      </i-cell>
    </i-cell-group>
    <div class="action-list"  :style="{'margin-bottom': isIphoneX ? '34px' : 0}">
      <button class="video-call" @click="videoCall">
        音视频通话
        <div class="new-badge">NEW</div>
      </button>
      <button class="send-messsage" @click="sendMessage">发送消息</button>
    </div>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex'
export default {
  data () {
    return {
      userProfile: {},
      isInBlacklist: false
    }
  },
  computed: {
    ...mapState({
      blacklist: state => state.user.blacklist
    }),
    ...mapGetters(['isIphoneX'])
  },
  onLoad ({ userID, groupID }) {
    if (userID) {
      if (this.blacklist.indexOf(userID) > -1) {
        this.isInBlacklist = true
      }
      wx.$app.getUserProfile({ userIDList: [userID] })
        .then((res) => {
          this.userProfile = res.data[0]
        })
    }
  },
  onUnload () {
    this.userProfile = {}
    this.isInBlacklist = false
  },
  methods: {
    getRandomInt (min, max) {
      min = Math.ceil(min)
      max = Math.floor(max)
      return Math.floor(Math.random() * (max - min)) + min
    },
    videoCall () {
      const options = {
        call_id: '',
        version: 3,
        room_id: this.getRandomInt(0, 42949),
        action: 0,
        duration: 0,
        invited_list: []
      }
      let args = JSON.stringify(options)
      const message = wx.$app.createCustomMessage({
        to: this.userProfile.userID,
        conversationType: 'C2C',
        payload: {
          data: args,
          description: '',
          extension: ''
        }
      })
      this.$store.commit('sendMessage', message)
      wx.$app.sendMessage(message)
      let url = `../call/main?args=${args}&&from=${message.from}&&to=${message.to}`
      wx.navigateTo({url})
    },
    sendMessage () {
      this.$store.dispatch('checkoutConversation', `C2C${this.userProfile.userID}`)
    },
    handleSwitch (event) {
      if (event.mp.detail.value) {
        this.addBlackList()
      } else {
        this.deleteBlackList()
      }
    },
    // 拉黑好友
    addBlackList () {
      wx.$app.addToBlacklist({ userIDList: [this.userProfile.userID] }).then((res) => {
        this.$store.commit('showToast', {
          title: '拉黑成功',
          icon: 'none',
          duration: 1500
        })
        this.isInBlacklist = true
        this.$store.commit('setBlacklist', res.data)
      }).catch(() => {
        this.$store.commit('showToast', {
          title: '拉黑失败',
          icon: 'none',
          duration: 1500
        })
      })
    },
    // 取消拉黑
    deleteBlackList () {
      wx.$app.removeFromBlacklist({ userIDList: [this.userProfile.userID] }).then((res) => {
        this.$store.commit('showToast', {
          title: '取消拉黑成功',
          icon: 'none',
          duration: 1500
        })
        this.$store.commit('setBlacklist', res.data)
        this.isInBlacklist = false
      }).catch(() => {
        this.$store.commit('showToast', {
          title: '取消拉黑失败',
          icon: 'none',
          duration: 1500
        })
      })
    }
  }
}
</script>

<style lang="stylus">
.cell-group
  margin-top 10px
.signature
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  max-width 50vw
  color $secondary
.container
  height 100vh
  background-color $background
  .info-card
    display flex
    padding 16px
    background-color $white
    .avatar
      width 80px
      height 80px
      border-radius 8px
      margin-right 14px
    .basic
      .username
        font-size 24px
        line-height 36px
        font-weight 600
      .user-id
        font-size 12px
        color $secondary
  .action-list
    position fixed
    bottom 0
    left 0
    display flex
    width 100%
    padding 12px
    justify-content space-between
    box-sizing border-box
    button
      flex-basis 40%
      flex-grow 1
      height 40px
      line-height 40px
      font-size 18px
      margin 0
      &:after
        border none
    .send-messsage
      background-color $primary
      color $white
    .video-call
      margin-right 8px
      background-color $light-button
      overflow visible
      .new-badge
        position absolute
        right -5px
        top -5px
        width 34px
        height 16px
        line-height 16px
        border-radius 8px
        font-size 10px
        color $white
        background-color $danger

</style>
