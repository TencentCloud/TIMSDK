<template>
  <div class="container">
    <div class="methods">
      <i-cell-group>
        <i-cell title="发起会话" is-link url="/pages/search/main?type=user"></i-cell>
        <i-cell title="加入群聊" is-link url="/pages/search/main?type=group"></i-cell>
        <i-cell title="新建群聊" is-link url="/pages/create/main"></i-cell>
        <i-cell title="我的黑名单" is-link url="/pages/blacklist/main"></i-cell>
        <i-cell title="我的群组" is-link url="/pages/groups/main"></i-cell>
      </i-cell-group>
    </div>
    <div class="friends">
      <van-index-bar :scroll-top="scrollTop" :index-list="indexList">
        <div v-for="item in groupedFriends" :key="item.key">
          <van-index-anchor :index="item.key" />
          <div class="friend-item" v-for="(friend, idx2) in item.friendList" :key="friend.userID" @click="toProfile(friend.userID)">
            <i-avatar i-class="avatar" :src="friend.profile.avatar" />
            <div class="username">{{friend.profile.nick || friend.userID}}</div>
          </div>
        </div>
      </van-index-bar>
    </div>
  </div>
</template>

<script>
import { pinyin } from '../../utils/index'

export default {
  data () {
    return {
      search: '',
      groupedFriends: [],
      indexList: [],
      addUserId: '',
      result: {},
      scrollTop: 0
    }
  },
  onPageScroll (event) {
    this.scrollTop = event.scrollTop
  },
  methods: {
    handleApply () {
      wx.$app
        .joinGroup({ groupID: this.result.groupID, type: this.result.type })
        .then(res => {
          if (res.data.status === 'JoinedSuccess') {
            this.$store.commit('showToast', {
              title: '加群成功'
            })
            this.search = ''
          } else {
            this.$store.commit('showToast', {
              title: '申请成功，等待群管理员确认'
            })
          }
          this.handleApplyModal()
        })
        .catch(() => {
          this.$store.commit('showToast', {
            title: '加群失败'
          })
        })
    },
    // 初始化朋友列表
    initFriendsList () {
      wx.$app.getFriendList({
        fromAccount: this.$store.state.user.userProfile.to
      }).then(res => {
        const tempMap = new Map()
        res.data.forEach(friend => tempMap.set(friend.userID, friend))
        const groupedFriends = this.groupingFriendList([...tempMap.values()])
        this.groupedFriends = groupedFriends
        this.indexList = groupedFriends.map(item => item.key)
      })
    },
    groupingFriendList (friends) {
      const tempMap = new Map()
      const result = []
      friends.forEach((friend) => {
        const name = friend.profile.nick || friend.userID
        const firstWord = pinyin(name)[0].toUpperCase()
        if (tempMap.has(firstWord)) {
          tempMap.get(firstWord).push(friend)
        } else {
          tempMap.set(firstWord, [friend])
        }
      })
      tempMap.forEach((friendList, key) => {
        result.push({ key, friendList })
      })
      return result.sort((a, b) => a.key > b.key ? 1 : -1)
    },
    toProfile (userID) {
      wx.navigateTo({ url: '../user-profile/main?userID=' + userID })
    }
  },
  mounted () {
    this.initFriendsList()
  }
}
</script>

<style lang='stylus'>
page
  height 100%
.container
  background $background
  width 100%
  height 100%
.input-wrapper
  width 100%
  display flex
  justify-content center
  padding 20px
  box-sizing border-box
.input
    color $regular
    text-align left
    height 32px
    background-color white
    font-size 16px
    line-height 32px
    width 75%
    border-radius 10px
.friends
  height 100vh
  background-color $white
  .van-index-anchor
    background-color #ededed
  .van-index-anchor--active
    color $primary
  .friend-item
    display flex
    padding 12px 0 12px 12px
  .avatar
    width 40px
    height 40px
    margin-right 12px
  .username
    width 100%
    height 50px
    line-height 40px
    font-size 18px
    border-bottom 1px solid $background
</style>
