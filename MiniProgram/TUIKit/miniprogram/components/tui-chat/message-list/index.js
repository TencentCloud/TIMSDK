// import formateTime from '../../tui-calling/tui-calling/utils/formate-time'
const app = getApp()
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    conversation: {
      type: Object,
      value: {},
      observer(newVal) {
        if (!newVal.conversationID) return
        this.setData({
          conversation: newVal,
        }, () => {
          this.getMessageList(this.data.conversation)
        })
      },
    },
    unreadCount: {
      type: Number,
      value: '',
      observer(newVal) {
        this.setData({
          unreadCount: newVal,
        })
      },
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
    avatar: '',
    userID: '',
    unreadCount: '',
    conversation: {}, // 当前会话
    messageList: [],
    // 自己的 ID 用于区分历史消息中，哪部分是自己发出的
    scrollView: '',
    triggered: true,
    nextReqMessageID: '', // 下一条消息标志
    isCompleted: false, // 当前会话消息是否已经请求完毕
    messagepopToggle: false,
    messageID: '',
    checkID: '',
    selectedMessage: {},
    deleteMessage: '',
    isRevoke: false,
    RevokeID: '', // 撤回消息的ID用于处理对方消息展示界面
    showName: '',
    showDownJump: false,
    showUpJump: false,
    jumpAim: '',
    messageIndex: '',
    isShow: false,
    Show: false,
    UseData: '',
    chargeLastmessage: '',
    groupOptionsNumber: '',
    showNewMessageCount: [],
  },

  lifetimes: {
    attached() {
    },
    ready() {
      if (this.data.unreadCount > 12) {
        this.setData({
          showUpJump: true,
        })
      }
      wx.$TUIKit.getMyProfile().then((res) => {
        this.data.avatar = res.data.avatar
        this.data.userID = res.data.userID
      })
      wx.$TUIKit.on(wx.$TUIKitEvent.MESSAGE_RECEIVED, this.$onMessageReceived, this)
      wx.$TUIKit.on(wx.$TUIKitEvent.MESSAGE_READ_BY_PEER, this.$onMessageReadByPeer, this)
      wx.$TUIKit.on(wx.$TUIKitEvent.MESSAGE_REVOKED, this.$onMessageRevoked, this)
    },

    detached() {
      // 一定要解除相关的事件绑定
      wx.$TUIKit.off(wx.$TUIKitEvent.MESSAGE_RECEIVED, this.$onMessageReceived)
      wx.$TUIKit.off(wx.$TUIKitEvent.MESSAGE_READ_BY_PEER, this.$onMessageReadByPeer)
      wx.$TUIKit.off(wx.$TUIKitEvent.MESSAGE_REVOKED, this.$onMessageRevoked)
    },
  },

  methods: {
    // 刷新消息列表
    refresh() {
      if (this.data.isCompleted) {
        this.setData({
          isCompleted: true,
          triggered: false,
        })
        return
      }
      this.getMessageList(this.data.conversation)
      setTimeout(() => {
        this.setData({
          triggered: false,
        })
      }, 2000)
    },
    // 获取消息列表
    getMessageList(conversation) {
      if (!this.data.isCompleted) {
        wx.$TUIKit.getMessageList({
          conversationID: conversation.conversationID,
          nextReqMessageID: this.data.nextReqMessageID,
          count: 15,
        }).then((res) => {
          const { messageList } = res.data // 消息列表。
          this.data.nextReqMessageID = res.data.nextReqMessageID // 用于续拉，分页续拉时需传入该字段。
          this.data.isCompleted = res.data.isCompleted // 表示是否已经拉完所有消息。
          this.data.messageList = [...messageList, ...this.data.messageList]
          if (messageList.length > 0 && this.data.messageList.length < this.data.unreadCount) {
            this.getMessageList(conversation)
          }
          this.$handleMessageRender(this.data.messageList, messageList)
        })
      }
    },
    // 历史消息渲染
    $handleMessageRender(messageList, currentMessageList) {
      for (let i = 0; i < messageList.length; i++) {
        if (messageList[i].flow === 'out') {
          messageList[i].isSelf = true
        }
      }
      if (messageList.length > 0) {
        if (this.data.conversation.type === '@TIM#SYSTEM') {
          this.filterRepateSystemMessage(messageList)
        } else {
          this.setData({
            messageList,
            jumpAim: this.filterSystemMessageID(currentMessageList[currentMessageList.length - 1].ID),
          }, () => {
          })
        }
      }
    },
    // 系统消息去重
    filterRepateSystemMessage(messageList) {
      const noRepateMessage = []
      for (let index = 0;  index < messageList.length; index++) {
        if (!noRepateMessage.some(item => item && item.ID === messageList[index].ID)) {
          noRepateMessage.push(messageList[index])
        }
      }
      this.setData({
        messageList: noRepateMessage,
      })
    },
    // 消息已读更新
    $onMessageReadByPeer() {
      this.setData({
        messageList: this.data.messageList,
      })
    },
    // 收到的消息
    $onMessageReceived(value) {
      this.setData({
        UseData: value,
      })
      value.data.forEach((item) => {
        if (this.data.messageList.length > 12 && !value.data[0].isRead
        && item.conversationID === this.data.conversation.conversationID) {
          this.data.showNewMessageCount.push(value.data[0])
          this.setData({
            showNewMessageCount: this.data.showNewMessageCount,
            showDownJump: true,
          })
        } else {
          this.setData({
            showDownJump: false,
          })
        }
      })
      // 若需修改消息，需将内存的消息复制一份，不能直接更改消息，防止修复内存消息，导致其他消息监听处发生消息错误
      const list = []
      value.data.forEach((item) => {
        if (item.conversationID === this.data.conversation.conversationID) {
          list.push(item)
        }
      })
      this.data.messageList = this.data.messageList.concat(list)
      app.globalData.groupOptionsNumber = this.data.messageList.slice(-1)[0].payload.operationType
      this.$onMessageReadByPeer()
      this.setData({
        messageList: this.data.messageList,
        groupOptionsNumber: this.data.messageList.slice(-1)[0].payload.operationType,
      })
      if (this.data.conversation.type === 'GROUP') {
        this.triggerEvent('changeMemberCount', {
          groupOptionsNumber: this.data.messageList.slice(-1)[0].payload.operationType,
        })
      }
    },
    // 自己的消息上屏
    updateMessageList(message) {
      message.isSelf = true
      this.data.messageList.push(message)
      this.setData({
        messageList: this.data.messageList,
        jumpAim: this.filterSystemMessageID(this.data.messageList[this.data.messageList.length - 1].ID),
      })
    },
    // 兼容 scrollView
    filterSystemMessageID(messageID) {
      const index = messageID.indexOf('@TIM#')
      if (index > -1) {
        return messageID.replace('@TIM#', '')
      }
      return messageID
    },
    // 获取消息ID
    handleLongPress(e) {
      const { index } = e.currentTarget.dataset
      this.setData({
        messageID: e.currentTarget.id,
        selectedMessage: this.data.messageList[index],
        Show: true,
      })
    },
    // 更新messagelist
    updateMessageByID(deleteMessage) {
      const { messageList } = this.data
      for (let index = messageList.length - 1; index >= 0;index--) {
        if (messageList[index] && messageList[index].ID === deleteMessage) {
          messageList.splice(index, 1)
          this.setData({
            messageList,
          })
        }
      }
    },
    // 删除消息
    DeleteMessage() {
      wx.$TUIKit.deleteMessage([this.data.selectedMessage])
        .then((imResponse) => {
          this.updateMessageByID(imResponse.data.messageList[0].ID)
        })
        .catch((imError) => {
          console.log(imError)
        })
    },
    // 撤回消息
    RevokeMessage() {
      wx.$TUIKit.revokeMessage(this.data.selectedMessage)
        .then((imResponse) => {
          this.updateMessageByID(imResponse.data.message.ID)
          if (imResponse.data.message.from === app.globalData.userInfo.userID) {
            this.setData({
              showName: '你',
              isRevoke: true,
            })
          }
          // 消息撤回成功
        })
        .catch((imError) => {
          wx.showToast({
            title: '超过2分钟消息不支持撤回',
            duration: 800,
            icon: 'none',
          }),
          this.setData({
            Show: false,
          })
          // 消息撤回失败
          console.warn('revokeMessage error:', imError)
        })
    },
    // 关闭弹窗
    handleEditToggleAvatar() {
      this.setData({
        Show: false,
      })
    },
    // 向对方通知消息撤回事件
    $onMessageRevoked(event) {
      if (event.data[0].from !== app.globalData.userInfo.userID) {
        this.setData({
          showName: event.data[0].nick,
          RevokeID: event.data[0].ID,
          isRevoke: true,
        })
      }
      this.updateMessageByID(event.data[0].ID)
    },
    // 消息跳转到最新
    handleJumpNewMessage() {
      this.setData({
        jumpAim: this.filterSystemMessageID(this.data.messageList[this.data.messageList.length - 1].ID),
        showDownJump: false,
        showNewMessageCount: [],
      })
    },
    // 消息跳转到最近未读
    handleJumpUnreadMessage() {
      if (this.data.unreadCount > 15) {
        this.getMessageList(this.data.conversation)
        this.setData({
          jumpAim: this.filterSystemMessageID(this.data.messageList
            [this.data.messageList.length - this.data.unreadCount].ID),
          showUpJump: false,
        })
      } else {
        this.setData({
          jumpAim: this.filterSystemMessageID(this.data.messageList
            [this.data.messageList.length - this.data.unreadCount].ID),
          showUpJump: false,
        })
      }
    },
    // 滑动到最底部置跳转事件为false
    scrollHandler() {
      this.setData({
        jumpAim: this.filterSystemMessageID(this.data.messageList[this.data.messageList.length - 1].ID),
        showDownJump: false,
      })
    },
    // 删除处理掉的群通知消息
    changeSystemMessageList(event) {
      this.updateMessageByID(event.detail.message.ID)
    },
  },
})
