<template>
  <div class="current-conversation-wrapper">
    <div class="current-conversation" @scroll="onScroll" v-if="showCurrentConversation">
      <div class="header">
        <span class="conversation-name text-ellipsis" style="max-width: 60%;">{{ name }}</span>
        <span
          class="el-icon-more show-more"
          @click="showMore"
          v-show="!currentConversation.conversationID.includes('SYSTEM')"
          title="查看详细"
        ></span>
      </div>
      <div class="content" :class="!showMessageSendBox ? 'full-height' : ''">
        <div class="message-list" ref="message-list" @scroll="this.onScroll">
          <el-button
            type="text"
            style="display:block;margin: 0 auto;"
            @click="$store.dispatch('getMessageList', currentConversation.conversationID)"
            >查看更多</el-button
          >
          <message-item v-for="message in currentMessageList" :key="message.ID" :message="message" />
        </div>
        <a v-show="isShowScrollButtomTips" class="newMessageTips" @click="scrollMessageListToButtom">↓回到最新位置↓</a>
      </div>
      <message-send-box v-if="showMessageSendBox" />
    </div>
    <conversation-profile v-if="showConversationProfile" />
    <image-previewer />
  </div>
</template>

<script>
import { mapGetters, mapState } from 'vuex'
import MessageSendBox from '../message/message-send-box'
import MessageItem from '../message/message-item'
import ConversationProfile from './conversation-profile.vue'
import ImagePreviewer from '../message/image-previewer'
export default {
  name: 'CurrentConversation',
  components: {
    MessageSendBox,
    MessageItem,
    ConversationProfile,
    ImagePreviewer
  },
  data() {
    return {
      isShowScrollButtomTips: false,
      preScrollHeight: 0,
      showConversationProfile: false
    }
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation,
      currentMessageList: state => state.conversation.currentMessageList
    }),
    ...mapGetters(['toAccount']),
    // 是否显示当前会话组件
    showCurrentConversation() {
      return !!this.currentConversation.conversationID
    },
    name() {
      if (this.currentConversation.type === 'C2C') {
        return this.currentConversation.userProfile.nick || this.toAccount
      } else if (this.currentConversation.type === 'GROUP') {
        return this.currentConversation.groupProfile.name || this.toAccount
      }
      return this.toAccount
    },
    showMessageSendBox() {
      return this.currentConversation.type !== this.TIM.TYPES.CONV_SYSTEM
    }
  },
  mounted() {
    this.$bus.$on('image-loaded', this.onImageLoaded)
    this.$bus.$on('scroll-bottom', this.scrollMessageListToButtom)
  },
  updated() {
    this.keepMessageListOnButtom()
  },

  methods: {
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

<style scoped>
/* 当前会话的骨架屏 */
.current-conversation-wrapper {
  display: flex;
  width: 100%;
  height: 100%;
  background-color: #eee;
  box-sizing: border-box;
  color: #000;
}
.current-conversation {
  width: 100%;
  min-width: 500px;
}
.el-row,
.el-col {
  height: 100%;
}
.header {
  position: relative;
  display: flex;
  align-items: center;
  justify-content: center;
  border-bottom: 1px solid #dddddd;
  height: 40px;
}
.content {
  display: flex;
  height: 70%;
  position: relative;
}
.message-list {
  width: 100%;
  overflow-y: scroll;
  padding-left: 12px;
}
.dropdown-menu {
  padding: 12px;
  max-width: 80%;
  color: #000;
}
.message-list {
  position: relative;
  width: 100%;
}
.show-more {
  position: absolute;
  right: 15px;
  color: gray;
  cursor: pointer;
}
.show-more:hover {
  color: black;
}
.full-height {
  height: 90%;
}
.newMessageTips {
  position: absolute;
  display: block;
  cursor: pointer;
  padding: 5px;
  width: 100px;
  margin: auto;
  left: 0;
  right: 0;
  bottom: 5px;
  font-size: 12px;
  text-align: center;
  border-radius: 10px;
  border: #ccc 1px solid;
  background-color: #fff;
  color: #268bf5;
}
</style>
