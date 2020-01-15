<template>
  <div class="chat-bubble" @mousedown.stop @contextmenu.prevent>
    <el-dropdown trigger="" ref="dropdown" v-if="!message.isRevoked" @command="handleCommand">
      <div class="message-content" :class="bubbleStyle">
        <slot></slot>
      </div>
      <el-dropdown-menu slot="dropdown">
        <el-dropdown-item command="revoke" v-if="isMine">撤回</el-dropdown-item>
        <!-- <el-dropdown-item command="delete">删除</el-dropdown-item> -->
      </el-dropdown-menu>
    </el-dropdown>

    <div class="group-tip-element-wrapper" v-if="message.isRevoked">
      {{text}}
      <el-button type="text" size="mini" class="edit-button" v-show="isEdit" @click="reEdit">&nbsp;重新编辑</el-button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MessageBubble',
  data() {
    return {
      isTimeout: false
    }
  },
  props: {
    isMine: {
      type: Boolean
    },
    isNew: {
      type: Boolean
    },
    message: {
      type: Object,
      required: true
    }
  },
  created() {
    this.isTimeoutHandler()
  },
  mounted() {
    if (this.$refs.dropdown && this.$refs.dropdown.$el) {
      this.$refs.dropdown.$el.addEventListener('mousedown', this.handleDropDownMousedown)
    }
  },
  beforeDestroy() {
    if (this.$refs.dropdown && this.$refs.dropdown.$el) {
      this.$refs.dropdown.$el.removeEventListener('mousedown', this.handleDropDownMousedown)
    }
  },
  computed: {
    bubbleStyle() {
      let classString = ''
      if (this.isMine) {
        classString += 'message-send'
      } else {
        classString += 'message-received'
      }
      if (this.isNew) {
        classString += 'new'
      }
      return classString
    },
    text() {
      if (this.message.conversationType === 'C2C' && !this.isMine) {
        return '对方撤回了一条消息'
      }
      if (this.message.conversationType === 'GROUP' && !this.isMine) {
        return `${this.message.from}撤回了一条消息`
      }
      return '你撤回了一条消息'
    },
    isEdit() {
      if (!this.isMine) {
        return false
      }
      if (this.message.type !== this.TIM.TYPES.MSG_TEXT) {
        return false
      }
      if (this.isTimeout) {
        return false
      }
      return true
    },
  },
  methods: {
    handleDropDownMousedown(e) {
      if (!this.isMine || this.isTimeout) {
        return
      }
      if (e.buttons === 2) {
        if (this.$refs.dropdown.visible) {
          this.$refs.dropdown.hide()
        } else {
          this.$refs.dropdown.show()
        }
      }
    },
    handleCommand(command) {
      switch (command) {
        case 'revoke':
          this.tim.revokeMessage(this.message).then(() => {
            this.isTimeoutHandler()
          }).catch((err) => {
            this.$store.commit('showMessage', {
              message: err,
              type: 'warning'
            })
          })
          break
        case 'delete':
          break
        default:
          break
      }
    },
    isTimeoutHandler() { // 从发送消息时间开始算起，两分钟内可以编辑
      let now = new Date()
      if (parseInt(now.getTime() / 1000) - this.message.time > 2 * 60) {
        this.isTimeout = true
        return
      }
      setTimeout(this.isTimeoutHandler, 1000)
    },
    reEdit() {
      this.$bus.$emit('reEditMessage', this.message.payload.text)
    }
  }
}
</script>

<style lang="stylus" scoped>
.chat-bubble
  position relative
  .message-content
    outline: none
    font-size 14px
    position relative
    max-width 350px
    word-wrap break-word
    word-break break-all
    padding 10px
    box-shadow: 0 5px 10px 0 rgba(0,0,0,.1);
    span
      white-space pre-wrap
      margin 0
      text-shadow $regular 0 0 0.05em
    img
      vertical-align bottom
    &::before
      position: absolute
      top: 0
      width: 12px
      height: 40px
      content "\e900"
      // content "\e906"
      font-family 'tim' !important
      font-size 24px // 32px 在mac上会模糊 24px正常 , window 24px模糊 28px 32px正常  36px windows mac 基本一致，但是太大
  .message-received
    background-color $white
    margin-left 15px
    border-radius 0 4px 4px 4px
    &::before
      left -10px
      transform scaleX(-1)
      color $white
    &.new
      transform: scale(0);
      transform-origin: top left;
      animation: bounce 500ms linear both;
  .message-send
    background-color $light-primary
    margin-right 15px
    border-radius 4px 0 4px 4px
    color $white
    &::before
      right: -10px
      color $light-primary
    &.new
      transform: scale(0);
      transform-origin: top right;
      animation: bounce 500ms linear both;
  .el-dropdown {
    vertical-align: top;
  }
  .el-dropdown + .el-dropdown {
    margin-left: 15px;
  }
  .el-icon-arrow-down {
    font-size: 12px;
  }
.group-tip-element-wrapper
  background $white
  padding 4px 15px
  border-radius 3px
  color $secondary
  font-size 12px
  // text-shadow $secondary 0 0 0.05em
.edit-button
  padding-top 4px
  height 20px
  font-size 10px
@keyframes bounce { 
  0% { transform: matrix3d(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  4.7% { transform: matrix3d(0.45, 0, 0, 0, 0, 0.45, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  9.41% { transform: matrix3d(0.883, 0, 0, 0, 0, 0.883, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  14.11% { transform: matrix3d(1.141, 0, 0, 0, 0, 1.141, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  18.72% { transform: matrix3d(1.212, 0, 0, 0, 0, 1.212, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  24.32% { transform: matrix3d(1.151, 0, 0, 0, 0, 1.151, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  29.93% { transform: matrix3d(1.048, 0, 0, 0, 0, 1.048, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  35.54% { transform: matrix3d(0.979, 0, 0, 0, 0, 0.979, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  41.04% { transform: matrix3d(0.961, 0, 0, 0, 0, 0.961, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  52.15% { transform: matrix3d(0.991, 0, 0, 0, 0, 0.991, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  63.26% { transform: matrix3d(1.007, 0, 0, 0, 0, 1.007, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  85.49% { transform: matrix3d(0.999, 0, 0, 0, 0, 0.999, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); }
  100% { transform: matrix3d(1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1); } 
}
</style>
