<template>
  <div class="chat-container">
    <div v-if="allConversation.length === 0" class="empty">
      <button type="button" class="empty-button" @click="empty">
        发起一段对话吧
      </button>
    </div>
    <i-modal title="确认删除会话？" :visible="modalVisible" @ok="handleConfirm()" @cancel="handleModalShow">
    </i-modal>
    <template v-for="item in allConversation">
      <div class="chat"
         v-if="item.type === 'C2C'"
         :key="item.conversationID"
         @longpress="longTimePress(item)"
         @click="checkoutConversation(item, item.userProfile.nick || item.userProfile.userID)">
        <div class="avatar-container">
          <i-avatar :src="item.userProfile.avatar || '/static/images/avatar.png'" i-class="avatar" />
        </div>
        <div class="right">
          <div class="information">
            <div class="username">{{item.userProfile.nick || item.userProfile.userID}}</div>
            <div class="content" v-if="!item.lastMessage.isRevoked">{{item.lastMessage.messageForShow}}</div>
            <div class="content" v-else>
              <template v-if="myInfo.userID === item.lastMessage.fromAccount">你撤回了一条消息</template>
              <template v-else>{{item.lastMessage.fromAccount}}撤回了一条消息</template>
            </div>
          </div>
          <div class="time">
            <div class="last">{{item.lastMessage._lastTime}}</div>
            <div class="remain" v-if="item.unreadCount > 0">
              <span v-if="item.unreadCount > 99" class="info">99+</span>
              <span v-else class="info">{{item.unreadCount}}</span>
            </div>
          </div>
        </div>
      </div>
      <div class="chat"
         v-else-if="item.type === 'GROUP'"
         @click="checkoutConversation(item, item.groupProfile.name || item.groupProfile.ID)"
         :key="item.conversationID"
         @longpress="longTimePress(item)">
        <div class="avatar-container">
          <i-avatar :src="item.groupProfile.avatar" i-class="avatar" />
        </div>
        <div class="right">
          <div class="information">
            <div class="username">{{item.groupProfile.name || item.groupProfile.groupID}}</div>
            <div class="content" v-if="!item.lastMessage.isRevoked">
              <template v-if="item.lastMessage.fromAccount === '@TIM#SYSTEM'">{{item.lastMessage.messageForShow}}</template>
              <template v-else>{{item.lastMessage.fromAccount}}：{{item.lastMessage.messageForShow}}</template>
            </div>
            <div class="content" v-else>
              <template v-if="myInfo.userID === item.lastMessage.fromAccount">你撤回了一条消息</template>
              <template v-else>{{item.lastMessage.fromAccount}}撤回了一条消息</template>
            </div>
          </div>
          <div class="time">
            <div class="last">{{item.lastMessage._lastTime}}</div>
            <div class="remain" v-if="item.unreadCount > 0">
              <span v-if="item.unreadCount > 99" class="info">99+</span>
              <span v-else class="info">{{item.unreadCount}}</span>
            </div>
          </div>
        </div>
      </div>
      <div class="chat"
           v-else-if="item.type === '@TIM#SYSTEM'"
           @click="checkoutNotification(item)"
           :key="item.conversationID"
           @longpress="longTimePress(item)">
        <div class="avatar-container">
          <image src="/static/images/system.png" class="avatar" />
        </div>
        <div class="right">
          <div class="information">
            <div class="username">系统通知</div>
            <div class="content">点击查看</div>
          </div>
          <div class="time">
            <div class="last"></div>
            <div class="remain" v-if="item.unreadCount > 0">
              <span v-if="item.unreadCount > 99" class="info">99+</span>
              <span v-else class="info">{{item.unreadCount}}</span>
            </div>
          </div>
        </div>
      </div>
    </template>
  </div>
</template>

<script>
import { mapState, mapGetters } from 'vuex'
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
      allConversation: state => state.conversation.allConversation,
      isSdkReady: state => state.global.isSdkReady
    }),
    ...mapGetters(['totalUnreadCount', 'myInfo'])
  },
  // 消息列表下拉
  onPullDownRefresh () {
    throttle(wx.$app.getConversationList(), 1000)
    wx.stopPullDownRefresh()
  },
  methods: {
    // 长按删除会话
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
      this.$store.dispatch('checkoutConversation', item.conversationID)
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
    },
    empty () {
      let url = '../search/main'
      wx.navigateTo({url})
    }
  },
  onLoad () {
    if (!this.isSdkReady) {
      wx.showLoading({ title: '正在同步数据', mask: true })
    }
  },
  watch: {
    isSdkReady (newVal) {
      if (newVal) {
        wx.hideLoading()
      }
    }
  }
}
</script>

<style lang='stylus'>
.chat-container
  background-color $background
  min-height 100vh
  box-sizing border-box
  border-bottom 1px solid $border-base
  .chat
    background-color white
    box-sizing border-box
    display flex
    height 72px
    &:last-child .right
      border-bottom none
    .avatar-container
      padding 12px
      box-sizing border-box
      .avatar
        border-radius 4px
        height 48px
        width 48px
.information
  display flex
  flex-direction column
  padding-right 10px
  height 48px
  width 60%
  flex-grow 1
  .username
    color $base
    font-size 18px
    line-height 28px
    overflow hidden
    text-overflow ellipsis
    white-space nowrap
  .content
    color $secondary
    font-size 14px
    overflow hidden
    line-height 20px
    text-overflow ellipsis
    white-space nowrap
.right
  padding 12px 0
  display flex
  justify-content space-between
  box-sizing border-box
  border-bottom 1px solid $light-background
  width calc(100% - 80px) // 80px 是头像框的宽度
  flex-grow 1
.time
  padding-right 16px
  display flex
  flex-direction column
  flex-basis 100px
  text-align right
  .last
    color $secondary
    font-size 12px
    line-height 28px
  .remain
    display flex
    flex-direction row-reverse
    .info
      color white
      font-size 12px
      background-color $danger
      border-radius 30px
      padding 2px 7px 3px
.empty
  display flex
  align-content center
  justify-content center
  .empty-button
    display flex
    justify-content center
    align-items center
    height 46px
    color white
    margin-top 40vh
    padding 12px
    background-color $primary
    border-radius 6px
    font-size 18px
    width 80vw
    &:before
      content '+'
      font-size 22px
      margin-right 12px
.input
  text-align center
  height 32px
  background-color white
  border-radius 8px
  font-size 16px

.content-red
  color $danger
  font-size 12px
  overflow hidden
  text-overflow ellipsis
  white-space nowrap
  width 80%
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
