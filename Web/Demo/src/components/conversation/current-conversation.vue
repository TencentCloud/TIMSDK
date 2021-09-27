<template>
  <div class="current-conversation-wrapper">
    <FriendProfile style="position: relative"/>
    <div class="current-conversation" @scroll="onScroll" v-if="showCurrentConversation">
      <div class="header">
        <div class="name">{{ name }}</div>
        <div class="btn-more-info"
          :class="showConversationProfile ? '' : 'left-arrow'"
          @click="showMore"
          v-show="!currentConversation.conversationID.includes('SYSTEM')"
          title="查看详细信息">
        </div>
      </div>
      <div class="content">
        <div class="message-list" ref="message-list" @scroll="this.onScroll">
          <div class="more" v-if="!isCompleted">
            <el-button
              type="text"
              @click="$store.dispatch('getMessageList', currentConversation.conversationID)"
            >查看更多</el-button>
          </div>
          <div class="no-more" v-else>没有更多了</div>
          <el-checkbox-group v-model="checkList" v-if="selectMessage">
            <el-checkbox :label="message.ID" v-for="message in currentMessageList" :key="message.ID" :disabled="message.status==='fail'">
              <message-item   :message="message"/>
            </el-checkbox>
          </el-checkbox-group>
          <message-item v-else v-for="message in currentMessageList" :key="message.ID" :message="message"/>
        </div>
        <div v-show="isShowScrollButtomTips" class="newMessageTips" @click="scrollMessageListToButtom">回到最新位置</div>
      </div>
      <div class="footer" v-if="showMessageSendBox" >
        <div class="merger-btn"  v-if="selectMessage">
          <div  class="relay-btn" @click="singleRelay">
            <img class="relay-icon" src="../../assets/image/sig-relay.png">
            <span class="relay-title">逐条转发</span>
          </div>
          <div  class="relay-btn" @click="mergerRelay">
            <img class="relay-icon" src="../../assets/image/merger-relay.png">
            <span class="relay-title">合并转发</span>
          </div>
          <div  class="relay-btn" @click="closeSelectMessage">
            <img class="relay-icon" src="../../assets/image/close-relay.png">
            <span class="relay-title">取消</span>
          </div>
        </div>
        <message-send-box v-else/>
      </div>
    </div>
    <div>
      <message-relay v-if="isShowConversationList "></message-relay>
    </div>
    <div class="profile" v-if="showConversationProfile" >
      <conversation-profile/>
    </div>
    <!-- 群成员资料组件 -->
    <member-profile-card />
      <el-popover
              ref="dropdown"
              placement="left-start"
              width="700"
              v-model="mergerMessagePop">
         <div class="pop-header">
           <img src="../../assets/image/back.png" v-if="mergerMessageList.length >1" class="pop-back" @click="mergerMessageBack"/>
           <span  class="title">{{mergerTitle}}</span>
           <img src="../../assets/image/close.png" class="pop-close" @click="closeMessagePop"/>
         </div>
        <transition
                name="custom-classes-transition"
                enter-active-class="animated fadeIn"
                leave-active-class="animated fadeOut"
        >
         <message-merger v-if="mergerMessagePop"></message-merger>
        </transition>
      </el-popover>
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'
import MessageSendBox from '../message/message-send-box'
import MessageItem from '../message/message-item'
import ConversationProfile from './conversation-profile.vue'
import MemberProfileCard from '../group/member-profile-card'
import MessageMerger from '../message/merger-message/message-merger'
import MessageRelay from '../message/merger-message/message-relay'
import FriendProfile from '../friend/friend-container'
import close from '../../assets/image/close.png'

export default {
  name: 'CurrentConversation',
  components: {
    MessageSendBox,
    MessageItem,
    ConversationProfile,
    MemberProfileCard,
    MessageMerger,
    MessageRelay,
    FriendProfile
  },
  data() {
    return {
      close: close,
      isShowScrollButtomTips: false,
      preScrollHeight: 0,
      showConversationProfile: false,
      timeout: '',
      checkList: [],
      // selectMessage: false,
      selectedMessageList: [],
      mergerMessagePop: false,
      mergerMessage: null,
      positionX: 0,
      positionY: 0,
    }
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation,
      currentUnreadCount: state => state.conversation.currentConversation.unreadCount,
      currentMessageList: state => state.conversation.currentMessageList,
      isCompleted: state => state.conversation.isCompleted,
      mergerMessageList: state => state.conversation.mergerMessageList,
      isShowConversationList: state => state.conversation.isShowConversationList,
      selectMessage: state => state.conversation.selectMessage,
      friendContent: state => state.friend.friendContent,
    }),
    ...mapGetters(['toAccount', 'hidden']),
    // 是否显示当前会话组件
    showCurrentConversation() {
      return !!this.currentConversation.conversationID
    },
    showFriendContent() {
      return this.friendContent
    },
    name() {
      if (this.currentConversation.type === 'C2C') {
        // let name = this.currentConversation.userProfile.nick || this.toAccount
        // let list = this.currentMessageList
        // let len = list.length
        // for (let i = len - 1; i >= 0; i--) {
        //   // C2C 会话对端更新nick时需要更新会话title
        //   if (list[i].flow === 'in' && list[i].nick && name !== list[i].nick) {
        //     name = list[i].nick
        //     break
        //   }
        // }
        return this.currentConversation.remark || this.currentConversation.userProfile.nick || this.currentConversation.userProfile.userID

      } else if (this.currentConversation.type === 'GROUP') {
        return this.currentConversation.groupProfile.name || this.toAccount
      } else if (this.currentConversation.conversationID === '@TIM#SYSTEM') {
        return '系统通知'
      }
      return this.toAccount
    },
    showMessageSendBox() {
      return this.currentConversation.type !== this.TIM.TYPES.CONV_SYSTEM
    },
    mergerTitle() {
      if (this.mergerMessage) {
        return this.mergerMessage.payload.title || '聊天记录'
      } else {
        return  '聊天记录'
      }
    }
  },

  mounted() {
    if (this.$refs.dropdown && this.$refs.dropdown.$el) {
      this.$refs.dropdown.$el.addEventListener('mousedown', this.move)
    }
    this.$bus.$on('image-loaded', this.onImageLoaded)
    this.$bus.$on('scroll-bottom', this.scrollMessageListToButtom)
    this.$bus.$on('mergerSelected', this.mergerSelectedHandler)
    this.$bus.$on('mergerMessageShow', this.mergerShow)


    if (this.currentConversation.conversationID === '@TIM#SYSTEM') {
      return false
    }
  },
  beforeDestroy() {
    if (this.$refs.dropdown && this.$refs.dropdown.$el) {
      this.$refs.dropdown.$el.removeEventListener('mousedown', this.move)
    }
  },
  updated() {
    this.keepMessageListOnButtom()
    // 1. 系统会话隐藏右侧资料组件
    // 2. 没有当前会话时，隐藏右侧资料组件。
    //    背景：退出群组/删除会话时，会出现一处空白区域
    if (this.currentConversation.conversationID === '@TIM#SYSTEM' ||
        typeof this.currentConversation.conversationID === 'undefined') {
      this.showConversationProfile = false
    }
  },
  watch: {
    currentUnreadCount(next) {
      if (!this.hidden && next > 0) {
        this.tim.setMessageRead({ conversationID: this.currentConversation.conversationID })
      }
    },
    hidden(next) {
      if (!next && this.currentUnreadCount > 0) {
        this.tim.setMessageRead({ conversationID: this.currentConversation.conversationID })
      }
    }
  },
  methods: {
    move(e) {
      let odiv = this.$refs.dropdown.$el.children[0]//e.target        //获取目标元素
      //算出鼠标相对元素的位置
      let disX = e.clientX - odiv.offsetLeft
      let disY = e.clientY - odiv.offsetTop
      document.onmousemove = (e)=>{       //鼠标按下并移动的事件
        //用鼠标的位置减去鼠标相对元素的位置，得到元素的位置
        let left = e.clientX - disX
        let top = e.clientY - disY

        //绑定元素位置到positionX和positionY上面
        this.positionX = top
        this.positionY = left

        //移动当前元素
        odiv.style.left = left + 'px'
        odiv.style.top = top + 'px'
      }
      document.onmouseup = () => {
        document.onmousemove = null
        document.onmouseup = null
      }
    },
    mergerMessageBack() {
      let index = this.mergerMessageList.length - 2
      this.$store.commit('updateMergerMessage', this.mergerMessageList[index])
      // this.mergerMessageList.pop()
    },
    closeMessagePop() {
      this.mergerMessagePop = false
      this.$store.commit('resetMergerMessage')
    },
    closeSelectMessage() {
      this.$store.commit('resetSelectedMessage', false)
    },
    mergerSelectedHandler() {
      this.selectedMessageList = []
      this.checkList = []
      this.$store.commit('setSelectedMessage', true)
    },
    mergerShow(value) {
      this.mergerMessagePop = true
      this.mergerMessage = value
      this.$store.commit('setMergerMessage', value)
    },
    mergerRelay() {
      this.selectedMessage()
      this.$store.commit('setRelayType', 3)
    },
    singleRelay() {
      this.selectedMessage()
      this.$store.commit('setRelayType', 2)
    },
    selectedMessage () {
      let messageList = []
      this.selectedMessageList = []
      this.checkList.forEach((id) => {
        messageList = this.currentMessageList.find((item) => {
          return item.ID === id
        })
        this.selectedMessageList.push(messageList)
      })

      this.$store.commit('showConversationList', true)
      //this.closeSelectMessage() // TODO
      this.$store.commit('setSelectedMessageList', this.selectedMessageList)
    },
    onScroll({ target: { scrollTop } }) {
      let messageListNode = this.$refs['message-list']
      if (!messageListNode) {
        return
      }
      if (this.preScrollHeight - messageListNode.clientHeight - scrollTop < 20) {
        this.isShowScrollButtomTips = false
      }
    },
    // 如果滚到底部就保持在底部，否则提示是否要滚到底部
    keepMessageListOnButtom() {
      let messageListNode = this.$refs['message-list']
      if (!messageListNode) {
        return
      }
      // 距离底部20px内强制滚到底部,否则提示有新消息
      if (this.preScrollHeight - messageListNode.clientHeight - messageListNode.scrollTop < 20) {
        this.$nextTick(() => {
          messageListNode.scrollTop = messageListNode.scrollHeight
        })
        this.isShowScrollButtomTips = false
      } else {
        this.isShowScrollButtomTips = true
      }
      this.preScrollHeight = messageListNode.scrollHeight
    },
    // 直接滚到底部
    scrollMessageListToButtom() {
      this.$nextTick(() => {
        let messageListNode = this.$refs['message-list']
        if (!messageListNode) {
          return
        }
        messageListNode.scrollTop = messageListNode.scrollHeight
        this.preScrollHeight = messageListNode.scrollHeight
        this.isShowScrollButtomTips = false
      })
    },
    showMore() {
      this.showConversationProfile = !this.showConversationProfile
    },
    onImageLoaded() {
      this.keepMessageListOnButtom()
    }
  }
}
</script>

<style lang="stylus" scoped>
/* 当前会话的骨架屏 */
.current-conversation-wrapper
  height $height
  background-color $background-light
  color $base
  display flex
  .current-conversation
    display: flex;
    flex-direction: column;
    width: 100%;
    height: $height;
  .profile
    height: $height;
    overflow-y: scroll;
    width 220px
    border-left 1px solid $border-base
    flex-shrink 0
  .more
    display: flex;
    justify-content: center;
    font-size: 12px;
  .no-more
    display: flex;
    justify-content: center;
    color: $secondary;
    font-size: 12px;
    padding: 10px 10px;

.header
  border-bottom 1px solid $border-base
  height 50px
  position relative
  .name
    padding 0 20px
    color $base
    font-size 18px
    font-weight bold
    line-height 50px
    text-shadow $font-dark 0 0 0.1em
  .btn-more-info
    position absolute
    top 10px
    right -15px
    border-radius 50%
    width 30px
    height 30px
    cursor pointer
    &::before
      position absolute
      right 0
      z-index 0
      content ""
      width: 15px
      height: 30px
      border: 1px solid $border-base
      border-radius: 0 100% 100% 0/50%
      border-left: none
      background-color $background-light
    &::after
      content ""
      width: 8px;
      height: 8px;
      transition: transform 0.8s;
      border-top: 2px solid $secondary;
      border-right: 2px solid $secondary;
      float:right;
      position:relative;
      top: 11px;
      right: 8px;
      transform:rotate(45deg)
    &.left-arrow
      transform rotate(180deg)
      &::before
        background-color $white
    &:hover
      &::after
        border-color $light-primary
.content
  display: flex;
  flex 1
  flex-direction: column;
  height: 100%;
  overflow: hidden;
  position: relative;
  .message-list
    width: 100%;
    box-sizing: border-box;
    overflow-y: scroll;
    padding: 0 20px;
  .newMessageTips
    position: absolute
    cursor: pointer;
    padding: 5px;
    width: 120px;
    margin: auto;
    left: 0;
    right: 0;
    bottom: 5px;
    font-size: 12px;
    text-align: center;
    border-radius: 10px;
    border: $border-light 1px solid;
    background-color: $white;
    color: $primary;
.footer
  border-top: 1px solid $border-base;
  .merger-btn {
    height 150px
    padding 3px 20px 20px 20px
    box-sizing border-box
    display flex
    justify-content space-between
    padding-top 50px
    .relay-btn {
      display flex
      flex-direction column
      justify-content center
      align-items center
      width 60px
      height 50px
      .relay-icon {
        display block
        border-radius 50%
        width 30px
        height 30px
        background-color #ffffff
        margin-bottom 5px
      }
      .relay-title {
        display block
        font-size 13px
      }
    }
  }

.show-more {
  text-align: right;
  padding: 10px 20px 0 0;
}
/deep/ .el-checkbox {
  width 100%
  font-weight 300
  margin-right 0
  white-space normal
}
/deep/ .el-checkbox__label {
  width 100%
  padding-right 20px
  box-sizing border-box
}

/deep/ .el-popover {
  cursor pointer
  width 700px
  position fixed
  left 30vw
  /*right 0*/
  margin 0
  background-color #F7F7F7
  padding 0
  top 15vh
}
/deep/ .el-checkbox__inner {
  width 18px
  height 18px
  border-radius 50%
}
/deep/ .el-checkbox__inner::after {
  height 8px
  left 6px
  top 2px
}
/deep/ .el-checkbox__label {
  line-height normal
  margin -10px 0
  margin-left 10px
}
 /deep/ .el-checkbox__input {
   position absolute
   top 30px
   left -10px
 }
  .pop-header {
    /*display flex*/
    position relative
    /*justify-content space-between*/
    margin-bottom 10px
    border-bottom 1px solid #DEDEDE
    background-color #F3F3F3
    padding 8px 8px
    & img {
      display block
      width 22px
      height 22px
      cursor pointer
      position absolute
      top 8px
    }
    .title {
      display block
      text-align center
    }
    .pop-close {
      right 5px
    }
    .pop-back {
      left  5px
    }
  }

</style>
