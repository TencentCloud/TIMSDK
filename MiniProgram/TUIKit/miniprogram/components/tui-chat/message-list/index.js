import formateTime from '../../tui-calling/tui-calling/utils/formate-time'

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
          this.getMessageList(newVal)
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
    conversation: {}, // 当前会话
    messageList: [],
    // 自己的 ID 用于区分历史消息中，哪部分是自己发出的
    scrollView: '',
    triggered: true,
    nextReqMessageID: '', // 下一条消息标志
    isCompleted: false, // 当前会话消息是否已经请求完毕
  },

  lifetimes: {
    ready() {
      wx.$TUIKit.getMyProfile().then((res) => {
        this.data.avatar = res.data.avatar
        this.data.userID = res.data.userID
      })
      wx.$TUIKit.on(wx.$TUIKitEvent.MESSAGE_RECEIVED, this.$onMessageReceived, this)
      wx.$TUIKit.on(wx.$TUIKitEvent.MESSAGE_READ_BY_PEER, this.$onMessageReadByPeer, this)
    },
    detached() {
      // 一定要解除相关的事件绑定
      wx.$TUIKit.off(wx.$TUIKitEvent.MESSAGE_RECEIVED, this.$onMessageReceived)
    },
  },

  methods: {
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
          this.$handleMessageRender(this.data.messageList, messageList)
        })
      }
    },

    // 自己的消息上屏
    updateMessageList(msg) {
      this.filterCallingMessage(msg)
      this.data.messageList.push(Object.assign(msg, { isSelf: true }))
      this.setData({
        messageList: this.data.messageList,
        scrollView: this.data.messageList[this.data.messageList.length - 1].ID,
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
      // 若需修改消息，需将内存的消息复制一份，不能直接更改消息，防止修复内存消息，导致其他消息监听处发生消息错误
      const event = JSON.parse(JSON.stringify(value))
      const list = []
      event.data.forEach((item) => {
        if (item.conversationID === this.data.conversation.conversationID) {
          this.filterCallingMessage(item)
          list.push(Object.assign(item))
        }
      })
      this.data.messageList = this.data.messageList.concat(list)
      this.setData({
        messageList: this.data.messageList,
        scrollView: this.filterSystemMessageID(this.data.messageList[this.data.messageList.length - 1].ID),
      })
    },
    // 历史消息渲染
    $handleMessageRender(messageList, currentMessageList) {
      for (let i = 0; i < messageList.length; i++) {
        if (messageList[i].flow === 'out') {
          messageList[i].isSelf = true
        }
        // 解析音视频通话消息
        this.filterCallingMessage(messageList[i])
      }
      if (messageList.length > 0) {
        this.setData({
          messageList,
          scrollView: this.filterSystemMessageID(currentMessageList[currentMessageList.length - 1].ID),
        }, () => {
        })
      }
    },

    // 兼容 scrollView
    filterSystemMessageID(messageID) {
      const index = messageID.indexOf('@TIM#')
      if (index > -1) {
        return messageID.replace('@TIM#', '')
      }
      return messageID
    },
    // 解析音视频通话消息
    extractCallingInfoFromMessage(message) {
      if (!message || message.type !== 'TIMCustomElem') {
        return ''
      }
      const signalingData = JSON.parse(message.payload.data)
      if (signalingData.businessID !== 1) {
        return ''
      }
      switch (signalingData.actionType) {
        case 1: {
          const objectData = JSON.parse(signalingData.data)
          if (objectData.call_end > 0 && !signalingData.groupID) {
            return `通话时长：${formateTime(objectData.call_end)}`
          }
          if (objectData.call_end === 0 || !objectData.room_id) {
            return '结束群聊'
          }
          return '发起通话'
        }
        case 2:
          return '取消通话'
        case 3:
          return '已接听'
        case 4:
          return '拒绝通话'
        case 5:
          return '无应答'
        default:
          return ''
      }
    },
    // 音视频通话消息解析
    filterCallingMessage(item) {
      if (item.type === 'TIMCustomElem') {
        let payloadData = {}
        try {
          payloadData = JSON.parse(item.payload.data)
        } catch (e) {
          payloadData = {}
        }
        if (payloadData.businessID === 1) {
          if (item.conversationType === 'GROUP') {
            if (payloadData.actionType === 5) {
              item.nick = payloadData.inviteeList ? payloadData.inviteeList.join(',') : item.from
            }
            const _text = this.extractCallingInfoFromMessage(item)
            const groupText = `${_text}`
            item.type = 'TIMGroupTipElem'
            const customData = {
              operationType: 256,
              text: groupText,
              userIDList: [],
            }
            item.payload = customData// JSON.stringify(customData)
          }
          if (item.conversationType === 'C2C') {
            const c2cText = this.extractCallingInfoFromMessage(item)
            item.type = 'TIMTextElem'
            const customData = {
              text: c2cText,
            }
            item.payload = customData
          }
        }
      }
    },
  },
})
