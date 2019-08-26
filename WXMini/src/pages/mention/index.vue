<template>
  <div class="chatting">
    <div class="title">点击进行选择</div>
    <div class="chat" v-for="item in currentGroupProfile.memberList" :key="item.userID" @click="chooseUser(item)">
      <i-row>
        <i-col span="6">
          <div class="avatar">
            <i-avatar :src="item.avatar || '/static/images/header.png'"/>
          </div>
        </i-col>
        <i-col span="18">
          <div class="information">
            <div class="username">{{item.nick || item.userID}}</div>
          </div>
        </i-col>
      </i-row>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  computed: {
    ...mapState({
      currentGroupProfile: state => {
        return state.group.currentGroupProfile
      }
    })
  },
  methods: {
    chooseUser (item) {
      this.$bus.$emit('atUser', item)
      wx.navigateBack({
        delta: 1
      })
    }
  }
}
</script>

<style lang='stylus' scoped>
.chatting
  background-color $background
  .title
    color $regular
    font-size 12px
    padding 4px 10px
  .chat
    background-color white
    border 1px solid $border-light
    margin-bottom -1px
    padding 10px 20px
.username
  color $base
  line-height 32px
</style>
