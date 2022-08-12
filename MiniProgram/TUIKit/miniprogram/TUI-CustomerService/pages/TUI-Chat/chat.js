import logger from '../../utils/logger';
import constant from '../../utils/constant';
// eslint-disable-next-line no-undef
const app = getApp();
// eslint-disable-next-line no-undef
const inputStyle = `
  --padding: 30px
`;

let newInputStyle =  `
--padding: 0px
`;

const setNewInputStyle = (number) => {
  const height = number;
  newInputStyle = `--padding: ${height}px`;
};


// eslint-disable-next-line no-undef
Page({

  /**
   * 页面的初始数据
   */
  data: {
    conversationName: '',
    conversation: {},
    messageList: [],
    isShow: false,
    showImage: false,
    showChat: true,
    conversationID: '',
    config: {
      sdkAppID: '',
      userID: '',
      userSig: '',
      type: 1,
      tim: null,
    },
    unreadCount: 0,
    viewData: {
      style: inputStyle,
    },
    KeyboardHeight: 0,
  },
  /**
   * 生命周期函数--监听页面加载
   */
  onLoad(options) {
    const { config } = this.data;
    config.sdkAppID = app.globalData.SDKAppID;
    config.userID = app.globalData.userInfo.userID;
    config.userSig = app.globalData.userInfo.userSig;
    config.tim = wx.$TUIKit;
    this.setData({
      config,
    }, () => {
      this.TRTCCalling = this.selectComponent('#tui-callkit');
      this.TRTCCalling.init();
    });
    // conversationID: C2C、 GROUP
    logger.log(`| TUI-chat | onLoad | conversationInfomation: ${options.conversationInfomation}`);
    const   payloadData = JSON.parse(options.conversationInfomation);
    const unreadCount = payloadData.unreadCount ? payloadData.unreadCount : 0;
    this.setData({
      conversationID: payloadData.conversationID,
      unreadCount,
    });
    wx.$TUIKit.setMessageRead({ conversationID: this.data.conversationID }).then(() => {
      logger.log('| TUI-chat | setMessageRead | ok');
    });
    wx.setNavigationBarColor({
      frontColor: '#ffffff',
      backgroundColor: '#006EFF',
    });
    wx.$TUIKit.getConversationProfile(this.data.conversationID).then((res) => {
      const { conversation } = res.data;
      wx.setNavigationBarTitle({
        title: this.getConversationName(conversation),
      });
      this.setData({
        conversationName: this.getConversationName(conversation),
        conversation,
        isShow: conversation.type === 'GROUP',
      });
    });
  },
  /**
 * 生命周期函数--监听页面卸载
 */
  onUnload() {
    this.TRTCCalling.destroyed();
  },
  getConversationName(conversation) {
    const { conversationType_text } = constant;
    if (conversation.type === '@TIM#SYSTEM') {
      this.setData({
        showChat: false,
      });
      return '系统通知';
    }
    if (conversation.type === conversationType_text.typeC2C) {
      return conversation.remark || conversation.userProfile.nick || conversation.userProfile.userID;
    }
    if (conversation.type === conversationType_text.typeGroup) {
      return conversation.groupProfile.name || conversation.groupProfile.groupID;
    }
  },
  sendMessage(event) {
    // 将自己发送的消息写进消息列表里面
    this.selectComponent('#message-list').updateMessageList(event.detail.message);
  },
  showMessageErrorImage(event) {
    this.selectComponent('#message-list').sendMessageError(event);
  },
  triggerClose() {
    this.selectComponent('#message-input').handleClose();
  },
  handleCall(event) {
    if (event.detail.groupID) {
      this.TRTCCalling.groupCall(event.detail);
    } else {
      this.TRTCCalling.call(event.detail);
    }
  },

  goBack() {
    // eslint-disable-next-line no-undef
    const pages = getCurrentPages(); // 当前页面栈
    if (pages[pages.length - 2].route === 'pages/TUI-Conversation/create-conversation/create'
      || pages[pages.length - 2].route === 'pages/TUI-Group/create-group/create'
      || pages[pages.length - 2].route === 'pages/TUI-Group/join-group/join') {
      wx.navigateBack({
        delta: 2,
      });
    } else {
      wx.navigateBack({
        delta: 1,

      });
    }
    this.TRTCCalling.destroyed();
    wx.$TUIKit.setMessageRead({
      conversationID: this.data.conversationID,
    }).then(() => {});
  },
  changeMemberCount(event) {
    this.selectComponent('#group-profile').updateMemberCount(event.detail.groupOptionsNumber);
  },
  resendMessage(event) {
    this.selectComponent('#message-input').onInputValueChange(event);
  },
  handleReport() {
    const url = '/pages/TUI-User-Center/webview/webview?url=https://cloud.tencent.com/apply/p/xc3oaubi98g';
    wx.navigateTo({
      url,
    });
  },
  // 监听键盘，获取焦点时将输入框推到键盘上方
  pullKeysBoards(event) {
    setNewInputStyle(event.detail.event.detail.height);
    this.setData({
      'viewData.style': newInputStyle,
    });
  },
  // 监听键盘，失去焦点时收起键盘
  downKeysBoards(event) {
    this.setData({
      'viewData.style': inputStyle,
    });
  },
  typeMessage(event) {
    const { conversationType_text, STRING_TEXT, FEAT_NATIVE_CODE } = constant;
    if (this.data.conversation.type === conversationType_text.typeC2C) {
      if (event.detail.typingMessage.typingStatus === FEAT_NATIVE_CODE.ISTYPING_STATUS && event.detail.typingMessage.actionParam === constant.typeInputStatusIng) {
        wx.setNavigationBarTitle({
          title: STRING_TEXT.TYPETYPING,
        });
        setTimeout(() => {
          wx.setNavigationBarTitle({
            title: this.data.conversationName,
          });
        }, (1000 * 30));
      } else if (event.detail.typingMessage.typingStatus === FEAT_NATIVE_CODE.NOTTYPING_STATUS && event.detail.typingMessage.actionParam === constant.typeInputStatusEnd) {
        wx.setNavigationBarTitle({
          title: this.data.conversationName,
        });
      }
    }
  },
});
