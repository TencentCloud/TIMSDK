<template>
  <div class="counter-warp">
    <div class="header">
      <div class="header-content">
        <img src="../../../static/images/im.png" class="icon">
        <div class="text">
          <div class="text-header">登录 · 即时通信</div>
          <div class="text-content">体验群组聊天，视频对话等IM功能</div>
        </div>
      </div>
    </div>
    <picker class="picker" :range="userIDList" :value="selectedIndex" @change="choose">
      <div class="cell">
        <div class="choose">用户</div>
        <div>
          {{userIDList[selectedIndex]}}
          <i-icon type="enter" />
        </div>
      </div>
    </picker>
    <button hover-class="clicked" :loading="loading" class="login-button" @click="handleLogin">登录</button>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { genTestUserSig } from '../../../static/utils/GenerateTestUserSig'
export default {
  data () {
    return {
      password: '',
      userIDList: new Array(30).fill().map((item, idx) => ('user' + idx)),
      selectedIndex: 1,
      loading: false
    }
  },
  computed: {
    ...mapState({
      myInfo: state => state.user.myInfo
    })
  },
  onUnload () {
    this.loading = false
  },
  methods: {
    // 点击登录进行初始化
    handleLogin () {
      const userID = this.userIDList[this.selectedIndex]
      // case1: 要登录的用户是当前已登录的用户，则直接跳转即可
      if (this.myInfo.userID && userID === this.myInfo.userID) {
        wx.switchTab({ url: '../index/main' })
        return
      }

      this.loading = true
      // case2: 当前已经登录了用户，但是和即将登录的用户不一致，则先登出当前登录的用户，再登录
      if (this.myInfo.userID) {
        this.$store.dispatch('resetStore')
        wx.$app.logout()
          .then(() => {
            this.login(userID)
          })
        return
      }
      // case3: 正常登录流程
      this.login(userID)
    },
    login (userID) {
      wx.$app.login({
        userID,
        userSig: genTestUserSig(this.userIDList[this.selectedIndex]).userSig
      }).then(() => {
        wx.switchTab({ url: '../index/main' })
      }).catch(() => {
        this.loading = false
      })
    },
    choose (event) {
      this.selectedIndex = Number(event.mp.detail.value)
    }
  }
}
</script>

<style lang="stylus" scoped>
.counter-warp
  height 100%
  background $white
  text-align center
  .header
    padding 30px 40px
    background-color $primary
    color white
    .header-content
      display flex
      align-items center
      .icon
        width 76px
        height 50px
      .text
        text-align left
        padding-left 8px
        .text-header
          font-size 28px
        .text-content
          font-size 12px
  .picker
    width 80vw
    margin 80px auto 60px
    .cell
      display flex
      justify-content  space-between
      align-items center
      border-bottom  1px solid $border-base
      padding-bottom 12px
      .choose
        font-weight 600
        font-size 16px

.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  font-size 16px
  border 1px solid $border-base
  margin-bottom 8px
.login-button
  width 80vw
  background-color $primary
  color white
  font-size 16px
  &::before
    width 20px
    height 20px
    margin 0 6px 2px 0
.clicked
  background-color $dark-primary
</style>
