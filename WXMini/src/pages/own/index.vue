<template>
  <div class="container">
    <div class="card">
      <div class="item">
        <i-row>
          <i-col span="8">
            <div class="avatar">
              <image style="width: 80px; height: 80px; border-radius: 8px" :src="myInfo.avatar || '/static/images/header.png'" />
            </div>
          </i-col>
          <i-col span="16">
            <div class="right">
              <div class="username">{{myInfo.nick}}</div>
              <div class="account">帐号：{{myInfo.userID}}</div>
            </div>
          </i-col>
        </i-row>
      </div>
  </div>
  <div class="revise">
    <i-button @click="reviseInfo" type="primary" long="true" shape="circle">修改资料</i-button>
  </div>
  <div class="revise">
    <i-button @click="logout" type="error" long="true" shape="circle">退出登录</i-button>
  </div>
</div>
</template>

<script>
export default {
  data () {
    return {
      search: '',
      myInfo: {}
    }
  },
  methods: {
    reviseInfo () {
      let url = '../profile/main'
      wx.navigateTo({ url: url })
    },
    logout () {
      this.$store.commit('resetGroup')
      this.$store.commit('resetUser')
      this.$store.commit('resetCurrentConversation')
      this.$store.commit('resetAllConversation')
      wx.$app.logout()
      wx.reLaunch({
        url: '../login/main'
      })
    }
  },
  // 更新自己的个人信息
  onShow () {
    this.myInfo = this.$store.state.user.myInfo
  }
}
</script>

<style lang='stylus' scoped>
.card
  border-bottom 1px solid $border-light
.avatar
  padding 10px
.right
  box-sizing border-box
  height 100px
  padding 10px
  display flex
  flex-direction column
  justify-content space-around
.username
  font-weight 600
  font-size 18px
  color $base
.account
  font-size 14px
  color $secondary
.start
  color white
  background-color $primary
  border-radius 8px
  height 50px
  width 200px
  line-height 50px
  font-size 16px
.revise
  padding 20px 40px 0 40px
</style>
