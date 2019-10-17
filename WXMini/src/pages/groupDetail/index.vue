<template>
  <div class="bg">
    <i-modal title="添加的用户ID" :visible="addModalVisible" @ok="handleAdd" @cancel="handleModalShow">
      <div class="input-wrapper">
        <input type="text" class="input" v-model.lazy:value="addUserId"/>
      </div>
    </i-modal>
    <i-modal title="转让群组" :visible="changeOwnerModal" @ok="handleChangeOwner" @cancel="changeGroupOwner">
      <div class="input-wrapper">
        <i-radio-group :current="current" @change="handleChange">
          <i-radio v-for="item in groupProfile.memberList" position="left" :key="item.userID" :value="item.userID">{{item.userID}}
          </i-radio>
        </i-radio-group>
      </div>
    </i-modal>
    <!--    group进入group详情页-->
    <div class="card">
      <i-row>
        <i-col span="8">
          <div class="avatar">
            <image style="width: 80px; height: 80px; border-radius: 8px" :src="groupProfile.avatar || '/static/images/groups.png'"/>
          </div>
        </i-col>
        <i-col span="16">
          <div class="right">
            <div class="username">{{groupProfile.name}}</div>
            <div class="account">群ID：{{groupProfile.groupID}}</div>
          </div>
        </i-col>
      </i-row>
    </div>
    <div class="card" style="margin-top:10px;padding-left:20px;padding-right:20px ">
      <i-row>
        <i-col span="22">
          <div class="member">
            <div class="member-list">
              群成员
            </div>
            <div @click="handleModalShow()"  v-if="currentGroupProfile.type === 'Private'" style="padding-left: 10px">
              <image
                style="width:20px;height:20px;border-radius:50%"
                src="/static/images/more.png" />
            </div>
          </div>
        </i-col>
        <i-col span="2">
          <div class="member" @click="allMember()">
            <image
              style="width:20px;height:20px;border-radius:50%"
              src="/static/images/right.png" />
          </div>
        </i-col>
      </i-row>
    </div>
    <div class="card">
      <div class="item">
        <div class="key">群介绍</div>
        <div class="value">{{groupProfile.introduction || '未设置'}}</div>
      </div>
    </div>
    <div class="card">
      <div class="item">
        <div class="key">群公告</div>
        <div class="value">{{groupProfile.notification || '未设置'}}</div>
      </div>
    </div>
    <div class="card">
      <div class="item">
        <div class="key">群类型</div>
        <div class="value">{{groupProfile.type}}</div>
      </div>
    </div>
    <div class="revise" v-if="isOwner && groupProfile.type !== 'AVChatRoom'">
        <button @click="changeGroupOwner" class="btn delete">转让群组</button>
      </div>
    <div class="revise" v-if="groupProfile.type !== 'Public'">
      <button @click="quitGroup" class="btn delete">退出群组</button>
    </div>
    <div class="revise"  v-if="isOwner && groupProfile.type !== 'Private'">
      <button @click="dismissGroup" class="btn delete">解散群组</button>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
export default {
  data () {
    return {
      groupProfile: {},
      addModalVisible: false,
      isInBlacklist: false,
      changeOwnerModal: false,
      list: [],
      current: ''
    }
  },
  // 退出聊天页面的时候所有状态清空
  onUnload () {
    this.groupProfile = {}
  },
  computed: {
    ...mapState({
      currentGroupProfile: state => {
        return state.group.currentGroupProfile
      }
    }),
    isMyRoleOwner () {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_OWNER
    },
    isMyRoleAdmin () {
      return this.currentGroupProfile.selfInfo.role === this.$type.GRP_MBR_ROLE_ADMIN
    }
  },
  onShow () {
    this.getBlacklist()
    this.groupProfile = this.$store.state.group.currentGroupProfile
  },
  methods: {
    dismissGroup () {
      wx.$app.dismissGroup(this.groupProfile.groupID)
        .then(({ data: groupID }) => {
          this.$store.commit('showToast', {
            title: `群：${this.groupProfile.name || this.groupProfile.groupID}解散成功！`,
            type: 'success'
          })
          this.$store.commit('resetCurrentConversation')
          this.$store.commit('resetGroup')
          wx.switchTab({
            url: '../index/main'
          })
        })
    },
    changeGroupOwner () {
      this.changeOwnerModal = !this.changeOwnerModal
    },
    handleChange (e) {
      this.current = e.target.value
    },
    handleChangeOwner () {
      wx.$app.changeGroupOwner({
        groupID: this.groupProfile.groupID,
        newOwnerID: this.current
      }).then(() => {
        this.$store.commit('showToast', {
          title: '转让群组成功'
        })
        this.changeGroupOwner()
      })
    },
    // 获取黑名单
    getBlacklist () {
      wx.$app.getBlacklist().then(res => {
        this.$store.commit('setBlacklist', res.data)
      })
    },
    // 所有成员页
    allMember () {
      let count = this.$store.state.group.count
      wx.$app.getGroupMemberList({
        groupID: this.currentGroupProfile.groupID,
        offset: 0,
        count: count
      }).then((res) => {
        this.$store.commit('setCurrentGroupMemberList', res.data.memberList)
        let url = '../members/main'
        wx.navigateTo({url})
      })
    },
    // 退出群聊
    quitGroup () {
      wx.$app.quitGroup(this.groupProfile.groupID).then(() => {
        this.$store.commit('showToast', {
          title: '退出成功',
          icon: 'success',
          duration: 1500
        })
        this.$store.commit('resetCurrentConversation')
        this.$store.commit('resetGroup')
        wx.switchTab({
          url: '../index/main'
        })
      }).catch((err) => {
        console.warn('quitGroupFail', err)
        this.$store.commit('showToast', {
          title: '退出失败',
          icon: 'none',
          duration: 1500
        })
      })
    },
    // 群组详情页，添加群成员modal是否出现
    handleModalShow () {
      this.addModalVisible = !this.addModalVisible
    },
    // 群组详情页，添加群成员
    handleAdd () {
      let conversationID = this.$store.state.conversation.currentConversationID
      wx.$app
        .getUserProfile({
          userIDList: [this.addUserId]
        }).then(() => {
          wx.$app
            .addGroupMember({
              groupID: conversationID.replace(this.TIM.TYPES.CONV_GROUP, ''),
              userIDList: [this.addUserId]
            })
            .then(res => {
              this.addUserId = ''
              this.handleModalShow()
              let fails = res.data.failureUserIDList
              let existed = res.data.existedUserIDList
              let success = res.data.successUserIDList
              if (fails.length > 0) {
                this.$store.commit('showToast', {
                  title: '添加失败!再试试吧',
                  icon: 'none',
                  duration: 1500
                })
              }
              if (existed.length > 0) {
                this.$store.commit('showToast', {
                  title: '已经在群里',
                  icon: 'none',
                  duration: 1500
                })
              }
              if (success.length > 0) {
                this.$store.commit('showToast', {
                  title: '添加成功',
                  icon: 'none',
                  duration: 1500
                })
              }
            })
        }).catch(() => {
          this.$store.commit('showToast', {
            title: '没有找到该用户',
            icon: 'none',
            duration: 1500
          })
        })
    }
  },
  destory () {}
}
</script>

<style lang="stylus" scoped>
.member-list
  color $base
  font-weight 500
.manage
  color $dark-primary
  border-radius 8px
  border 1px solid $dark-primary
  padding 2px 4px
.input-wrapper
  width 100%
  display flex
  justify-content center
.input
  width 80%
  border 1px solid $border-light
  border-radius 12px
.bg
  background-color $background
  height 100vh
// 添加用户当弹窗
.input-wrapper
  width 100%
  display flex
  justify-content center
.card
  border-top 1px solid $border-light
  border-bottom 1px solid $border-light
  background-color white
  margin-bottom -1px
.member
  display flex
  padding-top 10px
  padding-bottom 10px
.avatar
  padding 10px
.right
  box-sizing border-box
  height 100px
  padding 10px
  display flex
  flex-direction column
  justify-content space-around
  .username
    font-weight 600
    font-size 18px
    color $base
  .account
    font-size 14px
    color $secondary
.btn
  color white
  background-color $primary
  border-radius 20px
  height 40px
  width 150px
  line-height 40px
  font-size 16px
.delete
  background-color $danger
.item
  display flex
  justify-content space-between
  font-size 16px
  .key
    padding 10px 20px
    width 20%
    font-weight 500
    color $base
  .value
    width 80%
    padding 10px 20px 10px 0
    font-weight 400
    color $regular
    overflow hidden
    text-overflow ellipsis
    white-space nowrap
.revise
  padding-top 20px
  display flex
  flex-direction column
  justify-content space-around
  height 50px
</style>
