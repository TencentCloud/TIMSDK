<template>
  <div class="chatting">
    <div class="chat" v-for="item in allConversation" :key="item.conversationID">
      <i-modal title="确认删除会话？" :visible="modalVisible" @ok="handleConfirm()" @cancel="handleModalShow">
      </i-modal>
      <div @longpress="longTimePress(item)">
        <i-row v-if="item.type === 'C2C'" @click="checkoutConversation(item, item.userProfile.nick || item.userProfile.userID)" slot="content">
          <i-col span="4">
            <div class="avatar">
              <i-avatar :src="item.userProfile.avatar || '/static/images/header.png'" size="large" shape="square" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right">
              <div class="information">
                <div class="username">{{item.userProfile.nick || item.userProfile.userID}}</div>
                <div class="last">{{item.lastMessage._lastTime}}</div>
              </div>
              <div class="information">
                <div class="content">{{item.lastMessage.messageForShow}}</div>
                <div class="remain" v-if="item.unreadCount > 0">{{item.unreadCount}}</div>
              </div>
            </div>
          </i-col>
        </i-row>
        <i-row v-else-if="item.type === 'GROUP'" @click="checkoutConversation(item, item.groupProfile.name || item.groupProfile.ID)" slot="content">
          <i-col span="4">
            <div class="avatar">
              <i-avatar :src="item.groupProfile.avatar || '/static/images/groups.png'" size="large" shape="square" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right">
              <div class="information">
                <div class="username">{{item.groupProfile.name || item.groupProfile.groupID}}</div>
                <div class="last">{{item.lastMessage._lastTime}}</div>
              </div>
              <div class="information">
                <div class="content" v-if="item.lastMessage.fromAccount === '@TIM#SYSTEM'">{{item.lastMessage.messageForShow}}</div>
                <div class="content" v-else-if="item.lastMessage.type === 'TIMCustomElem'">[自定义消息]</div>
                <div class="content-red" v-else-if="item.lastMessage.at && item.unreadCount > 0">[有人@你了]</div>
                <div class="content" v-else>{{item.lastMessage.fromAccount}}：{{item.lastMessage.messageForShow}}</div>
                <div class="remain" v-if="item.unreadCount > 0">{{item.unreadCount}}</div>
              </div>
            </div>
          </i-col>
        </i-row>
        <i-row v-else-if="item.type === '@TIM#SYSTEM'" @click="checkoutNotification(item)" slot="content">
          <i-col span="4">
            <div class="avatar">
              <i-avatar src="../../../static/images/system.png" size="large" shape="square" />
            </div>
          </i-col>
          <i-col span="20">
            <div class="right">
              <div class="information">
                <div class="username">系统通知</div>
                <div class="remain" v-if="item.unreadCount > 0">{{item.unreadCount}}</div>
              </div>
              <div class="information">
                <div class="content">点击查看</div>
              </div>
            </div>
          </i-col>
        </i-row>
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import { throttle } from '../../utils/index'
export default {
  data () {
    return {
      modalVisible: false,
      conversation: {}
    }
  },
  computed: {
    ...mapState({
      allConversation: state => {
        return state.conversation.allConversation
      }
    })
  },
  // 消息列表下拉
  onPullDownRefresh () {
    throttle(wx.$app.getConversationList(), 1000)
    wx.stopPullDownRefresh()
  },
  methods: {
    longTimePress (item) {
      this.conversation = item
      this.handleModalShow()
    },
    handleModalShow () {
      this.modalVisible = !this.modalVisible
    },
    handleConfirm () {
      this.handleModalShow()
      this.deleteConversation(this.conversation)
    },
    // 将某会话设为已读
    setMessageRead (item) {
      if (item.unreadCount === 0) {
        return
      }
      wx.$app.setMessageRead({
        conversationID: item.conversationID
      })
    },
    // 点击某会话
    checkoutConversation (item, name) {
      if (item.lastMessage.at) {
        this.$store.commit('offAtRemind', item)
      }
      this.$store.commit('resetCurrentConversation')
      this.$store.commit('resetGroup')
      this.setMessageRead(item)
      wx.$app.getConversationProfile(item.conversationID)
        .then((res) => {
          this.$store.commit('updateCurrentConversation', res.data.conversation)
          this.$store.dispatch('getMessageList')
          if (item.type === this.TIM.TYPES.CONV_GROUP) {
            let groupID = item.conversationID.substring(5)
            wx.$app.getGroupProfile({ groupID: groupID })
              .then(res => {
                this.$store.commit('updateCurrentGroupProfile', res.data.group)
              })
          }
        })
      let url = `../chat/main?toAccount=${name}`
      wx.navigateTo({url})
    },
    // 点击系统通知时，处理notification
    checkoutNotification (item) {
      this.$store.commit('resetCurrentConversation')
      this.$store.commit('resetGroup')
      this.setMessageRead(item)
      wx.$app.getConversationProfile(item.conversationID)
        .then((res) => {
          this.$store.commit('updateCurrentConversation', res.data.conversation)
          this.$store.dispatch('getMessageList')
        })
      let url = '../system/main'
      wx.navigateTo({url})
    },
    // 删除会话
    deleteConversation (item) {
      wx.$app.deleteConversation(item.conversationID).then((res) => {
        console.log('delete success', res)
      })
    }
  },
  // 初始化加载userProfile并且存入store
  onLoad () {
    wx.$app.getMyProfile().then(res => {
      this.$store.commit('updateMyInfo', res.data)
    })
    wx.$app.getBlacklist().then(res => {
      this.$store.commit('setBlacklist', res.data)
    })
  },
  mounted () {}
}
</script>

<style lang='stylus' scoped>
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  font-size 16px
.avatar
  padding-right 10px
.chatting
  background-color $dark-background
  min-height 100vh
  box-sizing border-box
  border-bottom 1px solid $border-base
.chat
  background-color white
  margin-bottom -1px
  padding 15px 20px
  border-top 1px solid $border-base
  border-bottom 1px solid $border-base
.right
  padding 0 18px 0 8px
.information
  display flex
  flex-direction row
  justify-content space-between
.username
  color $base
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  width 50%
.last
  color $regular
  font-size 12px
  padding 2px 0
.content
  color $regular
  font-size 12px
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  width 80%
.content-red
  color $danger
  font-size 12px
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  width 80%
.remain
  color white
  font-size 12px
  background-color $danger
  border-radius 8px
  padding 2px 8px
.delete
  color white
  font-size 14px
  font-weight 600
  background-color $danger
  height 100%
  display flex
  flex-direction column
  justify-content center
.delete-button
  text-align center
</style>
