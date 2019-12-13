<template>
  <div class="counter-warp">
    <div style="margin-bottom: 20px">
      <i-avatar src="../../../static/images/launch.png" size="large" shape="square" />
    </div>
    <div class="login">
      <div class="select-wrapper" @click="choose">
        <div class="show">{{userID}}</div>
        <div class="down">
          <div class="inside"></div>
        </div>
      </div>
      <div class="select-list" v-if="selected" @click="select">
        <div class="select" id="user0">user0</div>
        <div class="select" id="user1">user1</div>
        <div class="select" id="user2">user2</div>
        <div class="select" id="user3">user3</div>
        <div class="select" id="user4">user4</div>
        <div class="select" id="user5">user5</div>
        <div class="select" id="user6">user6</div>
        <div class="select" id="user7">user7</div>
        <div class="select" id="user8">user8</div>
        <div class="select" id="user9">user9</div>
        <div class="select" id="user10">user10</div>
        <div class="select" id="user11">user11</div>
        <div class="select" id="user12">user12</div>
        <div class="select" id="user13">user13</div>
        <div class="select" id="user14">user14</div>
        <div class="select" id="user15">user15</div>
        <div class="select" id="user16">user16</div>
        <div class="select" id="user17">user17</div>
        <div class="select" id="user18">user18</div>
        <div class="select" id="user19">user19</div>
        <div class="select" id="user20">user20</div>
      </div>
<!--      <input type="text" class="input" placeholder="用户名" v-model="userID"/>-->
    </div>
    <div class="login-button">
      <i-button @click="handleLogin" type="primary" shape="circle">登录</i-button>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { genTestUserSig } from '../../../static/utils/GenerateTestUserSig'
export default {
  data () {
    return {
      userID: 'user0',
      password: '',
      selected: false
    }
  },
  computed: {
    ...mapState({
      isSdkReady: state => {
        return state.global.isSdkReady
      }
    })
  },
  methods: {
    // 点击登录进行初始化
    handleLogin () {
      let options = genTestUserSig(this.userID)
      options.runLoopNetType = 0
      if (options) {
        wx.$app.login({
          userID: this.userID,
          userSig: options.userSig
        }).then(() => {
          wx.showLoading({
            title: '登录成功'
          })
          wx.switchTab({
            url: '../index/main'
          })
        })
      }
    },
    choose () {
      this.selected = !this.selected
    },
    select (e) {
      this.userID = e.target.id
      this.choose()
    }
  }
}
</script>

<style lang="stylus" scoped>
.select-wrapper
  display flex
  justify-content space-between
  border 1px solid $border-light
  height 30px
  .show
    text-align center
    color $secondary
    padding-left 10px
    font-size 14px
    line-height 30px
  .down
    color white
    background-color $primary
    height 100%
    padding 10px 8px
    box-sizing border-box
    .inside
      width 0
      height 0
      border-left 8px solid transparent
      border-right 8px solid transparent
      border-top 10px solid white
.select-list
  position absolute
  z-index 9999
  background-color white
  width 200px
  height 200px
  overflow-y scroll
  border-left 1px solid $border-base
  border-right 1px solid $border-base
  box-sizing border-box
  .select
    border-bottom 1px solid $border-base
    font-size 14px
    text-align left
    padding 6px 8px
.counter-warp
  text-align center
  margin-top 100px
.login
  display inline-block
  padding 10px 0
  border-radius 8px
  width 200px
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  font-size 16px
  border 1px solid $border-base
  margin-bottom 8px
.login-button
  width 220px
  padding 20px 0
  display inline-block
</style>
