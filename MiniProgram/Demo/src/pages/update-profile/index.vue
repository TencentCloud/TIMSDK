<template>
  <div class="update-profile-wrapper">
    <input 
      class="input"
      :class="focus ? 'input-focus' : ''"
      type="text" 
      v-model="value"
      :placeholder="placeholder" 
      :focus="focus"
      @blur="focus = false"
      @focus="focus = true"
      >
    <button :class="{'button-disabled' : disabled}" :disabled="disabled" @click="handleClick">确认修改</button>
  </div>
</template>

<script>
import { mapState } from 'vuex'

// 修改资料页，支持修改个人资料和群组相关资料
export default {
  data () {
    return {
      type: 'user', // user / group
      key: '',
      groupID: '',
      value: '',
      focus: true
    }
  },
  computed: {
    ...mapState({
      myInfo: state => state.user.myInfo,
      groupProfile: state => state.conversation.currentConversation.groupProfile
    }),
    disabled () {
      switch (this.key) {
        case 'nick':
          if (this.value !== this.myInfo.nick) {
            return false
          }
          break
        case 'signature':
          if (this.value !== this.myInfo.selfSignature) {
            return false
          }
          break
        case 'nameCard':
          if (this.groupProfile && this.groupProfile.selfInfo && this.value !== this.groupProfile.selfInfo.nameCard) {
            return false
          }
          break
        case 'name':
          if (this.groupProfile && this.value !== this.groupProfile.name) {
            return false
          }
          break
        case 'notification':
          if (this.groupProfile && this.value !== this.groupProfile.notification) {
            return false
          }
          break
      }
      return true
    },
    placeholder () {
      switch (this.key) {
        case 'nick':
          return '请输入昵称'
        case 'signature':
          return '请输入个性签名'
        case 'nameCard':
          return '请输入群名片'
      }
    }
  },
  onLoad ({ type, key, groupID }) {
    this.type = type
    this.key = key
    if (groupID) {
      this.groupID = groupID
    }
    let title = ''
    switch (key) {
      case 'nick':
        title = '修改昵称'
        this.value = this.myInfo.nick
        break
      case 'signature':
        title = '修改个性签名'
        this.value = this.myInfo.selfSignature
        break
      case 'nameCard':
        title = '修改群名片'
        this.value = this.groupProfile.selfInfo.nameCard
        break
      case 'name':
        title = '修改群名称'
        this.value = this.groupProfile.name
        break
      case 'notification':
        title = '修改群公告'
        this.value = this.groupProfile.notification
        break
    }
    wx.setNavigationBarTitle({ title })
  },
  methods: {
    handleClick () {
      if (this.type === 'user') {
        this.updateMyProfile()
      } else if (this.type === 'group') {
        this.updateGroupProfile()
      }
    },
    updateMyProfile () {
      switch (this.key) {
        case 'nick':
          wx.$app.updateMyProfile({ nick: this.value })
            .then(this.handleResolve)
            .catch(this.handleReject)
          break
        case 'signature':
          wx.$app.updateMyProfile({ selfSignature: this.value })
            .then(this.handleResolve)
            .catch(this.handleReject)
          break
      }
    },
    updateGroupProfile () {
      switch (this.key) {
        case 'nameCard':
          wx.$app.setGroupMemberNameCard({
            groupID: this.groupID,
            nameCard: this.value
          }).then(this.handleResolve)
            .catch(this.handleReject)
          break
        case 'name':
          wx.$app.updateGroupProfile({
            groupID: this.groupID,
            name: this.value
          }).then(this.handleResolve)
            .catch(this.handleReject)
          break
        case 'notification':
          wx.$app.updateGroupProfile({
            groupID: this.groupID,
            notification: this.value
          }).then(this.handleResolve)
            .catch(this.handleReject)
          break
        default:
          break
      }
    },
    handleResolve () {
      wx.showToast({
        title: '修改成功',
        duration: 600
      })
      setTimeout(() => {
        wx.navigateBack()
      }, 600)
    },
    handleReject (error) {
      wx.showToast({ title: error.message, icon: 'none' })
    }
  }
}
</script>

<style lang="stylus" scoped>
.update-profile-wrapper
  height 100vh
  padding 12px
  .input
    padding 12px
    border-bottom 1px solid $dark-background
  button 
    margin-top 24px
    color $white
    background-color $primary
</style>