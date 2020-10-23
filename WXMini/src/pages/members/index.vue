<template>
  <div class="chatting">
    <i-modal title="设置禁言时间" :visible="muteModal" @ok="muteMember" @cancel="cancelMuteModal">
      <div class="input-wrapper" v-show="muteModal">
        <input type="number" class="input" placeholder="单位：秒" v-model.lazy:value="muteTime"/>
      </div>
    </i-modal>
    <div class="chat" v-for="item in currentGroupMemberList" :key="item.userID">
      <i-row slot="content">
        <i-col span="1">
          <div class="last" v-if="item.role === 'Member'">普</div>
          <div class="last" v-else-if="item.role === 'Admin'">管</div>
          <div class="last" v-else-if="item.role === 'Owner'">主</div>
        </i-col>
        <i-col span="3">
          <div class="avatar">
            <i-avatar :src="item.avatar || '/static/images/avatar.png'"/>
          </div>
        </i-col>
        <i-col span="7">
          <div class="information">
            <div class="username">{{item.nick || item.userID}}</div>
          </div>
        </i-col>
        <i-col span="6" v-if="currentGroupProfile.type === 'Public' || currentGroupProfile.type === 'ChatRoom'">
          <div class="information">
            <a class="set" v-if="(isMyRoleOwner || isMyRoleAdmin) && item.role === 'Member'" @click="setRole(item)">设为管理员</a>
            <a class="set" v-if="isMyRoleOwner && item.role === 'Admin'" @click="setRole(item)">取消管理员</a>
          </div>
        </i-col>
        <i-col span="3">
          <div class="information">
            <a class="delete" v-if="(isMyRoleOwner && item.role !== 'Owner'|| isMyRoleAdmin && item.role === 'Member')" @click="kick(item)">删除</a>
          </div>
        </i-col>
        <i-col span="4">
          <div class="information" v-if="currentGroupProfile.type !== 'Private'">
            <div v-if="(isMyRoleOwner && (item.role === 'Member' || item.role === 'Admin')) || (isMyRoleAdmin && item.role === 'Member')">
              <span v-if="item.muteUntil * 1000 > current">
                <a class="delete" @click="cancelMute(item)">取消禁言</a>
              </span>
              <span v-else>
                <a class="delete" @click="mute(item)">禁言</a>
              </span>
            </div>
          </div>
        </i-col>
      </i-row>
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
      intervalID: ''
    }
  },
  computed: {
    ...mapState({
      currentGroupProfile: state => {
        return state.conversation.currentConversation.groupProfile
      },
      currentGroupMemberList: state => {
        return state.group.currentGroupMemberList
      }
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
  methods: {
    getGroupMemberList () {
      this.$store.dispatch('getGroupMemberList')
    },
    muteMember () {
      wx.$app.setGroupMemberMuteTime({
        groupID: this.currentGroupProfile.groupID,
        userID: this.member.userID,
        muteTime: Number(this.muteTime)
      }).then((res) => {
        this.$store.commit('showToast', {
          title: '设置禁言成功'
        })
        this.muteTime = undefined
        this.cancelMuteModal()
      })
    },
    cancelMuteModal () {
      this.muteModal = false
    },
    cancelMute (item) {
      wx.$app.setGroupMemberMuteTime({
        groupID: this.currentGroupProfile.groupID,
        userID: item.userID,
        muteTime: Number(0)
      }).then(() => {
        this.$store.commit('showToast', {
          title: '禁言成功'
        })
      })
    },
    // 踢出群聊
    kick (item) {
      wx.$app.deleteGroupMember({
        groupID: this.currentGroupProfile.groupID,
        reason: '踢出群',
        userIDList: [item.userID]
      })
    },
    mute (item) {
      this.muteModal = true
      this.member = item
    },
    // 设置群角色——管理员Admin, 普通Member
    setRole (item) {
      let role = 'Admin'
      if (item.role === 'Admin') {
        role = 'Member'
      }
      wx.$app.setGroupMemberRole({
        groupID: this.currentGroupProfile.groupID,
        userID: item.userID,
        role: role
      }).then(() => {
        this.$store.commit('showToast', {
          title: '设置成功',
          icon: 'success',
          duration: 1500
        })
      })
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
  padding-right 10px
.information
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
</style>
