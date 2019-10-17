<template>
  <div>
    <div id="wrapper" v-if="!isLogin" >
      <login/>
    </div>
    <div
      class="loading"
      v-else
      v-loading="showLoading"
      element-loading-text="正在拼命初始化..."
      element-loading-background="rgba(0, 0, 0, 0.8)"
    >
      <div class="chat-wrapper">
        <el-row>
          <el-col :xs="10" :sm="10" :md="8" :lg="8" :xl="7">
            <side-bar />
          </el-col>
          <el-col :xs="14" :sm="14" :md="16" :lg="16" :xl="17">
            <current-conversation />
          </el-col>
        </el-row>
      </div>
      <image-previewer />
    </div>
    <div class="bg">
    </div>
  </div>

</template>

<script>
import { Notification } from 'element-ui'
import { mapState } from 'vuex'
import CurrentConversation from './components/conversation/current-conversation'
import SideBar from './components/layout/side-bar'
import Login from './components/user/login'
import ImagePreviewer from './components/message/image-previewer.vue'
import { translateGroupSystemNotice } from './utils/common'

export default {
  title: 'TIMSDK DEMO',
  components: {
    Login,
    SideBar,
    CurrentConversation,
    ImagePreviewer
  },

  computed: {
    ...mapState({
      currentUserProfile: state => state.user.currentUserProfile,
      currentConversation: state => state.conversation.currentConversation,
      isLogin: state => state.user.isLogin,
      isSDKReady: state => state.user.isSDKReady
    }),
    // 是否显示 Loading 状态
    showLoading() {
      return !this.isSDKReady
    }
  },

  mounted() {
    // 初始化监听器
    this.initListener()
  },

  methods: {
    initListener() {
      // 登录成功后会触发 SDK_READY 事件，该事件触发后，可正常使用 SDK 接口
      this.tim.on(this.TIM.EVENT.SDK_READY, this.onReadyStateUpdate, this)
      // SDK NOT READT
      this.tim.on(this.TIM.EVENT.SDK_NOT_READY, this.onReadyStateUpdate, this)
      // 被踢出
      this.tim.on(this.TIM.EVENT.KICKED_OUT, () => {
        this.$store.commit('showMessage', {
          message: '被踢出，请重新登录。',
          type: 'error'
        })
        this.$store.commit('toggleIsLogin', false)
        this.$store.commit('reset')
      })
      // SDK内部出错
      this.tim.on(this.TIM.EVENT.ERROR, this.onError)
      // 收到新消息
      this.tim.on(this.TIM.EVENT.MESSAGE_RECEIVED, this.onReceiveMessage)
      // 会话列表更新
      this.tim.on(this.TIM.EVENT.CONVERSATION_LIST_UPDATED, event => {
        this.$store.commit('updateConversationList', event.data)
      })
      // 群组列表更新
      this.tim.on(this.TIM.EVENT.GROUP_LIST_UPDATED, event => {
        this.$store.commit('updateGroupList', event.data)
      })
      // 收到新的群系统通知
      this.tim.on(this.TIM.EVENT.GROUP_SYSTEM_NOTICE_RECEIVED, event => {
        const isKickedout = event.data.type === 4
        const isCurrentConversation =
          `GROUP${event.data.message.payload.groupProfile.groupID}` === this.currentConversation.conversationID
        // 在当前会话被踢，需reset当前会话
        if (isKickedout && isCurrentConversation) {
          this.$store.commit('resetCurrentConversation')
        }
        Notification({
          title: '新系统通知',
          message: translateGroupSystemNotice(event.data.message),
          duration: 3000,
          onClick: () => {
            const SystemConversationID = '@TIM#SYSTEM'
            this.$store.dispatch('checkoutConversation', SystemConversationID)
          }
        })
      })
    },
    onReceiveMessage({ data: messageList }) {
      this.handleAt(messageList)
      this.$store.commit('pushCurrentMessageList', messageList)
    },
    onError({ data }) {
      if (data.message !== 'Network Error') {
        this.$store.commit('showMessage', {
          message: data.message,
          type: 'error'
        })
      }
    },
    onReadyStateUpdate({ name }) {
      const isSDKReady = name === this.TIM.EVENT.SDK_READY ? true : false
      this.$store.commit('toggleIsSDKReady', isSDKReady)

      if (isSDKReady) {
        this.tim.getMyProfile().then(({ data }) => {
          this.$store.commit('updateCurrentUserProfile', data)
        })
        this.$store.dispatch('getBlacklist')
      }
    },
    /**
     * 处理 @ 我的消息
     * @param {Message[]} messageList
     */
    handleAt(messageList) {
      // 筛选有 @ 符号的文本消息
      const atTextMessageList = messageList.filter(
        message => message.type === this.TIM.TYPES.MSG_TEXT && message.payload.text.includes('@')
      )
      for (let i = 0; i < atTextMessageList.length; i++) {
        const message = atTextMessageList[i]
        const matched = message.payload.text.match(/@\w+/g)
        if (!matched) {
          continue
        }
        // @ 我的
        if (matched.includes(`@${this.currentUserProfile.userID}`)) {
          // 当前页面不可见时，调用window.Notification接口，系统级别通知。
          if (document.hidden) {
            this.notifyMe(message)
          }
          Notification({
            title: `有人在群${message.conversationID.slice(5)}提到了你`,
            message: message.payload.text,
            duration: 3000
          })
          this.$bus.$emit('new-messsage-at-me', {
            data: { conversationID: message.conversationID }
          })
        }
      }
    },
    /**
     * 使用 window.Notification 进行全局的系统通知
     * @param {Message} message
     */
    notifyMe(message) {
      // 需检测浏览器支持和用户授权
      if (!('Notification' in window)) {
        return
      } else if (window.Notification.permission === 'granted') {
        this.handleNotify(message)
      } else if (window.Notification.permission !== 'denied') {
        window.Notification.requestPermission().then(permission => {
          // 如果用户同意，就可以向他们发送通知
          if (permission === 'granted') {
            this.handleNotify(message)
          }
        })
      }
    },
    handleNotify(message) {
      const notification = new window.Notification('有人提到了你', {
        body: message.payload.text
      })
      notification.onclick = () => {
        window.focus()
        this.$store.dispatch('checkoutConversation', message.conversationID)
        notification.close()
      }
    }
  }
}
</script>

<style lang="stylus">
body
  overflow hidden
  margin 0
  font-family "Microsoft YaHei","微软雅黑","MicrosoftJhengHei","Lantinghei SC", "Open Sans", Arial, "Hiragino Sans GB", "STHeiti", "WenQuanYi Micro Hei", SimSun, sans-serif
  // font-family  "Helvetica Neue", Helvetica, Arial, "PingFang SC", "Hiragino Sans GB", "Heiti SC", "Microsoft YaHei", "WenQuanYi Micro Hei", sans-serif
  // text-shadow: $regular 0 0 0.05em
  background-color $bg
  -ms-scroll-chaining: chained;
  -ms-overflow-style: none;
  -ms-content-zooming: zoom;
  -ms-scroll-rails: none;
  -ms-content-zoom-limit-min: 100%;
  -ms-content-zoom-limit-max: 500%;
  -ms-scroll-snap-type: proximity;
  -ms-scroll-snap-points-x: snapList(100%, 200%, 300%, 400%, 500%);
  -ms-overflow-style: none;
  overflow: auto;

  div
    box-sizing border-box
    &::before
    &::after
      box-sizing border-box

#wrapper {
  display: flex;
  justify-content: center;
  padding-top: 100px;
}
// TODO filter mac chrome 会有问题，下次修改可以去掉
.bg
  position absolute
  width: 100%;
  height: 100%;
  top: 0;
  left: 0;
  z-index: -1;
  background url('~@/./assets/image/bg.jpg') no-repeat 0 0
  background-size cover
  // filter blur(67px)

.loading {
  height: 100vh;
  width: 100vw;
  display: flex;
  justify-content: center;
}

.text-ellipsis {
  overflow: hidden;
  text-overflow: ellipsis;
  white-space: nowrap;
}

.chat-wrapper
  margin-top: 8vh
  width $width
  height $height
  max-width 1280px
  box-shadow 0 11px 20px 0 rgba(0, 0, 0, .3)

/* 设置滚动条的样式 */
::-webkit-scrollbar {
  width: 3px;
  height: 3px;
}
/* 滚动槽 */
::-webkit-scrollbar-track {
  border-radius: 10px;
}
/* 滚动条滑块 */
::-webkit-scrollbar-thumb {
  border-radius: 10px;
  background: rgba(0, 0, 0, 0.1);
}
</style>
