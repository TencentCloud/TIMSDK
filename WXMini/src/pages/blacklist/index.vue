<template>
  <div class="blacklist">
    <div v-if="blacklist.length === 0" class="wrapper">
      <div class="none">
        你还没有拉黑任何人哦
      </div>
    </div>
    <div class="list" @click="toDetail(item.userID)" v-for="item in userList" :key="item.userID">
      <div class="avatar">
        <img :src="item.avatar || '/static/images/avatar.png'" style="width: 100%;height: 100%">
      </div>
      <div class="name">
        {{item.nick || item.userID}}
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
      userList: []
    }
  },
  computed: {
    ...mapState({
      blacklist: state => state.user.blacklist
    })
  },
  onShow () {
    if (this.blacklist.length > 0) {
      let option = {
        userIDList: this.blacklist
      }
      wx.$app.getUserProfile(option).then(res => {
        this.userList = res.data
      })
    }
  },
  methods: {
    // 去用户详情
    toDetail (id) {
      wx.navigateTo({ url: '../user-profile/main?userID=' + id })
    }
  }
}
</script>

<style lang='stylus' scoped>
.blacklist
  padding 10px 0 4px 0
  background-color $background
  height 100vh
.slot
  padding 0 0 4px 10px
  font-size 12px
  color $secondary
.none
  padding 10px
  display flex
  justify-content center
  color $regular
.wrapper
  display flex
  flex-wrap wrap
  padding 4px 6px
  background-color white
  box-sizing border-box
  border-top 1px solid $border-base
  border-bottom 1px solid $border-base
.list
  display flex
  padding 10px 10px
  background-color white
  box-sizing border-box
  margin-bottom -1px
  border-top 1px solid $border-base
  border-bottom 1px solid $border-base
  .avatar
    height 40px
    width 40px
  .name
    padding-left 25px
    line-height 40px
    font-size 16px
</style>
