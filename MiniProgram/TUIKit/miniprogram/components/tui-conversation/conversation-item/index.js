import { caculateTimeago } from '../../base/common'
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    conversation: {
      type: Object,
      value: {},
      observer(conversation) {
        // 计算时间戳
        this.setData({
          conversationName: this.getConversationName(conversation),
          setConversationAvatar: this.setConversationAvatar(conversation),
        })
        this.$updateTimeago(conversation)
      },
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    xScale: 0,
    conversationName: '',
    conversationAvatar: '',
  },
  lifetimes: {
    show() {
      this.$updateTimeago(this.data.conversation)
    },
  },
  /**
   * 组件的方法列表
   */
  methods: {
    // 先查 remark；无 remark 查 (c2c)nick/(group)name；最后查 (c2c)userID/(group)groupID
    getConversationName(conversation) {
      if (conversation.type === '@TIM#SYSTEM') {
        return '系统通知'
      }
      if (conversation.type === 'C2C') {
        return conversation.remark || conversation.userProfile.nick || conversation.userProfile.userID
      }
      if (conversation.type === 'GROUP') {
        return conversation.groupProfile.name || conversation.groupProfile.groupID
      }
    },
    setConversationAvatar(conversation) {
      if (conversation.type === '@TIM#SYSTEM') {
        return 'https://web.sdk.qcloud.com/component/TUIKit/assets/system.png'
      }
      if (conversation.type === 'C2C') {
        return conversation.userProfile.avatar || 'https://sdk-web-1252463788.cos.ap-hongkong.myqcloud.com/component/TUIKit/assets/avatar_21.png'
      }
      if (conversation.type === 'GROUP') {
        return conversation.groupProfile.avatar || '../../../static/assets/gruopavatar.svg'
      }
    },
    deleteConversation() {
      wx.showModal({
        content: '确认删除会话？',
        success: (res) => {
          if (res.confirm) {
            wx.$TUIKit.deleteConversation(this.data.conversation.conversationID)
            this.setData({
              conversation: {},
              xScale: 0,
            })
          }
        },
      })
    },
    handleTouchMove(e) {
      if (!this.lock) {
        this.last = e.detail.x
        this.lock = true
      }
      if (this.lock && e.detail.x - this.last < -5) {
        this.setData({
          xScale: -75,
        })
        setTimeout(() => {
          this.lock = false
        }, 2000)
      } else if (this.lock && e.detail.x - this.last > 5) {
        this.setData({
          xScale: 0,
        })
        setTimeout(() => {
          this.lock = false
        }, 2000)
      }
    },
    $updateTimeago(conversation) {
      if (conversation.conversationID) {
        conversation.lastMessage.timeago = caculateTimeago(conversation.lastMessage.lastTime * 1000)
        conversation.lastMessage.messageForShow = conversation.lastMessage.messageForShow.slice(0, 15)
      }
      this.setData({
        conversation,
      })
    },
    handleimageerro() {
      this.setData({
        setConversationAvatar: '../../../static/assets/gruopavatar.svg',
      })
    },
  },
})
