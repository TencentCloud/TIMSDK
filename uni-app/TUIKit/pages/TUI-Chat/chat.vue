<template>
<view class="container">
<!--  <TUI-calling class="calling" id="tui-calling" @sendMessage="sendMessage"></TUI-calling>-->
  <view class="tui-chatroom-navigatorbar">
    <image class="tui-chatroom-navigatorbar-back" @tap="goBack" src="/static/static/assets/ic_back_white.svg"></image>
    <!-- 先查 remark；无 remark 查 (c2c)nick/(group)name；最后查 (c2c)userID/(group)groupID -->
    <view class="conversation-title">{{conversationName}}</view>
  </view>
  <view class="group-profile">
    <TUI-group-profile id="groip-profile" v-if="isShow" :conversation="conversation"></TUI-group-profile>
  </view>
  <view class="message-list" @tap="triggerClose">
    <TUI-message-list  ref="messageList" id="message-list" :conversation="conversation"></TUI-message-list>
  </view>
  <view class="container-box" v-if="videoPlay" @tap.stop="stopVideoHander">
    <video class="video-message" v-if="videoPlay"  :src="videoMessage.payload.videoUrl" :poster="videoMessage.payload.thumbUrl" object-fit="cover" error="videoError" autoplay="true" direction="0">
    </video>
  </view>
  <view class="message-input" v-if="showChat">
    <TUI-message-input ref="messageInput"  id="message-input" :conversation="conversation" @sendMessage="sendMessage"></TUI-message-input>
  </view>
</view>
</template>

<script>
import logger from '../../utils/logger';
import TUIMessageList from "../../components/tui-chat/message-list/index";
import TUIMessageInput from "../../components/tui-chat/message-input/index";
import TUIGroupProfile from "../../components/tui-group/group-profile/index";

export default {
  data() {
    return {
      conversationName: '',
      conversation: {},
      messageList: [],
      isShow: false,
      showChat: true,
      conversationID: '',
      videoPlay: false,
      videoMessage: {},
    };
  },

  components: {
    TUIMessageList,
    TUIMessageInput,
    TUIGroupProfile
  },
  props: {},
  created(){
    uni.$on('videoPlayerHandler',(value)=>{
      this.videoPlay = value.isPlay
      this.videoMessage = value.message
    })
  },

  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    // conversationID: C2C、 GROUP
    logger.log(` TUI-chat | onLoad | conversationID: ${options.conversationID}`);
    const {
      conversationID
    } = options;
    this.setData({
      conversationID
    });
    uni.$TUIKit.setMessageRead({
      conversationID
    }).then(() => {
      logger.log('TUI-chat | setMessageRead  | ok');
    });
    uni.$TUIKit.getConversationProfile(conversationID).then(res => {
      const {
        conversation
      } = res.data;
      this.conversation = conversation
      this.setData({
        conversationName: this.getConversationName(conversation),
        isShow: conversation.type === 'GROUP'
      });
    });
  },

  methods: {
    stopVideoHander() {
      this.videoPlay = false
    },
    getConversationName(conversation) {
      if (conversation.type === '@TIM#SYSTEM') {
        this.setData({
          showChat: false
        });
        return '系统通知';
      }

      if (conversation.type === 'C2C') {
        return conversation.remark || conversation.userProfile.nick || conversation.userProfile.userID;
      }

      if (conversation.type === 'GROUP') {
        return conversation.groupProfile.name || conversation.groupProfile.groupID;
      }
    },

    sendMessage(event) {
      // 将自己发送的消息写进消息列表里面
      this.$refs.messageList.updateMessageList(event.detail.message);
    },

    triggerClose() {
      if(this.showChat) {
        this.$refs.messageInput.handleClose();
      }
    },

    goBack() {
      const pages = getCurrentPages(); // 当前页面栈

      if (pages[pages.length - 2].route === 'pages/TUI-Conversation/create-conversation/create' || pages[pages.length - 2].route === 'pages/TUI-Group/create-group/create' || pages[pages.length - 2].route === 'pages/TUI-Group/join-group/join') {
        uni.navigateBack({
          delta: 2
        });
      } else {
        uni.navigateBack({
          delta: 1
        });
      }

      uni.$TUIKit.setMessageRead({
        conversationID: this.conversationID
      }).then(() => {});
    }

  }
};
</script>
<style>
@import "./chat.css";
</style>
