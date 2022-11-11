import formateTime from '../../../../utils/formate-time';
import constant from '../../../../utils/constant';
// eslint-disable-next-line no-undef
Component({
  /**
   * 组件的属性列表
   */
  properties: {
    message: {
      type: Object,
      value: {},
      observer(newVal) {
        this.setData({
          message: newVal,
          renderDom: this.parseCustom(newVal),
        });
      },
    },
    isMine: {
      type: Boolean,
      value: true,
    },
  },

  /**
   * 组件的初始数据
   */
  data: {
  },

  /**
   * 组件的方法列表
   */
  methods: {
    // 解析音视频通话消息
    extractCallingInfoFromMessage(message) {
      const callingmessage = JSON.parse(message.payload.data);
      if (callingmessage.businessID !== 1) {
        return '';
      }
      const objectData = JSON.parse(callingmessage.data);
      switch (callingmessage.actionType) {
        case 1: {
          if (objectData.call_end >= 0 && !callingmessage.groupID) {
            return `通话时长：${formateTime(objectData.call_end)}`;
          }
          if (callingmessage.groupID) {
            return '结束群聊';
          }
          if (objectData.data && objectData.data.cmd === 'switchToAudio') {
            return '切换语音通话';
          }
          if (objectData.data && objectData.data.cmd === 'switchToVideo') {
            return '切换视频通话';
          }
          return '发起通话';
        }
        case 2:
          return '取消通话';
        case 3:
          if (objectData.data && objectData.data.cmd === 'switchToAudio') {
            return '切换语音通话';
          }
          if (objectData.data && objectData.data.cmd === 'switchToVideo') {
            return '切换视频通话';
          }
          return '已接听';
        case 4:
          return '拒绝通话';
        case 5:
          if (objectData.data && objectData.data.cmd === 'switchToAudio') {
            return '切换语音通话';
          }
          if (objectData.data && objectData.data.cmd === 'switchToVideo') {
            return '切换视频通话';
          }
          return '无应答';
        default:
          return '';
      }
    },
    parseCustom(message) {
      const { conversationType_text, businessID_text } = constant;
      let customMessage = null;
      try {
        customMessage = JSON.parse(message.payload.data);
      } catch (e) {
        customMessage = {};
      }
      try {
        // 约定自定义消息的 data 字段作为区分，不解析的不进行展示
        if (customMessage.businessID === businessID_text.typeOrder) {
          const renderDom = [{
            type: 'order',
            name: 'custom',
            title: customMessage.title || '',
            imageUrl: customMessage.imageUrl || '',
            price: customMessage.price || 0,
            description: customMessage.description,
          }];
          return renderDom;
        }
        // 服务评价
        if (customMessage.businessID === businessID_text.typeEvaluation) {
          const renderDom = [{
            type: 'evaluation',
            title: message.payload.description,
            score: customMessage.score,
            description: customMessage.comment,
          }];
          return renderDom;
        }
        // native 自定义消息解析
        if (customMessage.businessID === businessID_text.typeLink) {
          const renderDom = [{
            type: 'text_link',
            text: customMessage.text,
          }];
          return renderDom;
        }
        // 群消息解析
        if (message.payload.data === businessID_text.typeCreate) {
          const renderDom = [{
            type: 'group_create',
            text: message.payload.extension,
          }];
          return renderDom;
        }
      } catch (error) {
      }
      // 客服咨询
      try {
        const extension = JSON.parse(message.payload.extension);
        if (message.payload.data === businessID_text.typeConsultion) {
          const renderDom = [{
            type: 'consultion',
            title: extension.title || '',
            item: extension.item || 0,
            description: extension.description,
          }];
          return renderDom;
        }
      } catch (error) {
      }
      // 音视频通话消息解析
      try {
        const callingmessage = JSON.parse(message.payload.data);
        if (callingmessage.businessID === 1) {
          if (message.conversationType === conversationType_text.typeGroup) {
            if (message.payload.data.actionType === 5) {
              message.nick = message.payload.data.inviteeList ? message.payload.data.inviteeList.join(',') : message.from;
            }
            const _text = this.extractCallingInfoFromMessage(message);
            const groupText = `${_text}`;
            const renderDom = [{
              type: 'groupCalling',
              text: groupText,
              userIDList: [],
            }];
            return renderDom;
          }
          if (message.conversationType === conversationType_text.typeC2C) {
            const c2cText = this.extractCallingInfoFromMessage(message);
            const renderDom = [{
              type: 'c2cCalling',
              text: c2cText,
            }];
            return renderDom;
          }
        }
        return [{
          type: 'notSupport',
          text: '[自定义消息]',
        }];
      } catch (error) {
      }
    },
    openLink(e) {
      if (e.currentTarget.dataset.value.key === '立即前往') {
        wx.navigateTo({
          url: '/pages/TUI-User-Center/webview/webview?url=https://cloud.tencent.com/act/pro/imnew?from=16975&wechatMobile',
        });
      } else if (e.currentTarget.dataset.value.key === '立即体验') {
        wx.navigateTo({
          url: '/pages/TUI-User-Center/webview/webview?url=https://cloud.tencent.com/document/product/269/68091',
        });
      }
    },
  },
});
