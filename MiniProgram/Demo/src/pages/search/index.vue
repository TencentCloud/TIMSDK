<template>
  <div class="container">
    <div class="search-bar">
      <img src="/static/images/search.png"/>
      <input v-model="ID" :focus="true" confirm-type="search" :placeholder="placeholder" @confirm="search" @input="handleInput"/>
    </div>
    <button @click="handleClick" :loading="loading" v-show="searched" hover-class="clicked">{{buttonText}}</button>
  </div>
</template>

<script>
import { mapState } from 'vuex'
// 该页面用于：
// 1. 搜索用户>发起会话
// 2. 搜索群组>申请加群
export default {
  data () {
    return {
      type: '', // user / group
      ID: '',
      searchedID: '',
      searched: false,
      loading: false,
      buttonText: ''
    }
  },
  onLoad ({ type }) {
    this.type = type
    if (type === 'user') {
      this.buttonText = '发起会话'
      wx.setNavigationBarTitle({ title: '发起会话' })
    } else {
      this.buttonText = '申请加群'
      wx.setNavigationBarTitle({ title: '加入群聊' })
    }
  },
  onUnload () {
    this.ID = ''
    this.searched = false
    this.loading = false
    this.type = ''
  },
  computed: {
    ...mapState({
      groupList: state => state.group.groupList
    }),
    placeholder () {
      if (this.type === 'user') {
        return '请输入userID'
      } else {
        return '请输入groupID'
      }
    }
  },
  methods: {
    handleInput () {
      if (this.searchedID === '' || this.ID !== this.searchedID) {
        this.searched = false
      }
    },
    search () {
      if (this.ID === '') {
        return
      }
      wx.showLoading({ title: '正在搜索' })
      if (this.type === 'user') {
        this.searchUser()
      } else {
        this.searchGroup()
      }
    },
    searchUser () {
      wx.$app.getUserProfile({ userIDList: [this.ID] })
        .then(({ data }) => {
          wx.hideLoading()
          if (data.length === 0) {
            wx.showToast({ title: '未找到该用户', duration: 1000, icon: 'none' })
            return
          }
          this.searched = true
          this.searchedID = this.ID
        }).catch((error) => {
          wx.hideLoading()
          wx.showToast({ title: error.message, duration: 1000, icon: 'none' })
        })
    },
    searchGroup () {
      wx.$app.searchGroupByID(this.ID)
        .then(({ data }) => {
          wx.hideLoading()
          const isJoined = this.groupList.findIndex((group) => group.groupID === this.ID) >= 0
          if (isJoined || data.group.type === wx.TIM.TYPES.GRP_AVCHATROOM) {
            this.buttonText = '进入群聊'
          } else {
            this.buttonText = '申请加群'
          }
          this.searched = true
          this.searchedID = this.ID
        }).catch((error) => {
          wx.hideLoading()
          if (error.code === 10007) {
            wx.showToast({ title: '讨论组类型群组不允许申请加群', duration: 1000, icon: 'none' })
          } else {
            wx.showToast({ title: '未找到该群组', duration: 1000, icon: 'none' })
          }
        })
    },
    handleClick () {
      if (this.type === 'user') {
        this.createConversation()
      } else {
        this.joinGroup()
      }
    },
    // 发起会话
    createConversation () {
      this.loading = true
      this.$store.dispatch('checkoutConversation', `C2C${this.ID}`)
        .then(() => {
          this.loading = false
        })
        .catch(() => {
          this.loading = false
        })
    },
    // 申请加群
    joinGroup () {
      this.loading = true
      wx.$app.joinGroup({ groupID: this.ID, applyMessage: '我想申请加入贵群，望批准！' })
        .then(() => {
          this.loading = false
          this.$store.dispatch('checkoutConversation', `GROUP${this.ID}`)
        })
        .catch(() => {
          this.loading = false
        })
    }
  }
}
</script>

<style lang='stylus' scoped>
.container
  height 100vh
  padding 16px
  background-color $background
  .search-bar
    display flex
    align-items center
    background-color $white
    border-radius 16px
    padding 5px 16px
    font-size 14px
    input
      width 100%
    img
      width 14px
      height 14px
      margin-right 10px
  button
    background-color $primary
    color $white
    width 80vw
    position absolute
    left 50%
    bottom 24px
    margin-left -40vw
  .clicked
    background-color $dark-primary
</style>
