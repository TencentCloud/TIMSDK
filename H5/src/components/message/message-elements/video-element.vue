<template>
  <message-bubble :isMine=isMine>
    <video
      :src="payload.videoUrl"
      :poster="payload.thumbUrl"
      controls
      class="video"
      @error="videoError"
    ></video>
  </message-bubble>
</template>

<script>
import MessageBubble from '../message-bubble'
export default {
  name: 'VideoElement',
  components: {
    MessageBubble
  },
  props: {
    payload: {
      type: Object,
      required: true
    },
    isMine: {
      type: Boolean
    }
  },
  methods: {
    videoError(e) {
      this.$message.error('视频出错，错误原因：' + e.target.error.message)
    }
  }
}
</script>

<style lang="stylus" scoped>
.video
  width 100%
  max-height 300px
</style>
