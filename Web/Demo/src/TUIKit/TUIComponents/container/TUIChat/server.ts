import IComponentServer from '../IComponentServer';
import { JSONToString } from './utils/utils';

/**
 * class TUIChatServer
 *
 * TUIChat 逻辑主体
 */
export default class TUIChatServer extends IComponentServer {
  public TUICore: any;
  public store: any;
  public currentStore: any = {};
  constructor(TUICore: any) {
    super();
    this.TUICore = TUICore;
    this.bindTIMEvent();
    this.store = TUICore.setComponentStore('TUIChat', {}, this.updateStore.bind(this));
  }

  /**
   * 组件销毁
   * destroy
   */
  public destroyed() {
    this.unbindTIMEvent();
  }

  /**
   * 数据监听回调
   * data listener callback
   *
   * @param {any} newValue 新数据
   * @param {any} oldValue 旧数据
   *
   */
  updateStore(newValue: any, oldValue: any) {
    Object.assign(this.currentStore, newValue);
    if (!newValue.conversation.conversationID) {
      this.currentStore.messageList = [];
      return;
    }
    if (
      newValue.conversation.conversationID &&
      newValue.conversation.conversationID !== oldValue.conversation.conversationID
    ) {
      this.render(newValue.conversation);
    }
  }

  public render(conversation: any) {
    const len = 15;
    this.currentStore.isFirstRender = true;
    this.currentStore.messageList = [];
    this.currentStore.readSet.clear();
    this.getMessageList({ conversationID: conversation.conversationID, count: len });
    if (conversation.type === this.TUICore.TIM.TYPES.CONV_GROUP) {
      this.currentStore.userInfo.isGroup = true;
      const options = {
        groupID: conversation.groupProfile.groupID,
        userIDList: [conversation.groupProfile.selfInfo.userID],
      };
      this.getGroupProfile({ groupID: conversation.groupProfile.groupID });
      this.getGroupMemberProfile(options).then((res: any) => {
        const { memberList } = res.data;
        const [selfInfo] = memberList;
        this.currentStore.selfInfo = selfInfo;
      });
    } else {
      this.currentStore.userInfo.isGroup = false;
      this.currentStore.userInfo.list = [conversation?.userProfile];
    }
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    TIM 事件监听注册接口
   * //                        TIM Event listener registration interface
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  private bindTIMEvent() {
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_RECEIVED, this.handleMessageReceived, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_MODIFIED, this.handleMessageModified, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_REVOKED, this.handleMessageRevoked, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.MESSAGE_READ_BY_PEER, this.handleMessageReadByPeer, this);
    this.TUICore.tim.on(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated, this);
    this.TUICore.tim.on(
      this.TUICore.TIM.EVENT.MESSAGE_READ_RECEIPT_RECEIVED,
      this.handleMessageReadReceiptReceived,
      this
    );
  }

  private unbindTIMEvent() {
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_RECEIVED, this.handleMessageReceived);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_MODIFIED, this.handleMessageModified);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_REVOKED, this.handleMessageRevoked);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_READ_BY_PEER, this.handleMessageReadByPeer);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.GROUP_LIST_UPDATED, this.handleGroupListUpdated);
    this.TUICore.tim.off(this.TUICore.TIM.EVENT.MESSAGE_READ_RECEIPT_RECEIVED, this.handleMessageReadReceiptReceived);
  }

  private handleMessageReceived(event: any) {
    if (event?.data[0]?.conversationID === this?.store?.conversation?.conversationID) {
      this.currentStore.messageList = [...this.currentStore.messageList, ...event.data];
    }
  }
  private handleMessageModified(event: any) {
    const middleData = this.currentStore.messageList;
    this.currentStore.messageList = [];
    this.currentStore.messageList = middleData;
  }
  private handleMessageRevoked(event: any) {
    const middleData = this.currentStore.messageList;
    this.currentStore.messageList = [];
    this.currentStore.messageList = middleData;
  }
  private handleMessageReadByPeer(event: any) {
    const middleData = this.currentStore.messageList;
    this.currentStore.messageList = [];
    this.currentStore.messageList = middleData;
  }

  private handleGroupListUpdated(event: any) {
    event?.data.map((item: any) => {
      if (item?.groupID === this?.store?.conversation?.groupProfile?.groupID) {
        this.store.conversation.groupProfile = item;
        this.currentStore.conversation = {};
        this.currentStore.conversation = this.store.conversation;
      }
      return item;
    });
  }

  private handleMessageReadReceiptReceived(event: any) {
    const middleData = this.currentStore.messageList;
    this.currentStore.messageList = [];
    this.currentStore.messageList = middleData;
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 处理 TIM 接口参数及回调
   * //                     Handling TIM interface parameters and callbacks
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 创建消息生成参数
   * Create message generation parameters
   *
   * @param {Object} content 消息体
   * @param {String} type 消息类型 text: 文本类型 file: 文件类型 face: 表情 location: 地址 custom: 自定义 merger: 合并 forward: 转发
   * @param {Callback} callback 回调函数
   * @param {any} to 发送的对象
   * @returns {options} 消息参数
   */
  public handleMessageOptions(content: any, type: string, callback?: any, to?: any) {
    const options: any = {
      to: '',
      conversationType: to?.type || this.store.conversation.type,
      payload: content,
      needReadReceipt: this.currentStore.needReadReceipt,
    };
    if (this.currentStore.needTyping) {
      options.cloudCustomData = {
        messageFeature: {
          needTyping: 1,
          version: 1,
        },
      };
      options.cloudCustomData = JSON.stringify(options.cloudCustomData);
    }
    if (type === 'file' && callback) {
      options.onProgress = callback;
    }
    switch (options.conversationType) {
      case this.TUICore.TIM.TYPES.CONV_C2C:
        options.to = to?.userProfile?.userID || this.store.conversation?.userProfile?.userID || '';
        break;
      case this.TUICore.TIM.TYPES.CONV_GROUP:
        options.to = to?.groupProfile?.groupID || this.store.conversation?.groupProfile?.groupID || '';
        break;
      default:
        break;
    }
    return options;
  }

  /**
   * 处理异步函数
   * Handling asynchronous functions
   *
   * @param {callback} callback 回调函数
   * @returns {Promise} 返回异步函数
   */
  public handlePromiseCallback(callback: any) {
    return new Promise<void>((resolve, reject) => {
      const config = {
        TUIName: 'TUIChat',
        callback: () => {
          callback && callback(resolve, reject);
        },
      };
      this.TUICore.setAwaitFunc(config.TUIName, config.callback);
    });
  }

  /**
   * 文件上传进度函数处理
   * File upload progress function processing
   *
   * @param {number} progress 文件上传进度 1表示完成
   * @param {message} message 文件消息
   */
  public handleUploadProgress(progress: number, message: any) {
    this.currentStore.messageList.map((item: any) => {
      if (item.ID === message.ID) {
        item.progress = progress;
      }
      return item;
    });
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 TIM 方法
   * //                               TIM methods
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 发送表情消息
   * Send face messages
   *
   * @param {Object} data 消息内容/message content
   * @param {Number} data.index 表情索引/face index
   * @param {String} data.data 额外数据/extra data
   * @returns {Promise}
   */
  public sendFaceMessage(data: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions(data, 'face');
        const message = this.TUICore.tim.createFaceMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送图片消息
   * Send image message
   *
   * @param {Image} image 图片文件/image
   * @returns {Promise}
   */
  public sendImageMessage(image: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions({ file: image }, 'file', (progress: number) => {
          this.handleUploadProgress(progress, message);
        });
        const message = this.TUICore.tim.createImageMessage(options);
        message.progress = 0.01;
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送视频消息
   * Send video message
   *
   * @param {Video} video 视频文件/video
   * @returns {Promise}
   */
  public sendVideoMessage(video: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions({ file: video }, 'file', (progress: number) => {
          this.handleUploadProgress(progress, message);
        });
        const message = this.TUICore.tim.createVideoMessage(options);
        message.progress = 0.01;
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);

        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送文件消息
   * Send file message
   *
   * @param {File} file 文件/file
   * @returns {Promise}
   */
  public sendFileMessage(file: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions({ file }, 'file', (progress: number) => {
          this.handleUploadProgress(progress, message);
        });
        const message = this.TUICore.tim.createFileMessage(options);
        message.progress = 0.01;
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送自定义消息
   * Send Custom message
   *
   * @param {Object} data 消息内容/message content
   * @param {String} data.data 自定义消息的数据字段/custom message data fields
   * @param {String} data.description 自定义消息的说明字段/custom message description fields
   * @param {String} data.extension 自定义消息的扩展字段/custom message extension fields
   * @returns {Promise}
   */
  public sendCustomMessage(data: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        data.data = JSON.stringify(data.data);
        const options = this.handleMessageOptions(data, 'custom');
        const message = this.TUICore.tim.createCustomMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送地理位置消息
   * Send location message
   *
   * @param {Object} data 消息内容/message content
   * @param {String} data.description 地理位置描述信息/geographic descriptive information
   * @param {Number} data.longitude 经度/longitude
   * @param {Number} data.latitude 纬度/latitude
   * @returns {Promise}
   */
  public sendLocationMessage(data: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions(data, 'location');
        const message = this.TUICore.tim.createLocationMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 转发消息
   * forward message
   *
   * @param {message} message 消息实例/message
   * @param {any} to 转发的对象/forward to
   * @returns {Promise}
   */
  public forwardMessage(message: any, to: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions(message, 'forward', {}, to);
        const imMessage = this.TUICore.tim.createForwardMessage(options);
        const imResponse = await this.TUICore.tim.sendMessage(imMessage);
        if (this.store.conversation.conversationID === imResponse.data.message.conversationID) {
          this.currentStore.messageList.push(imResponse.data.message);
        }
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送消息已读回执
   * Send message read receipt
   *
   * @param {Array} messageList 同一个 C2C 或 GROUP 会话的消息列表，最大长度为30/A list of messages for the same C2C or GROUP conversation, with a maximum length of 30
   * @returns {Promise}
   */
  public async sendMessageReadReceipt(messageList: Array<any>) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse: any = await this.TUICore.tim.sendMessageReadReceipt(messageList);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 拉取已读回执列表
   * Pull read receipt list
   *
   * @param {Array} messageList 同一群会话的消息列表/The message list of the same group of the conversation
   * @returns {Promise}
   */
  public async getMessageReadReceiptList(messageList: Array<any>) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse: any = await this.TUICore.tim.getMessageReadReceiptList(messageList);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                 对外方法
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 获取 messageList
   * get messagelist
   *
   * @param {any} options 获取 messageList 参数/messageList options
   * @param {Boolean} history  是否获取历史消息/Whether to get historical information
   * @returns {Promise}
   */
  public async getMessageList(options: any, history?: boolean) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getMessageList(options);
        if (imResponse.data.messageList.length) {
          await this.getMessageReadReceiptList(imResponse.data.messageList);
        }
        if (!history) {
          this.currentStore.messageList = imResponse.data.messageList;
        } else {
          this.currentStore.messageList = [...imResponse.data.messageList, ...this.currentStore.messageList];
        }
        this.currentStore.nextReqMessageID = imResponse.data.nextReqMessageID;
        this.currentStore.isCompleted = imResponse.data.isCompleted;

        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取历史消息
   * get history messagelist
   *
   * @returns {Promise}
   */
  public async getHistoryMessageList() {
    const options = {
      conversationID: this.currentStore.conversation.conversationID,
      nextReqMessageID: this.currentStore.nextReqMessageID,
      count: 15,
    };
    if (!this.currentStore.isCompleted) {
      this.getMessageList(options, true);
    }
  }

  /**
   * 发送文本消息
   * send text message
   *
   * @param {any} text 发送的消息/text message
   * @param {object} data 被引用消息的内容/The content of the quoted message
   * @returns {Promise}
   */
  public sendTextMessage(text: any, data: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions({ text }, 'text');
        let cloudCustomDataObj = {};
        if (options.cloudCustomData) {
          try {
            cloudCustomDataObj = JSONToString(options.cloudCustomData);
          } catch {
            cloudCustomDataObj = {};
          }
        }
        const cloudCustomData = JSON.stringify(data);
        const secondOptions = Object.assign(options, { cloudCustomData, ...cloudCustomDataObj });
        const message = this.TUICore.tim.createTextMessage(secondOptions);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送【对方正在输入中】在线自定义消息
   * send typing online custom message
   *
   * @param {Object} data 消息内容/message content
   * @param {String} data.data 自定义消息的数据字段/custom message data field
   * @param {String} data.description 自定义消息的说明字段/custom message description field
   * @param {String} data.extension 自定义消息的扩展字段/custom message extension field
   * @returns {Promise}
   */
  public sendTypingMessage(data: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        data.data = JSON.stringify(data.data);
        const options = this.handleMessageOptions(data, 'custom');
        const message = this.TUICore.tim.createCustomMessage(options);
        const imResponse = await this.TUICore.tim.sendMessage(message, { onlineUserOnly: true });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送@ 提醒功能的文本消息
   * Send @ Reminder text message
   *
   * @param {any} data 消息内容/message content
   * @param {String} data.text 文本消息/text message
   * @param {Array} data.atUserList 需要 @ 的用户列表，如果需要 @ALL，请传入 TIM.TYPES.MSG_AT_ALL / List of users who need @, if you need @ALL, please pass in TIM.TYPES.MSG_AT_ALL
   * @returns {message}
   *
   * - 注：此接口仅用于群聊/This interface is only used for group chat
   */
  public sendTextAtMessage(data: any) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions(data, 'text');
        const message = this.TUICore.tim.createTextAtMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 发送合并消息
   * send merger message
   *
   * @param {Object} data 消息内容/message content
   * @param {Array.<Message>} data.messageList 合并的消息列表/merger message list
   * @param {String} data.title 合并的标题/merger title
   * @param {String} data.abstractList 摘要列表，不同的消息类型可以设置不同的摘要信息/Summary list, different message types can set different summary information
   * @param {String} data.compatibleText 兼容文本/ompatible text
   * @returns {Promise}
   */
  public sendMergerMessage(data: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const options = this.handleMessageOptions(data, 'merger');
        const message = this.TUICore.tim.createMergerMessage(options);
        this.currentStore.messageList.push(message);
        const imResponse = await this.TUICore.tim.sendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.map((item: any) => {
          if (item.ID === imResponse.data.message.ID) {
            return imResponse.data.message;
          }
          return item;
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 消息撤回
   * revoke message
   *
   * @param {message} message 消息实例/message
   * @returns {Promise}
   */
  public revokeMessage(message: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.revokeMessage(message);
        resolve(imResponse);
      } catch (error) {
        reject(error);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      }
    });
  }

  /**
   * 重发消息
   * resend message
   *
   * @param {message} message 消息实例/message
   * @returns {Promise}
   */
  public resendMessage(message: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.resendMessage(message);
        this.currentStore.messageList = this.currentStore.messageList.filter((item: any) => item.ID !== message.ID);
        this.currentStore.messageList.push(imResponse.data.message);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 删除消息
   * delete message
   *
   * @param {Array.<message>} messages 消息实例/message
   * @returns {Promise}
   */
  public deleteMessage(messages: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.deleteMessage(messages);
        resolve(imResponse);
        const middleData = this.currentStore.messageList;
        this.currentStore.messageList = [];
        this.currentStore.messageList = middleData;
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群组属性
   * get group profile
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.groupProfileFilter 群资料过滤器
   * @returns {Promise}
   */
  public getGroupProfile(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupProfile(options);
        this.currentStore.conversation.groupProfile = imResponse.data.group;
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群成员资料
   * get group member profile
   *
   * @param {any} options 参数
   * @param {String} options.groupID 群组ID
   * @param {Array.<String>} options.userIDList 要查询的群成员用户 ID 列表
   * @param {	Array.<String>} options.memberCustomFieldFilter 群成员自定义字段筛选
   * @returns {Promise}
   */
  public getGroupMemberProfile(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupMemberProfile(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 处理申请加群
   * handling group application
   * - 管理员
   *   administrator
   *
   * @param {any} options 参数
   * @param {String} options.handleAction 处理结果 Agree(同意) / Reject(拒绝)
   * @param {String} options.handleMessage 附言
   * @param {Message} options.message 对应【群系统通知】的消息实例
   * @returns {Promise}
   */
  public handleGroupApplication(options: any): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.handleGroupApplication(options);
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取其他用户资料
   * get user profile
   *
   * @param {Array<string>} userIDList 用户的账号列表/userID list
   * @returns {Promise}
   */
  public async getUserProfile(userIDList: Array<string>) {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getUserProfile({ userIDList });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取 SDK 缓存的好友列表
   * Get the friend list cached by the SDK
   *
   * @param {Array<string>} userIDList 用户的账号列表
   * @returns {Promise}
   */
  public async getFriendList(): Promise<void> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getFriendList();
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群消息已读成员列表
   * Get the list of memebers who have read the group message.
   *
   * @param {message} message 消息实例/message
   * @param {string} cursor 分页拉取的游标，第一次拉取传''/Paging pull the cursor,first pull pass ''
   * @param {number} count 分页拉取的个数/The number of page pulls
   * @returns {Promise}
   */
  public async getGroupReadMemberList(message: any, cursor = '', count = 15): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupMessageReadMemberList({
          message,
          filter: 0,
          cursor,
          count,
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * 获取群消息未读成员列表
   * Get the list of memebers who have not read the group message.
   *
   * @param {message} message 消息实例/message
   * @param {string} cursor 分页拉取的游标，第一次拉取传''/Paging pull the cursor,first pull pass ''
   * @param {number} count 分页拉取的个数/The number of page pulls
   * @returns {Promise}
   */
  public async getGroupUnreadMemberList(message: any, cursor = '', count = 15): Promise<any> {
    return this.handlePromiseCallback(async (resolve: any, reject: any) => {
      try {
        const imResponse = await this.TUICore.tim.getGroupMessageReadMemberList({
          message,
          filter: 1,
          cursor,
          count,
        });
        resolve(imResponse);
      } catch (error) {
        reject(error);
      }
    });
  }

  /**
   * /////////////////////////////////////////////////////////////////////////////////
   * //
   * //                                    UI 数据绑定server数据同步
   * //                           UI data binding server data synchronization
   * //
   * /////////////////////////////////////////////////////////////////////////////////
   */

  /**
   * 赋值
   * bind
   *
   * @param {Object} params 使用的数据/params
   * @returns {Object} 数据/data
   */
  public bind(params: any) {
    return (this.currentStore = params);
  }
}
