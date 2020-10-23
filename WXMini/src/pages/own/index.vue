<template>
  <div class="container">
    <div class="info-card">
      <image class="avatar" :src="myInfo.avatar || '/static/images/avatar.png'" />
      <div class="basic">
        <div class="username">{{myInfo.nick || '未设置'}}</div>
        <div class="user-id">用户ID：{{myInfo.userID}}</div>
      </div>
    </div>
    <i-cell-group i-class="cell-group">
      <i-cell title="个性签名">
        <div slot="footer" class="signature">
          {{myInfo.selfSignature || '暂无'}}
        </div>
      </i-cell>
    </i-cell-group>
    <i-cell-group i-class="cell-group">
      <i-cell title="修改资料" is-link url="../profile/main"></i-cell>
      <i-cell title="退出登录" i-class="logout" @click="logout"></i-cell>
    </i-cell-group>
  </div>
</template>

<script>
import { mapState } from 'vuex'

export default {
  data () {
    return {
      search: ''
    }
  },
  computed: {
    ...mapState({
      myInfo: state => state.user.myInfo
    })
  },
  methods: {
    logout () {
      this.$store.dispatch('resetStore')
      wx.$app.logout()
      wx.hideLoading()
      wx.reLaunch({
        url: '../login/main'
      })
    }
  }
}
</script>

<style lang='stylus'>
.cell-group
  margin-top 10px
.logout
  color $danger
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
</style>
