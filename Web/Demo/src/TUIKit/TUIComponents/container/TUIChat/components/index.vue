<template>
  <MessageBubble :message="message">
    <MessageText v-if="message.type === types.MSG_TEXT" :data="handleTextMessageShowContext(message)" />
    <MessageImage  v-if="message.type === types.MSG_IMAGE" :data="handleImageMessageShowContext(message)" />
    <MessageVideo  v-if="message.type === types.MSG_VIDEO" :data="handleVideoMessageShowContext(message)" />
    <MessageAudio  v-if="message.type === types.MSG_AUDIO" :data="handleAudioMessageShowContext(message)" />
    <MessageFile   v-if="message.type === types.MSG_FILE" :data="handleFileMessageShowContext(message)" />
    <MessageFace   v-if="message.type === types.MSG_FACE" :data="handleFaceMessageShowContext(message)" />
    <MessageLocation   v-if="message.type === types.MSG_LOCATION" :data="handleLocationMessageShowContext(message)" />
    <MessageCustom  v-if="message.type === types.MSG_CUSTOM" :data="handleCustomMessageShowContext(message)" />
    <MessageMerger   v-if="message.type === types.MSG_MERGER" :data="handleMergerMessageShowContext(message)" />
    <MessageTip v-if="message.type === types.MSG_GRP_TIP" :data="handleTipMessageShowContext(message)" />
  </MessageBubble>
</template>

<script lang="ts">
import { defineComponent, watchEffect, reactive, toRefs } from 'vue';
import MessageBubble from './message-bubble.vue';
import MessageText from './message-text.vue';
import MessageImage from './message-image.vue';
import MessageVideo from './message-video.vue';
import MessageAudio from './message-audio.vue';
import MessageFile from './message-file.vue';
import MessageFace from './message-face.vue';
import MessageLocation from './message-location.vue';
import MessageMerger from './message-merger.vue';
import MessageCustom from './message-custom.vue';
import messageTip from './message-tip.vue';

import {
  handleTextMessageShowContext,
  handleImageMessageShowContext,
  handleVideoMessageShowContext,
  handleAudioMessageShowContext,
  handleFileMessageShowContext,
  handleFaceMessageShowContext,
  handleLocationMessageShowContext,
  handleMergerMessageShowContext,
  handleTipMessageShowContext,
  handleCustomMessageShowContext,
} from '../utils/utils';

export default defineComponent({
  components: {
    MessageBubble,
    MessageText,
    MessageImage,
    MessageVideo,
    MessageAudio,
    MessageFile,
    MessageFace,
    MessageLocation,
    MessageMerger,
    MessageCustom,
    messageTip,
  },
  props: {
    message: {
      type: Object,
      default: () => ({}),
    },
    types: {
      type: Object,
      default: () => ({}),
    },
  },
  setup(props:any, ctx:any) {
    let data = reactive({
      message: {},
      types: {},
    });

    watchEffect(() => {
      data = { ...data, ...props };
    });

    return {
      ...toRefs(data),
      handleTextMessageShowContext,
      handleImageMessageShowContext,
      handleVideoMessageShowContext,
      handleAudioMessageShowContext,
      handleFileMessageShowContext,
      handleFaceMessageShowContext,
      handleLocationMessageShowContext,
      handleMergerMessageShowContext,
      handleTipMessageShowContext,
      handleCustomMessageShowContext,
    };
  },
});
</script>
<style lang="scss" scoped>

</style>
