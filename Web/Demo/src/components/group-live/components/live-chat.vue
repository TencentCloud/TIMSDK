<template>
    <div class="comment-wrapper">
      <div class="message-list" ref="message-list">
        <template v-for="(item, index) in avChatRoomMessageList">
          <!-- 进群提示消息 -->
          <template v-if="item.type === 'TIMGroupTipElem' && item.payload.groupJoinType === 1">
            <div class="msg-item-join" :key="`join_msg_item_${index}`">{{`欢迎${item.nick || item.payload.userIDList.join('')}进入直播间`}}</div>
          </template>
          <!-- 退群提示消息 -->
          <template v-if="item.type === 'TIMGroupTipElem' && item.payload.groupJoinType === 0">
            <div class="msg-item-join" :key="`leave_msg_item_${index}`">{{`${item.nick || item.payload.userIDList.join('')}离开了直播间`}}</div>
          </template>
          <!-- 普通文本消息 -->
          <template v-if="item.type === 'TIMTextElem'">
            <div class="msg-item-text" :key="`text_msg_item_${index}`">
              <img class="avatar" :src="getAvatar(item)" alt=""/>
              <p class="nick" >{{getNick(item)}}</p>
              <p class="msg" ><span class="msg-text">{{ item.payload.text }}</span></p>
            </div>
          </template>
          <template v-if="item.type === 'TIMCustomElem'">
            <!-- native 弹幕消息 -->
            <template v-if="item.payload.data.command === '5'">
              <div class="msg-item-text" :key="`barrage_msg_item_${index}`">
              <img class="avatar" :src="getAvatar(item)" alt=""/>
              <p class="nick" >{{getNick(item)}}</p>
              <p class="msg" ><span class="msg-text">{{ item.payload.data.message }}</span></p>
            </div>
            </template>
            <!-- 礼物消息 -->
            <template v-if="item.payload.data.command === '6'">
              <div class="msg-item-gift" :key="`gift_msg_item_${index}`">
                <img class="avatar" :src="getAvatar(item)" alt=""/>
                <p class="nick" >{{getNick(item)}}</p>
                <p class="msg" >送了一个{{ giftInfo[item.payload.data.message - 1].name }}</p>
                <img class="gift-pic" :src="giftInfo[item.payload.data.message - 1].icon" alt="" />
              </div>
            </template>
          </template>
        </template>
      </div>
      <live-gift  v-if="!isAnchor" />
      <div class="send-container">
        <textarea
          class="comment-message"
          :placeholder="`${sendAvailable ? '请输入内容...' : '开始直播后可以互动聊天哦！'}`"
          v-model="messageContent"
          :disabled="!sendAvailable"
          @keyup.enter="sendMessage"
        ></textarea>
        <el-tooltip
          class="item"
          effect="dark"
          content="按Enter发送消息"
          placement="left-start"
        >
           <div class="btn-send" @click="sendMessage">
            <div class="tim-icon-send"></div>
          </div>
        </el-tooltip>
      </div>
    </div>
</template>

<script>
import { mapState } from 'vuex'
import { Tooltip } from 'element-ui'
import liveGift from './live-gift'

export default {
  name: 'liveChat',
  data() {
    return {
      sendAvailable: false,
      messageContent: '',
      defaultAvatar: 'https://imgcache.qq.com/open/qcloud/video/act/webim-avatar/avatar-2.png',
      giftInfo: [
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482989_25.png',
          name: '火箭'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1507876726_3',
          name: '鸡蛋'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482294_7.png',
          name: '吻'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482461_11.png',
          name: '跑车'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1594714453_7.png',
          name: '嘉年华'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590482754_17.png',
          name: '玫瑰'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1594281297_11.png',
          name: '直升机'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1507876472_1',
          name: '点赞'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483038_27.png',
          name: '比心'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483168_31.png',
          name: '冰淇淋'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483225_33.png',
          name: '玩偶'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483278_35.png',
          name: '蛋糕'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483348_37.png',
          name: '豪华轿车'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483429_39.png',
          name: '游艇'
        },
        {
          icon: 'https://8.url.cn/huayang/resource/now/new_gift/1590483505_41.png',
          name: '翅膀'
        }
      ]
    }
  },
  computed: {
    ...mapState({
      user: state => state.user,
      groupLiveInfo: state => state.groupLive.groupLiveInfo,
      avChatRoomMessageList: state => {
        const list = state.groupLive.avChatRoomMessageList
        list.map((item) => {
          if (item.type === 'TIMCustomElem' && typeof item.payload.data === 'string' && item.payload.data.indexOf('{') > -1) {
            item.payload.data = JSON.parse(item.payload.data)
          }
          return item
        })
        return list
      },
      // avChatRoomBarrageMessageList: state => state.groupLive.avChatRoomBarrageMessageList,
      // avChatRoomGiftMessageList: state => state.groupLive.avChatRoomGiftMessageList,
    }),
    isAnchor () {
      return this.user.userID === this.groupLiveInfo.anchorID
    }
  },
  components: {
    liveGift,
    ElTooltip: Tooltip,
  },
  created() {
    // 此处监听，防止观众侧派发加群事件时，该组件中还未注册监听
    this.$bus.$on('join-group-live-avchatroom', () => {
      this.joinGroupLiveAvChatRoom()
    })
  },
  mounted() {
    this.$bus.$on('group-live-send-gift', (index)=> {
      const message = this.tim.createCustomMessage({
        to: this.groupLiveInfo.roomID,
        conversationType: this.TIM.TYPES.CONV_GROUP,
        payload: {
          data: JSON.stringify({version: '1.0.0' ,'message': `${index}`,'command':'6','action':301}),
          description: '',
          extension: ''
        }
      })
      // 此处用JSON序列化和反序列化对message断链
      this.$store.commit('pushAvChatRoomMessageList', JSON.parse(JSON.stringify(message)))
      this.tim.sendMessage(message).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
    })
  },
  beforeDestroy() {
    this.$bus.$off('join-group-live-avchatroom')
    this.$bus.$off('group-live-send-gift')
    if (!this.isAnchor && this.groupLiveInfo.isNeededQuitRoom === 1) {
      this.quitGroupLiveAvChatRoom()
    }
    this.$store.commit('updateGroupLiveInfo', { isNeededQuitRoom: 0 })
  },
  methods: {
    getAvatar (item) {
      if (item.from === this.user.userID) {
        return this.user.currentUserProfile.avatar || this.defaultAvatar
      }
      return item.avatar || this.defaultAvatar
    },
    getNick (item) {
      if (item.from === this.user.userID) {
        return this.user.currentUserProfile.nick || item.from
      }
      return item.nick || item.from
    },
    // 进入直播互动群
    joinGroupLiveAvChatRoom() {
      this.tim.joinGroup({
        groupID: this.groupLiveInfo.roomID
      }).then((imResponse) => {
        const status = imResponse.data.status
        if (status === this.TIM.TYPES.JOIN_STATUS_SUCCESS || status === this.TIM.TYPES.JOIN_STATUS_ALREADY_IN_GROUP) {
          this.sendAvailable = true
        }
      }).catch(() => {})
    },
    // 退出直播互动群
    quitGroupLiveAvChatRoom() {
      this.tim.quitGroup(this.groupLiveInfo.roomID).then(() => {}).catch(() => {})
    },
    sendMessage() {
      if (!this.sendAvailable) {
        this.$store.commit('showMessage', {
          message: '开始直播后可以互动聊天哦！',
          type: 'warning'
        })
        return
      }
      if (this.messageContent === '' || this.messageContent.trim().length === 0) {
        this.messageContent = ''
        this.$store.commit('showMessage', {
          message: '不能发送空消息哦！',
          type: 'info'
        })
        return
      }
      const message = this.tim.createTextMessage({
        to: this.groupLiveInfo.roomID,
        conversationType: this.TIM.TYPES.CONV_GROUP,
        payload: { text: this.messageContent }
      })
      // 此处用JSON序列化和反序列化对message断链
      this.$store.commit('pushAvChatRoomMessageList', JSON.parse(JSON.stringify(message)))
      this.tim.sendMessage(message).catch(error => {
        this.$store.commit('showMessage', {
          type: 'error',
          message: error.message
        })
      })
      this.messageContent = ''
    }
  },
  watch: {
    avChatRoomMessageList: function() {
      this.$nextTick(() => {
        let messageListNode = this.$refs['message-list']
        if (!messageListNode) {
          return
        }
        messageListNode.scrollTop = messageListNode.scrollHeight
      })
    }
  }
}
</script>
<style lang="stylus" scoped>
  ::-webkit-textarea-placeholder {
    color: #a5b5c1
  }
  ::-moz-textarea-placeholder {
    color: #a5b5c1
  }
  ::-ms-textarea-placeholder {
    color: #a5b5c1
  }
  .comment-wrapper {
    position relative
    box-sizing border-box
    width 100%
    height 100%
    display flex
    flex-flow column
  }
  .message-list {
      position: relative;
      width: 100%;
      overflow: auto;
      overflow-x: hidden;
      -webkit-box-sizing: border-box;
      box-sizing: border-box;
      overflow-y: scroll;
      -webkit-overflow-scrolling: touch;
      padding: 20px;
      margin-bottom: 5px;
      flex 1
      .msg-item-join {
        margin: 0 30px 20px 30px
        padding: 4px 15px
        border-radius: 3px
        color: #a5b5c1
        font-size: 12px
        text-align: center
        box-sizing: border-box
        white-space: nowrap
        overflow: hidden
        text-overflow: ellipsis

      }
      .msg-item-text {
        width 100%
        min-height 60px
        .avatar {
          width 45px
          height 45px
          border-radius 50%
        }
        .nick {
          position relative
          top -24px
          left 8px
          color #a5b5c1
          font-size 14px
          margin 0
          max-width 150px !important
          display inline-block
          overflow hidden
          text-overflow ellipsis
          white-space nowrap
        }
        .msg {
          position relative
          top -25px
          left 60px
          word-break break-all
          color #fff
          margin 0
          max-width 230px
          .msg-text {
            display inline-block
            height 100%
            background-color #5cadff
            border-radius 0 4px 4px 4px
            padding 10px
            font-size 14px
          }
        }
        .msg::before {
          position: absolute
          top: 0
          width: 12px
          height: 40px
          content: "\E900"
          font-family: 'tim' !important
          font-size: 24px
          transform scaleX(-1)
          left -10px
          color #5cadff
        }
      }
      .msg-item-gift {
        position relative
        width 60%
        min-width 290px
        height 60px
        background #5cadff
        border-radius 30px
        margin 0 0 20px 0
        .avatar {
          width 45px
          height 45px
          border-radius 50%
          margin 8px
        }
        .nick {
          position relative
          top -32px
          left 0px
          color #fff
          margin 0
          font-size 14px
          max-width 150px !important
          display inline-block
          overflow hidden
          text-overflow ellipsis
          white-space nowrap
        }
        .msg {
          position relative
          top -35px
          left -5px
          padding 0 0 0 65px
          word-break break-all
          color #fff
          margin 0
          font-size 14px
        }
        .gift-pic {
          position absolute
          top -15px
          right -18px
          width 75px
          height 75px
        }
      }
    }
    .send-container {
      position relative
      width 100%
      height 100px
      -webkit-box-sizing border-box
      box-sizing border-box
      border-top 1px solid #e6e6e6
      display flex
      flex-flow column
      .comment-message {
        flex 1
        margin 0
        border-radius 0
        border hidden
        outline-style none
        padding 10px
        font-size 16px
        color #000
        resize none
      }
      .btn-send {
        position: absolute
        color: #2d8cf0
        font-size: 30px
        right: 0px
        bottom: 0px
        padding: 6px 6px 4px 4px
        cursor: pointer
      }
    }
</style>
