<template>
  <div>
    <div>
      <span class="label">userID:</span>
      {{ member.userID }}
      <el-button v-if="showCancelBan" type="text" @click="cancelMute">取消禁言</el-button>
      <el-popover title="禁言" v-model="popoverVisible" v-show="showBan">
        <el-input v-model="muteTime" placeholder="请输入禁言时间" @keydown.enter.native="setGroupMemberMuteTime" />
        <el-button slot="reference" type="text" style="color:red;">禁言</el-button>
      </el-popover>
    </div>
    <div>
      <span class="label">nick:</span>
      {{ member.nick || '暂无' }}
    </div>
    <div>
      <span class="label">nameCard:</span>
      {{ member.nameCard || '暂无' }}
      <el-popover title="修改群名片" v-model="nameCardPopoverVisible" v-show="showEditNameCard">
        <el-input v-model="nameCard" placeholder="请输入群名片" @keydown.enter.native="setGroupMemberNameCard" />
        <i class="el-icon-edit" title="修改群名片" slot="reference" style="cursor:pointer; font-size:1.6rem;"></i>
      </el-popover>
    </div>
    <div>
      <span class="label">role:</span>
      <span class="content role" :title="changeRoleTitle">{{ member.role }}</span>
    </div>
    <div v-if="showMuteUntil">
      <span class="label">禁言至:</span>
      <span class="content">{{ muteUntil }}</span>
    </div>
    <el-button type="text" v-if="canChangeRole" @click="changeMemberRole">{{
      member.role === 'Admin' ? '取消管理员' : '设为管理员'
    }}</el-button>
    <el-button type="text" v-if="showKickout" style="color:red;" @click="kickoutGroupMember">踢出群组</el-button>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { Popover } from 'element-ui'
import { getFullDate } from '../../../utils/date'
export default {
  components: {
    ElPopover: Popover
  },
  props: ['member'],
  data() {
    return {
      muteTime: '',
      popoverVisible: false,
      nameCardPopoverVisible: false,
      nameCard: this.member.nameCard,
    }
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation,
      currentUserProfile: state => state.user.currentUserProfile,
      current: state => state.current
    }),
    // 是否显示踢出群成员按钮
    showKickout() {
      return (this.isOwner || this.isAdmin) && !this.isMine
    },
    isOwner() {
      return this.currentConversation.groupProfile.selfInfo.role === 'Owner'
    },
    isAdmin() {
      return this.currentConversation.groupProfile.selfInfo.role === 'Admin'
    },
    isMine() {
      return this.currentUserProfile.userID === this.member.userID
    },
    canChangeRole() {
      return this.isOwner && ['ChatRoom', 'Public'].includes(this.currentConversation.subType)
    },
    changeRoleTitle() {
      if (!this.canChangeRole) {
        return ''
      }
      return this.isOwner && this.member.role === 'Admin' ? '设为：Member' : '设为：Admin'
    },
    // 是否显示禁言时间
    showMuteUntil() {
      // 禁言时间小于当前时间
      return this.member.muteUntil * 1000 > this.current
    },
    // 是否显示取消禁言按钮
    showCancelBan() {
      if (this.showMuteUntil && this.currentConversation.type === this.TIM.TYPES.CONV_GROUP && !this.isMine) {
        return this.isOwner || this.isAdmin
      }
      return false
    },
    // 是否显示禁言按钮
    showBan() {
      if (this.currentConversation.type === this.TIM.TYPES.CONV_GROUP) {
        return this.isOwner || this.isAdmin
      }
      return false
    },
    // 是否显示编辑群名片按钮
    showEditNameCard() {
      return this.isOwner || this.isAdmin
    },
    // 日期格式化后的禁言时间
    muteUntil() {
      return getFullDate(new Date(this.member.muteUntil * 1000))
    }
  },
  methods: {
    kickoutGroupMember() {
      this.tim.deleteGroupMember({
        groupID: this.currentConversation.groupProfile.groupID,
        reason: '我要踢你出群',
        userIDList: [this.member.userID]
      })
    },
    changeMemberRole() {
      if (!this.canChangeRole) {
        return
      }
      let currentRole = this.member.role
      this.tim.setGroupMemberRole({
        groupID: this.currentConversation.groupProfile.groupID,
        userID: this.member.userID,
        role: currentRole === 'Admin' ? 'Member' : 'Admin'
      })
    },
    setGroupMemberMuteTime() {
      this.tim
        .setGroupMemberMuteTime({
          groupID: this.currentConversation.groupProfile.groupID,
          userID: this.member.userID,
          muteTime: Number(this.muteTime)
        })
        .then(() => {
          this.muteTime = ''
          this.popoverVisible = false
        })
    },
    // 取消禁言
    cancelMute() {
      this.tim
        .setGroupMemberMuteTime({
          groupID: this.currentConversation.groupProfile.groupID,
          userID: this.member.userID,
          muteTime: 0
        })
        .then(() => {
          this.muteTime = ''
        })
    },
    setGroupMemberNameCard() {
      if (this.nameCard.trim().length === 0) {
        this.$store.commit('showMessage', {
          message: '不能设置空的群名片',
          type: 'warning'
        })
        return
      }
      this.tim
        .setGroupMemberNameCard({
          groupID: this.currentConversation.groupProfile.groupID,
          userID: this.member.userID,
          nameCard: this.nameCard
        })
        .then(() => {
          this.nameCardPopoverVisible = false
          this.$store.commit('showMessage', {
            message: '修改成功'
          })
        })
    }
  }
}
</script>

<style lang="stylus" scoped>
.label {
  color: rgb(204, 200, 200);
}
.cursor-pointer {
  cursor: pointer;
}
</style>
