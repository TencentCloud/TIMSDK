<template>
  <div class="message-wrapper" :class="messagePosition">
    <div
      v-if="currentConversationType === TIM.TYPES.CONV_C2C"
      class="c2c-layout"
      :class="messagePosition"
    >
      <div class="col-1" v-if="showAvatar">
        <!-- 头像 -->
        <avatar :src="avatar" />
      </div>
      <div class="col-2">
        <!-- 消息主体 -->
        <div class="content-wrapper">
          <message-status-icon v-if="isMine" :message="message" />
          <text-element
            v-if="message.type === TIM.TYPES.MSG_TEXT"
            :isMine="isMine"
            :payload="message.payload"
          />
          <image-element
            v-else-if="message.type === TIM.TYPES.MSG_IMAGE"
            :isMine="isMine"
            :payload="message.payload"
          />
          <file-element
            v-else-if="message.type === TIM.TYPES.MSG_FILE"
            :isMine="isMine"
            :payload="message.payload"
          />
          <sound-element
            v-else-if="message.type === TIM.TYPES.MSG_SOUND"
            :isMine="isMine"
            :payload="message.payload"
          />
          <group-tip-element
            v-else-if="message.type===TIM.TYPES.MSG_GRP_TIP"
            :payload="message.payload"
          />
          <group-system-notice-element
            v-else-if="message.type === TIM.TYPES.MSG_GRP_SYS_NOTICE"
            :payload="message.payload"
            :message="message"
          />
          <custom-element
            v-else-if="message.type === TIM.TYPES.MSG_CUSTOM"
            :isMine="isMine"
            :payload="message.payload"
          />
          <face-element
            v-else-if="message.type === TIM.TYPES.MSG_FACE"
            :isMine="isMine"
            :payload="message.payload"
          />
          <video-element
            v-else-if="message.type === TIM.TYPES.MSG_VIDEO"
            :isMine="isMine"
            :payload="message.payload"
          />
          <span v-else>暂未支持的消息类型：{{message.type}}</span>
        </div>
        <message-footer v-if="showMessageHeader" :message="message" />
      </div>
      <div class="col-3">
        <!-- 消息状态 -->
      </div>
    </div>

    <div
      v-if="currentConversationType === TIM.TYPES.CONV_GROUP"
      class="group-layout"
      :class="messagePosition"
    >
      <!-- 头像 群组没有获取单个头像的接口，暂时无法显示头像-->
      <div class="col-1" v-if="showAvatar">
        <avatar :src="avatar" />
      </div>
      <div class="col-2">
        <!-- 消息主体 -->
        <message-header v-if="showMessageHeader" :message="message" />
        <div class="content-wrapper">
          <message-status-icon v-if="isMine" :message="message" />
          <text-element
            v-if="message.type === TIM.TYPES.MSG_TEXT"
            :isMine="isMine"
            :payload="message.payload"
          />
          <image-element
            v-else-if="message.type === TIM.TYPES.MSG_IMAGE"
            :isMine="isMine"
            :payload="message.payload"
          />
          <file-element
            v-else-if="message.type === TIM.TYPES.MSG_FILE"
            :isMine="isMine"
            :payload="message.payload"
          />
          <sound-element
            v-else-if="message.type === TIM.TYPES.MSG_SOUND"
            :isMine="isMine"
            :payload="message.payload"
          />
          <group-tip-element
            v-else-if="message.type===TIM.TYPES.MSG_GRP_TIP"
            :isMine="isMine"
            :payload="message.payload"
          />
          <custom-element
            v-else-if="message.type === TIM.TYPES.MSG_CUSTOM"
            :isMine="isMine"
            :payload="message.payload"
          />
          <face-element
            v-else-if="message.type === TIM.TYPES.MSG_FACE"
            :isMine="isMine"
            :payload="message.payload"
          />
          <video-element
            v-else-if="message.type === TIM.TYPES.MSG_VIDEO"
            :isMine="isMine"
            :payload="message.payload"
          />
          <span v-else>暂未支持的消息类型：{{message.type}}</span>
        </div>
      </div>
      <div class="col-3">
        <!-- 消息状态 -->
      </div>
    </div>

    <div class="system-layout" v-if="currentConversationType === TIM.TYPES.CONV_SYSTEM ">
      <div class="col-1">
        <avatar :src="avatar" :type="currentConversationType" />
      </div>
      <div class="col-2">
        <message-header :message="message" />
        <group-system-notice-element :payload="message.payload" :message="message" />
      </div>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import MessageStatusIcon from './message-status-icon.vue'
import MessageHeader from './message-header'
import MessageFooter from './message-footer'
import FileElement from './message-elements/file-element.vue'
import FaceElement from './message-elements/face-element.vue'
import ImageElement from './message-elements/image-element.vue'
import TextElement from './message-elements/text-element.vue'
import SoundElement from './message-elements/sound-element.vue'
import VideoElement from './message-elements/video-element.vue'
import GroupTipElement from './message-elements/group-tip-element.vue'
import GroupSystemNoticeElement from './message-elements/group-system-notice-element.vue'
import CustomElement from './message-elements/custom-element.vue'
export default {
  name: 'MessageItem',
  props: {
    message: {
      type: Object,
      required: true
    }
  },
  components: {
    MessageHeader,
    MessageFooter,
    MessageStatusIcon,
    FileElement,
    FaceElement,
    ImageElement,
    TextElement,
    SoundElement,
    GroupTipElement,
    GroupSystemNoticeElement,
    CustomElement,
    VideoElement
  },
  data() {
    return {
      renderDom: []
    }
  },
  computed: {
    ...mapState({
      currentConversation: state => state.conversation.currentConversation,
      currentUserProfile: state => state.user.currentUserProfile
    }),
    // 是否显示头像，群提示消息不显示头像
    showAvatar() {
      if (this.currentConversation.type === 'C2C') {
        return true
      } else if (this.currentConversation.type === 'GROUP') {
        return this.message.type !== this.TIM.TYPES.MSG_GRP_TIP
      }
      return false
    },
    avatar() {
      if (this.currentConversation.type === 'C2C') {
        return this.isMine
          ? this.currentUserProfile.avatar
          : this.currentConversation.userProfile.avatar
      } else if (this.currentConversation.type === 'GROUP') {
        return this.isMine
          ? this.currentUserProfile.avatar
          : this.message.avatar
      } else {
        return ''
      }
    },
    currentConversationType() {
      return this.currentConversation.type
    },
    isMine() {
      // console.log(this.currentUserProfile, this.currentConversation);
      return this.message.flow === 'out'
    },
    messagePosition() {
      if (
        ['TIMGroupTipElem', 'TIMGroupSystemNoticeElem'].includes(
          this.message.type
        )
      ) {
        return 'position-center'
      }
      if (this.isMine) {
        return 'position-right'
      } else {
        return 'position-left'
      }
    },
    showMessageHeader() {
      if (
        ['TIMGroupTipElem', 'TIMGroupSystemNoticeElem'].includes(
          this.message.type
        )
      ) {
        return false
      }
      return true
    }
  }
}
</script>

<style lang="stylus" scoped>
.message-wrapper {
  margin: 20px 0;
  .content-wrapper {
    display: flex;
    align-items: center;
  }
}

.group-layout, .c2c-layout, .system-layout {
  display: flex;

  .col-1 {
    .avatar {
      width: 56px;
      height: 56px;
      border-radius: 50%;
      box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
    }
  }

  .col-2 {
    display: flex;
    flex-direction: column;
    // max-width 50% // 此设置可以自适应宽度，目前由bubble限制
  }

  .col-3 {
    width: 30px;
  }

  &.position-left {
    .col-2 {
      align-items: flex-start;
    }
  }

  &.position-right {
    flex-direction: row-reverse;

    .col-2 {
      align-items: flex-end;
    }
  }

  &.position-center {
    justify-content: center;
  }
}

.c2c-layout {
  .col-2 {
    .base {
      margin-top: 3px;
    }
  }
}

.group-layout {
  .col-2 {
    .chat-bubble {
      margin-top: 5px;
    }
  }
}
</style>
