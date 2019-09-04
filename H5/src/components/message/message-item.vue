<template>
  <div class="message-wrapper" :class="messagePosition">
    <message-header v-if="showMessageHeader" :message="message" />
    <div class="content">
      <message-status-icon :message="message" />
      <text-element
        v-if="message.type === TIM.TYPES.MSG_TEXT"
        :isMine="isMine"
        :payload="message.payload"
      />
      <image-element v-else-if="message.type === TIM.TYPES.MSG_IMAGE" :payload="message.payload" />
      <file-element v-else-if="message.type === TIM.TYPES.MSG_FILE" :payload="message.payload" />
      <sound-element v-else-if="message.type === TIM.TYPES.MSG_SOUND" :payload="message.payload" />
      <group-tip-element v-else-if="message.type===TIM.TYPES.MSG_GRP_TIP" :payload="message.payload" />
      <group-system-notice-element
        v-else-if="message.type === TIM.TYPES.MSG_GRP_SYS_NOTICE"
        :payload="message.payload"
        :message="message"
      />
      <custom-element v-else-if="message.type === TIM.TYPES.MSG_CUSTOM" :payload="message.payload" />
      <face-element v-else-if="message.type === TIM.TYPES.MSG_FACE" :payload="message.payload"/>
      <span v-else>暂未支持的消息类型：{{message.type}}</span>
    </div>
  </div>
</template>

<script>
import { mapState } from 'vuex'
import MessageStatusIcon from './message-status-icon.vue'
import MessageHeader from './message-header'
import FileElement from './message-elements/file-element.vue'
import FaceElement from './message-elements/face-element.vue'
import ImageElement from './message-elements/image-element.vue'
import TextElement from './message-elements/text-element.vue'
import SoundElement from './message-elements/sound-element.vue'
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
    MessageStatusIcon,
    FileElement,
    FaceElement,
    ImageElement,
    TextElement,
    SoundElement,
    GroupTipElement,
    GroupSystemNoticeElement,
    CustomElement,
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
    isMine() {
      return this.message.flow === 'out'
    },
    messagePosition() {
      if (
        ['TIMGroupTipElem', 'TIMGroupSystemNoticeElem'].includes(
          this.message.elements[0].type
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
          this.message.elements[0].type
        )
      ) {
        return false
      }
      return true
    },
  }
}
</script>

<style scoped>
.message-wrapper {
  display: flex;
  flex-direction: column;
  margin: 12px 0;
}
.position-left {
  align-items: flex-start;
}
.position-right {
  align-items: flex-end;
}
.position-center {
  align-items: center;
}
.content{
  display: flex;
  align-items: center;
}
</style>
