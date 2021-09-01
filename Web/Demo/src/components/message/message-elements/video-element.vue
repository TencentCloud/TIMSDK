<template>
  <message-bubble :isMine=isMine :message=message>
    <video
      :src="payload.videoUrl"
      controls
      class="video"
      @error="videoError"
    ></video>
    <el-progress
      v-if="showProgressBar"
      :percentage="percentage"
      :color="percentage => (percentage === 100 ? '#67c23a' : '#409eff')"
    />
  </message-bubble>
</template>

<script>
import MessageBubble from '../message-bubble'
import { Progress } from 'element-ui'
export default {
  name: 'VideoElement',
  components: {
    MessageBubble,
    ElProgress: Progress
  },
  props: {
    payload: {
      type: Object,
      required: true
    },
    message: {
      type: Object,
      required: true
    },
    isMine: {
      type: Boolean
    }
  },

  computed: {
    showProgressBar() {
      return this.message.status === 'unSend'
    },
    percentage() {
      return Math.floor((this.$parent.message.progress || 0) * 100)
    }
  },
  methods: {
    videoError(e) {
      this.$store.commit('showMessage', { type: 'error', message: '视频出错，错误原因：' + e.target.error.message })
    },
  }
}
</script>

<style lang="stylus" scoped>
.video
  width 100%
  max-height 300px
</style>
