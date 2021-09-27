<template>
    <div class="chat-bubble" @mousedown.stop @contextmenu.prevent>
        <div class="conversation-container">
            <ConversationSelectedList   @getList="getList"></ConversationSelectedList>
            <div class="conversation-list-btn">
                <span class="conversation-btn" @click="cancel">取消</span>
                <span class="conversation-btn" @click="messageRelay">发送</span>
            </div>
        </div>
    </div>
</template>

<script>
  import { mapState } from 'vuex'
  import ConversationSelectedList from '../../conversation/conversation-selected-list'

  export default {
    name: 'MessageBubble',
    components: {
      ConversationSelectedList
    },
    data() {
      return {
        isTimeout: false,
        showConversationList: false,
        selectedConversation: [],
        testMergerMessage: {}
      }
    },
    created() {
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
    updated() {
    },
    computed: {
      ...mapState({
        isShowConversationList: state => state.conversation.isShowConversationList,
        selectedMessageList: state => state.conversation.selectedMessageList,
        relayType: state => state.conversation.relayType,
        relayMessage: state => state.conversation.relayMessage
      }),
    },
    methods: {
      cancel() {
        this.$store.commit('showConversationList', false)
      },
      getList(value) {
        this.selectedConversation = value

      },
      sendSingleMessage(to, type, message) {
        const _message = this.tim.createForwardMessage({
          to: to,
          conversationType: type,
          payload: message,
          priority: this.TIM.TYPES.MSG_PRIORITY_NORMAL
        })
        this.$store.commit('pushCurrentMessageList', _message)   // ??
        return _message
      },
      mergerSort() {
        this.selectedMessageList.sort((a, b) =>  {
          if(a.time !== b.time) {
            return a.time - b.time
          }else {
            return a.sequence - b.sequence
          }
        })
      },
      mergerMessage(to, type) {
        let _abstractList = [], _count = 0, _title = ''
        _count = this.selectedMessageList.length < 3 ? this.selectedMessageList.length : 3

        for(let i = 0; i < _count; i++) {
          _abstractList.push(this.setAbstractList(this.selectedMessageList[i]))
        }
        _title = this.selectedMessageList[0].conversationType === 'GROUP' ? '群聊的聊天记录' : `${this.selectedMessageList[0].nick || this.selectedMessageList[0].from} 和 ${this.selectedMessageList[0].to} 的聊天记录`
        let message = this.tim.createMergerMessage({
          to: to,
          conversationType: type,
          payload: {
            messageList: this.selectedMessageList ,
            title: _title,
            abstractList: _abstractList,
            compatibleText: '请升级IMSDK到v2.10.1或更高版本查看此消息'
          }
        })
        this.$store.commit('pushCurrentMessageList', message)   // ??
        return message
      },
      async messageRelay() {
        let _type = '', _to = ''
        for (let item of this.selectedConversation) {
          if(item.indexOf(this.TIM.TYPES.CONV_C2C) !== -1) {
            _type = this.TIM.TYPES.CONV_C2C
            _to = item.substring(3, item.length)
          }
          if(item.indexOf(this.TIM.TYPES.CONV_GROUP) !== -1) {
            _type = this.TIM.TYPES.CONV_GROUP
            _to = item.substring(5, item.length)
          }
          // 排序
          this.mergerSort()
          if (this.relayType === 1) {
            let message = this.sendSingleMessage(_to, _type, this.relayMessage)
            this.sendMessageHandler(message)
          }

          if (this.relayType === 2) {
            if(this.selectedMessageList.length > 30) {
              this.$store.commit('showMessage', {
                message: '转发消息仅支持30条以内',
                type: 'error'
              })
              return
            }
            for (let selectedMessage of this.selectedMessageList) {
              let message = await this.sendSingleMessage(_to, _type, selectedMessage)
              await this.tim.sendMessage(message)
                .then((res) => {
                  return res
                })
                .catch(imError => {
                  this.$store.commit('showMessage', {
                    message: imError.message,
                    type: 'error'
                  })
                })

            }
          }
          if (this.relayType === 3) {
            let message = this.mergerMessage(_to, _type)
            this.sendMessageHandler(message)
          }
        }
        this.$store.commit('showConversationList', false)
        this.$store.commit('resetSelectedMessage', false)
      },

      sendMessageHandler(message) {
        this.tim.sendMessage(message).catch(imError => {
            this.$store.commit('showMessage', {
              message: imError.message,
              type: 'error'
            })
          })
      },
      setAbstractList(message) {
        let nick = message.nick || message.from
        let text = ''
        switch (message.type) {
          case this.TIM.TYPES.MSG_TEXT:
            text = message.payload.text || ''
            if (text.length > 20) {
              text = text.slice(0, 20)
            }
            return `${nick}: ${text}`
          case this.TIM.TYPES.MSG_MERGER:
            return `${nick}: [聊天记录]`
          case this.TIM.TYPES.MSG_IMAGE:
            return `${nick}: [图片]`
          case this.TIM.TYPES.MSG_AUDIO:
            return `${nick}: [音频]`
          case this.TIM.TYPES.MSG_VIDEO:
            return `${nick}: [视频]`
          case this.TIM.TYPES.MSG_CUSTOM:
            return `${nick}: [自定义消息]`
          case this.TIM.TYPES.MSG_FILE:
            return `${nick}: [文件]`
          case this.TIM.TYPES.MSG_FACE:
            return `${nick}: [动画表情]`
        }
      },
      handleDropDownMousedown(e) {
        if (e.buttons === 2) {
          if (this.$refs.dropdown.visible) {
            this.$refs.dropdown.hide()
          } else {
            this.$refs.dropdown.show()
          }
        }
      }
    }
  }
</script>

<style lang="stylus" scoped>
    .conversation-container {
        position absolute
        top 0
        left 0
        right 0
        width 80%
        margin auto
        background-color #fff
        z-index 999
    }
    .conversation-list-btn {
        width 140px
        display flex
        float right
        margin 10px 0
        .conversation-btn {
            cursor pointer
            padding 6px 12px
            background #00A4FF
            color #ffffff
            font-size 14px
            border-radius 20px
            margin-left 13px
        }
    }
</style>
