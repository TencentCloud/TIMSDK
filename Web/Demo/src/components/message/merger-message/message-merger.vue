<template>
    <div class="merger-conversation-wrapper">
        <div class="current-conversation" @scroll="onScroll">
            <div class="content">
                <div class="message-list" ref="message-list" @scroll="this.onScroll">
                    <div   v-for="(messageItem, index) in mergerList(mergerMessage)" :key="index">
                        <div class="message-item">
                            <div class="avatar-box">
                                <avatar class="group-member-avatar" :src="messageItem.avatar"/>
                            </div>
                            <div class="container-box">
                                <div class="nick-date">
                                    <div class="name text-ellipsis">{{messageItem.nick || messageItem.from || '小晨曦'}}</div>
                                    <div class="date">{{ getDate(messageItem.time) }}</div>
                                </div>
                                <merger-message-item v-for="(item,index) in messageItem.messageBody" :key="index" :message="item" :payload="item.payload"/>
                            </div>
                        </div>
                        <el-divider></el-divider>
                    </div>
                </div>
            </div>
        </div>
    </div>
</template>

<script>
  import {  mapState } from 'vuex'
  import MergerMessageItem from './mergerMessage-item'
  import { getFullDate } from '../../../utils/date'
  export default {
    name: 'CurrentConversation',
    components: {
      MergerMessageItem,
    },
    data() {
      return {
        preScrollHeight: 0,
        mergerMessageList: [],
        showMessage: null,

      }
    },
    computed: {
      ...mapState({
        currentConversation: state => state.conversation.currentConversation,
        mergerMessage: state => state.conversation.mergerMessage
      }),
      mergerList() {
        return function(message) {
          return message.payload.messageList
        }
      }
    },
    created () {
    },
    mounted() {

    },
    updated() {

    },
    watch: {

    },
    methods: {
      getDate(time) {
        return getFullDate(new Date(time * 1000))
      },
      onScroll({ target: { scrollTop } }) {
        let messageListNode = this.$refs['message-list']
        if (!messageListNode) {
          return
        }
        if (this.preScrollHeight - messageListNode.clientHeight - scrollTop < 20) {
          this.isShowScrollButtomTips = false
        }
      },
      // 如果滚到底部就保持在底部，否则提示是否要滚到底部
      keepMessageListOnButtom() {
        let messageListNode = this.$refs['message-list']
        if (!messageListNode) {
          return
        }
        // 距离底部20px内强制滚到底部,否则提示有新消息
        if (this.preScrollHeight - messageListNode.clientHeight - messageListNode.scrollTop < 20) {
          this.$nextTick(() => {
            messageListNode.scrollTop = messageListNode.scrollHeight
          })
          this.isShowScrollButtomTips = false
        } else {
          this.isShowScrollButtomTips = true
        }
        this.preScrollHeight = messageListNode.scrollHeight
      },
      // 直接滚到底部
      scrollMessageListToButtom() {
        this.$nextTick(() => {
          let messageListNode = this.$refs['message-list']
          if (!messageListNode) {
            return
          }
          messageListNode.scrollTop = messageListNode.scrollHeight
          this.preScrollHeight = messageListNode.scrollHeight
          this.isShowScrollButtomTips = false
        })
      },
      onImageLoaded() {
        this.keepMessageListOnButtom()
      }
    }
  }
</script>

<style lang="stylus" scoped>
    /* 当前会话的骨架屏 */
    .merger-conversation-wrapper
        height 54vh
        /*background-color #ffffff*/
        color $base
        display flex
        .current-conversation
            display: flex;
            flex-direction: column;
            width: 100%;
            height: 100%;
    .content
        display: flex;
        flex 1
        flex-direction: column;
        height: 100%;
        overflow: hidden;
        position: relative;
        .message-list
            width: 100%;
            box-sizing: border-box;
            overflow-y: scroll;
            padding: 0 20px;

    .footer
        border-top: 1px solid $border-base;
    .show-more {
        text-align: right;
        padding: 10px 20px 0 0;
    }
    /deep/ .el-checkbox {
        width 100%
    }
    /deep/ .el-checkbox__label {
        width 100%
        padding-right 20px
        box-sizing border-box
    }
    /deep/ .el-divider--horizontal {
        display: block;
        height: 1px;
        width: 90%;
        margin: 0 auto 8px;
    }
    .message-item {
        display flex
        /*border-bottom 1px solid #DEDEDE*/
        /*padding-bottom  10px*/
    }
    .avatar-box {
        .avatar {
            width: 36px;
            height: 36px;
            border-radius: 50%;
            box-shadow: 0 5px 10px 0 rgba(0, 0, 0, 0.1);
        }
    }
    .container-box {
        display flex
        flex-direction column
        .nick-date {
            font-size 12px
            color #B3B3B3
            display flex
            flex-direction row
            .name {
                margin 0 5px
            }
        }

    }
</style>
