<template>
  <div class="chatting">
    <i-checkbox-group :current="selectedList"  @change="handleCheckedMembersChange">
      <i-checkbox v-if="showAllItem"   value="__kImSDK_MesssageAtALL__" key="" >
        <div style="display: flex">
          <i-avatar class="avatar" :src="''" />
          <div class="username text-ellipsis">所有人</div>
        </div>
      </i-checkbox>
    <i-checkbox v-for="member in currentGroupMemberList" :disabled="member.userID===myInfo.userID" :value="member.userID" :key="member.userID" style="display: block">
      <div style="display: flex">
        <div class="avatar">
          <i-avatar :src="member.avatar || '/static/images/avatar.png'"/>
        </div>
        <div class="information text-ellipsis">
          <div class="username">{{member.nameCard || member.nick || member.userID}}</div>
        </div>
      </div>
    </i-checkbox>
    </i-checkbox-group>
    <div class="list-btn">
      <p class="btn-box" @click="selectedCancel">取消</p>
      <p class="btn-box" @click="selectedConfirm">确定</p>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
      muteModal: false,
      member: {},
      muteTime: undefined,
      current: Date.now(),
      intervalID: '',
      selectedList: [],
      showAllItem: false
    }
  },
  onLoad (options) {
    this.showAllItem = !(options.fr && options.fr === 'calling')
    wx.$app.getGroupMemberList({ groupID: this.groupProfile.groupID })
      .then(({data: { memberList }}) => {
        this.$store.commit('updateCurrentGroupMemberList', memberList)
      })
  },
  onUnload () {
    this.$store.commit('resetCurrentMemberList')
  },
  computed: {
    ...mapState({
      currentGroupProfile: state => {
        return state.conversation.currentConversation.groupProfile
      },
      currentGroupMemberList: state => {
        return state.group.currentGroupMemberList
      },
      groupProfile: state => state.conversation.currentConversation.groupProfile,
      myInfo: state => state.user.myInfo
    }),
    isMyRoleOwner () {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_OWNER
    },
    isMyRoleAdmin () {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_ADMIN
    }
  },
  onReachBottom () {
    // 若群成员列表未拉完，则触底时拉下一页
    if (this.currentGroupMemberList.length !== this.currentGroupProfile.memberCount) {
      this.getGroupMemberList()
    }
  },
  onunload () {
    this.$store.commit('resetCurrentMemberList')
  },
  methods: {
    getGroupMemberList () {
      this.$store.dispatch('getGroupMemberList')
    },
    cancelMuteModal () {
      this.muteModal = false
    },
    handleCheckedMembersChange (data) {
      const index = this.selectedList.indexOf(data.mp.detail.value)
      index === -1 ? this.selectedList.push(data.mp.detail.value) : this.selectedList.splice(index, 1)
    },
    selectedCancel () {
      this.showAllItem = false
      this.selectedList.length = 0
      wx.navigateBack({ delta: 1 })
    },
    selectedConfirm () {
      if (this.selectedList.length === 0) {
        this.$store.commit('showMessage', {
          type: 'warning',
          message: '请选择成员'
        })
        return
      }
      this.showAllItem = false
      this.$store.commit('updateSelectedMember', this.selectedList)
      this.selectedList = []
      // let url = '../chat/main'
      // wx.navigateTo({url})
      wx.navigateBack({ delta: 1 })
    }
  },
  mounted () {
    this.intervalID = setInterval(() => {
      this.current = Date.now()
    }, 1000)
  },
  destory () {
    this.intervalID = ''
  }
}
</script>

<style lang='stylus' scoped>
.search
  background-color $background
  padding 8px 8px 8px 8px
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  font-size 16px
  border 1px solid $border-base
.avatar
  display inline
  padding-right 10px
.information
  display inline
  width 100%
.chat
  line-height 32px
  padding 10px
  background-color $background
  margin-bottom -1px
  border-top 1px solid $border-base
  border-bottom 1px solid $border-base
.right
  padding 0 18px 0 8px
.set
  color #4082a2
  font-size 14px
.delete
  color #c86957
  font-size 14px
.username
  line-height 30px
  font-size 14px
  color $base
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
.last
  color $regular
  font-size 12px
.content
  color $regular
  font-size 12px
  width 80%
.remain
  color white
  font-size 12px
  background-color $danger
  border-radius 8px
  padding 2px 8px

.checkbox-member
  width 20px
  height 20px
  border-radius 50%
.list-btn
  width 100%
  display flex
  height 40px
  position fixed
  bottom 0
  z-index 1000
  background-color #ffffff
  justify-content space-around
.btn-box
  padding 5px 16px
  background-color #006fff
  border-radius 20px
  color #ffffff
  height 20px
  line-height 20px
  font-size 14px
  margin-top 5px
.chatting {
  padding-bottom 50px
}
</style>
