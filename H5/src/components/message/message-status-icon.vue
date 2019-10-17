<template>
  <span
    style="width:16px;height:16px;"
    :class="messageIconClass"
    @click="handleIconClick"
  >{{messageIconClass==='message-send-fail'? '!':''}}</span>
</template>

<script>
export default {
  name: 'MessageStatusIcon',
  props: {
    message: {
      type: Object,
      required: true
    }
  },
  computed: {
    messageIconClass() {
      switch (this.message.status) {
        case 'unSend':
          return 'el-icon-loading'
        case 'fail':
          return 'message-send-fail'
        default:
          return ''
      }
    }
  },
  methods: {
    handleIconClick() {
      if (this.messageIconClass === 'message-send-fail') {
        this.tim.resendMessage(this.message).catch(imError => {
          this.$store.commit('showMessage', {
            message: imError.message,
            type: 'error'
          })
        })
      }
    }
  }
}
</script>

<style lang="stylus" scoped>
.message-send-fail {
  background-color: red;
  color: $white;
  border-radius: 50%;
  text-align: center;
  line-height: 16px;
  cursor: pointer;
}
</style>
