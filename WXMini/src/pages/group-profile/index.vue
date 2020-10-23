<template>
  <div class="group-detail-wrapper" v-if="groupProfile">
    <div class="header">
      <template v-for="member in memberList">
        <div class="member" :key="member.userID" @click="toUserProfile(member)">
          <i-avatar
            i-class="avatar"
            :src="member.avatar || '/static/images/avatar.png'"
            defaultAvatar="'/static/images/avatar.png'"
            shape="square" />
          <div class="name">
            {{member.nameCard || member.nick || member.userID}}
          </div>
        </div>
      </template>
      <div class="show-more-btn" @click="toAllMemberList">
        <icon :size="40" src="/static/images/show-more.png"/>
        <div class="name">
          查看全部
        </div>
      </div>
      <div class="add-member-btn" v-if="addMemberButtonVisible" @click="addMemberModalVisible = true">
        <icon :size="40" src="/static/images/add-group-member.png"/>
        <div class="name">
          添加
        </div>
      </div>
    </div>
    <!-- 群组相关资料 -->
    <i-cell-group>
      <i-cell title="群ID" value-class="cell-value" :value="groupProfile.groupID"/>
      <i-cell title="群名称" value-class="cell-value" :is-link="canIEditGroupProfile" :value="groupProfile.name"
        :url="'../update-profile/main?type=group&key=name&groupID=' + groupProfile.groupID"/>
      <i-cell title="群公告" value-class="cell-value" :is-link="canIEditGroupProfile" :value="groupProfile.notification"
        :url="'../update-profile/main?type=group&key=notification&groupID=' + groupProfile.groupID"/>
      <i-cell title="我在本群的昵称" value-class="cell-value" is-link :value="groupProfile.selfInfo.nameCard"
        :url="'../update-profile/main?type=group&key=nameCard&groupID=' + groupProfile.groupID"/>
    </i-cell-group>
    <!-- 群组相关操作 -->
    <i-cell-group i-class="group-action">
      <i-cell title="全体禁言">
        <switch slot="footer" color="#006fff" :disabled="!isAdminOrOwner" @change="handleMuteSwitch"  @click ="handleClick"/>
      </i-cell>
    </i-cell-group>
    <i-cell-group i-class="group-action">
      <i-cell i-class="quit" :title="quitText" is-link @click="handleQuit" />
    </i-cell-group>

    <!-- 添加群成员 Modal 窗 -->
    <i-modal :i-class="inputFocus ? 'add-member-modal-on-focus add-member-modal' : 'add-member-modal'" title="添加群成员" :visible="addMemberModalVisible" @ok="handleOk" @cancel="addMemberModalVisible = false">
      <input v-show="addMemberModalVisible" class="user-id-input" :focus="addMemberModalVisible" v-model="userID" placeholder="请输入 userID" @focus="inputFocus = true" @blur="inputFocus = false"/>
    </i-modal>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
      addMemberModalVisible: false,
      inputFocus: false,
      userID: ''
    }
  },
  onLoad () {
    wx.$app.getGroupMemberList({ groupID: this.groupProfile.groupID })
      .then(({data: { memberList }}) => {
        this.$store.commit('updateCurrentGroupMemberList', memberList)
      })
  },
  onUnload () {
    this.userID = ''
    this.addMemberModalVisible = false
    this.$store.commit('resetCurrentMemberList')
  },
  computed: {
    ...mapState({
      groupProfile: state => state.conversation.currentConversation.groupProfile,
      memberList: state => state.group.currentGroupMemberList.slice(0, 12)
    }),
    // 好友工作群才能添加群成员
    addMemberButtonVisible () {
      if (this.groupProfile) {
        return this.groupProfile.type === wx.TIM.TYPES.GRP_WORK
      }
      return false
    },
    quitText () {
      if (this.groupProfile &&
        this.groupProfile.type !== wx.TIM.TYPES.GRP_WORK &&
        this.groupProfile.selfInfo &&
        this.groupProfile.selfInfo.role === wx.TIM.TYPES.GRP_MBR_ROLE_OWNER
      ) {
        return '退出并解散群聊'
      }
      return '退出群聊'
    },
    isAdminOrOwner () {
      if (this.groupProfile && this.groupProfile.selfInfo) {
        return this.groupProfile.selfInfo.role !== wx.TIM.TYPES.GRP_MBR_ROLE_MEMBER
      }
      return false
    },
    canIEditGroupProfile () {
      if (!this.groupProfile || !this.groupProfile.selfInfo) {
        return false
      }
      // 任何成员都可修改好友工作群的群资料
      if (this.groupProfile.type === wx.TIM.TYPES.GRP_WORK) {
        return true
      }
      // 其他类型的群组只有管理员以上身份可以修改
      if (this.isAdminOrOwner) {
        return true
      }
      return false
    }
  },
  methods: {
    toAllMemberList () {
      wx.navigateTo({ url: '../members/main' })
    },
    toUserProfile (member) {
      wx.navigateTo({ url: `../user-profile/main?userID=${member.userID}` })
    },
    handleQuit () {
      wx.showModal({
        title: '提示',
        content: '是否确定退出群聊？',
        success: (res) => {
          if (res.confirm) {
            // 解散群聊
            if (this.groupProfile.type !== wx.TIM.TYPES.GRP_WORK && this.groupProfile.selfInfo.role === wx.TIM.TYPES.GRP_MBR_ROLE_OWNER) {
              wx.$app.dismissGroup(this.groupProfile.groupID).then(() => {
                wx.showToast({ title: '解散成功', duration: 800 })
                setTimeout(() => {
                  wx.switchTab({ url: '../index/main' })
                }, 800)
              }).catch((error) => {
                wx.showToast({ title: error.message, icon: 'none' })
              })
            } else {
              // 退出群聊
              wx.$app.quitGroup(this.groupProfile.groupID).then(() => {
                wx.showToast({ title: '退群成功', duration: 800 })
                setTimeout(() => {
                  wx.switchTab({ url: '../index/main' })
                }, 800)
              }).catch((error) => {
                wx.showToast({ title: error.message, icon: 'none' })
              })
            }
          }
        }
      })
    },
    handleClick () {
      if (!this.isAdminOrOwner) {
        wx.showToast({ title: '普通群成员不能设置全体禁言', duration: 1500, icon: 'none' })
      }
    },
    handleMuteSwitch (event) {
      if (this.isAdminOrOwner) {
        let muteAllMembers = event.mp.detail.value
        wx.$app.updateGroupProfile({
          muteAllMembers: muteAllMembers,
          groupID: this.groupProfile.groupID
        }).then(imResponse => {
          const muteAllMembers = imResponse.data.group.muteAllMembers
          if (muteAllMembers) {
            this.$store.commit('showToast', {
              title: '全体禁言已开启',
              con: 'none',
              duration: 1500
            })
          } else {
            this.$store.commit('showToast', {
              title: '全体禁言已取消',
              icon: 'none',
              duration: 1500
            })
          }
        })
          .catch(error => {
            wx.showToast({ title: error.message, duration: 800, icon: 'none' })
          })
      }
    },
    handleOk () {
      if (this.userID === '') {
        wx.showToast({ title: '请输入userID', icon: 'none', duration: 800 })
      }
      wx.$app.addGroupMember({
        groupID: this.groupProfile.groupID,
        userIDList: [this.userID]
      }).then((res) => {
        if (res.data.successUserIDList.length > 0) {
          wx.showToast({ title: '添加成功', duration: 800 })
          this.userID = ''
          this.addMemberModalVisible = false
        }
        if (res.data.existedUserIDList.length > 0) {
          wx.showToast({ title: '该用户已在群中', duration: 800, icon: 'none' })
        }
        if (res.data.failureUserIDList.length > 0) {
          wx.showToast({ title: '添加失败，请确保该用户存在', duration: 800, icon: 'none' })
        }
      }).catch((error) => {
        wx.showToast({ title: error.message, duration: 800, icon: 'none' })
      })
    }
  }
}
</script>

<style lang="stylus">
.add-member-modal-on-focus
  transform translateY(-70px)
.group-detail-wrapper
  height 100vh
  background-color $background
  .header
    display flex
    flex-wrap wrap
    background-color $white
    padding-bottom 18px
    margin-bottom 8px
    .member, .show-more-btn, .add-member-btn
      display flex
      justify-content space-between
      align-items center
      flex-direction column
      width 20%
      padding-top 16px
      .name
        width 40px
        font-size 12px
        overflow hidden
        white-space nowrap
        text-overflow ellipsis
        text-align center
      .avatar
        width 40px
        height 40px
    .show-more-btn, .add-member-btn
      .name
        font-size 10px
.group-action
  margin-top 8px
.quit
  color $danger
.user-id-input
  margin 12px auto
  width 80%
  padding 0 12px
  border-bottom 1px solid $light-background
.cell-value
  color $dark-background !important
</style>
