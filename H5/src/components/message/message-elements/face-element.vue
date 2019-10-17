<template>
<message-bubble :isMine=isMine>
  <div class="face-element-wrapper">
    <img :src="url"/>
  </div>
</message-bubble>
</template>

<script>
import MessageBubble from '../message-bubble'
export default {
  name: 'FaceElement',
  props: {
    payload: {
      type: Object,
      required: true
    },
    isMine: {
      type: Boolean
    }
  },
  components: {
    MessageBubble,
  },
  computed:{
    url() {
      return `https://imgcache.qq.com/open/qcloud/tim/assets/face-elem/${this.payload.data}.png`
    }
  }
}
</script>

<style lang="stylus" scoped>
.face-element-wrapper
  img
    max-width 90px
</style>
