<template>
  <div class="bg">
    <div class="card">
      <i-row>
        <i-col span="8">
          <div class="avatar">
            <image style="width: 80px; height: 80px; border-radius: 8px" src="/static/images/header.png" />
          </div>
        </i-col>
        <i-col span="16">
          <div class="right">
            <div class="username">{{userProfile.nick || '未设置'}}</div>
            <div class="account">帐号：{{userProfile.userID}}</div>
          </div>
        </i-col>
      </i-row>
    </div>
    <div class="card" style="margin-top:20px">
      <div class="item">
        <div class="key">性别</div>
        <div clasa="value">{{userProfile.gender || '未设置'}}</div>
      </div>
      <div class="item">
        <div class="key">生日</div>
        <div class="value">{{userProfile.birthday || '未设置'}}</div>
      </div>
      <div class="item">
        <div class="key">地址</div>
        <div class="value">{{userProfile.location || '未设置'}}</div>
      </div>
      <div class="item">
        <div class="key">签名</div>
        <div class="value">{{userProfile.selfSignature || '未设置'}}</div>
      </div>
    </div>
    <div class="revise">
<!--      <button @click="deleteFriend" class="btn delete">删除好友</button>-->
      <button @click="addBlackList" class="btn delete" v-if="!isInBlacklist">拉黑</button>
      <button @click="deleteBlackList" class="btn" v-if="isInBlacklist">取消拉黑</button>
    </div>
  </div>
</template>

<script>
export default {
  data () {
    return {
      userProfile: {},
      isInBlacklist: false
    }
  },
  // 退出聊天页面的时候所有状态清空
  onUnload () {
    this.userProfile = {}
  },
  onShow () {
    this.getBlacklist()
    this.userProfile = this.$store.state.user.userProfile
    let blacklist = this.$store.state.user.blacklist
    if (blacklist.indexOf(this.userProfile.userID) > -1) {
      this.isInBlacklist = true
    }
  },
  methods: {
    // 获取黑名单
    getBlacklist () {
      wx.$app.getBlacklist().then(res => {
        this.$store.commit('setBlacklist', res.data)
      })
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
      this.userProfile = this.$store.state.user.userProfile
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
      this.userProfile = this.$store.state.user.userProfile
    }
  }
}
</script>

<style lang="stylus" scoped>
.bg
  background-color $background
  height 100vh
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
.btn
  color white
  background-color $primary
  border-radius 20px
  height 40px
  width 150px
  line-height 40px
  font-size 16px
.delete
  background-color $danger
.container
  background-color $background
  height 100vh
  overflow scroll
.card
  border-top 1px solid $border-light
  border-bottom 1px solid $border-light
  background-color white
  margin-bottom -1px
  .item
    display flex
    width 100vw
    padding 10px 20px
    border-bottom 1px solid $border-base
    font-size 16px
    .key
      width 60vw
      font-weight 500
      color $base
      box-sizing border-box
    .value
      width 40vw
      font-weight 400
      color $regular
      box-sizing border-box
.avatar
  padding 10px
.revise
  padding-top 20px
  display flex
  flex-direction column
  justify-content space-around
  height 100px
</style>
