import {
  V2TIMManager,
  V2TIMMessage,
  V2TIMMessagePriority,
  V2TIMMessageStatus,
  V2TIMMessageGetType,
  V2TIMElemType,
  V2TIMImageType,
  V2TIMMessageReactionChangeInfo,
  V2TIMGroupTipsType,
  V2TIMMessageReceipt,
  V2TIMUserInfo,
  V2TIMGroupMemberInfo,
  V2TIMMessageReaction,
  V2TIMMessageReactionResult,
  V2TIMMessageListGetOption,
  V2TIMAdvancedMsgListener,
} from '@tencentcloud/imsdk'

import util from '@ohos.util'
import fs from '@ohos.file.fs'
import { Util } from './Util'
import { ChatEngine, ErrorResult } from './ChatEngine'
import { MessageActionNotifyKey } from './MessageActionState'
import { MessageSendNotifyKey, MessageCustomInfoKey } from './MessageInputState'
import CommonData from '../datasource/CommonData'
import MessageDataSource from '../datasource/MessageDataSource'
import fileio from '@ohos.fileio'
import notificationCenter from './NotificationCenter'

////////////////////////////////////////////////////////////
// Data
////////////////////////////////////////////////////////////

export enum MessageStatus {
  initStatus = 0,
  sending,
  sendSuccess,
  sendFail,
  revoked,
  deleted,
  localImported,
  violation
}

export enum MessageType {
  Unknown = 0,
  Text,
  Image,
  Video,
  Sound,
  File,
  Face,
  System,
  Custom
}

export interface MessageReaction {
  // id 用于 MessageReaction 更新的唯一标识, 这里设置为 reactionID
  id: string;
  resourcePath?: string;
  reactedByMyself?: boolean;
  totalUserCount?: number;
}

/**
 * 回复消息信息类
 */
@Observed
export class MessageReplyInfo {
  msgID?: string;
  msgSender?: string;
  msgAbstract?: string;
  msgStatus?: MessageStatus;
  messageType?: MessageType;
  messageBody?: MessageBody;

  constructor() {
    // 初始化属性
  }
}

// 首先定义一些具体的类型接口，用于替代any
export interface MessageReplyContent {
  messageID: string;
  messageAbstract: string;
  messageSender: string;
  messageType?: number;
  messageTime?: number;
  messageSeq?: number;
  messagePriority?: number;
  messageStatus?: number;
  messageExt?: string;
}

export interface RepliesContent {
  replies: MessageReplyContent[];
  count?: number;
  timestamp?: number;
  title?: string;
  version?: string;
}

export interface CustomMessageContent {
  text?: string;
  imageUrl?: string;
  data?: string | number;
  customField?: string;
  type?: string;
  size?: number;
  width?: number;
  height?: number;
  duration?: number;
  url?: string;
  replies?: RepliesContent;
  customData?: Record<string, string | number>;
  customConfig?: Record<string, string | number>;
}

export interface CloudCustomData {
  // 使用明确的属性名定义，而不是计算属性
  reply?: Record<string, string | number>;
  replies?: RepliesContent;

  // 增加其他可能的属性
  customExtension?: Record<string, string | number | boolean>;
  additionalInfo?: Record<string, string | number | boolean>;
}

/**
 * 消息信息类
 */
@Observed
export class MessageInfo extends CommonData {
  //sender 和 receiver
  sender?: string;
  isSelf?: boolean;
  receiver?: string;
  groupID?: string;
  dateTime?: Date;
  status?: MessageStatus;
  progress?: number; //(0-100)

  //Message Type
  messageType?: MessageType;
  //Message Body
  messageBody?: MessageBody;
  //Message read count
  readCount?: number;
  unreadCount?: number;
  //Message emoji
  reactions?: MessageReaction[];
  //Reply Message
  replyMessageInfo?: MessageReplyInfo;
  repliedMessageCount?: number;
  //Quote Message
  quoteMessageInfo?: MessageReplyInfo;
  //IM Message
  imMessage?: V2TIMMessage;
}

/**
 * 消息体类
 */
@Observed
export class MessageBody {
  //Text Message
  text?: string;
  //Image Message
  originalImagePath?: string;
  originalImageWidth?: number;
  originalImageHeight?: number;
  originalImageSize?: number;
  thumbImagePath?: string;
  largeImagePath?: string;
  //Video Message
  videoPath?: string;
  videoType?: string;
  videoSize?: number;
  videoDuration?: number;
  videoSnapshotPath?: string;
  videoSnapshotWidth?: number;
  videoSnapshotHeight?: number;
  videoSnapshotSize?: number;
  //Sound Message
  soundPath?: string;
  soundSize?: number;
  soundDuration?: number;
  isSoundPlayed?: boolean;
  //File Message
  filePath?: string;
  fileName?: string;
  fileSize?: number;
  //Face Message
  faceIndex?: number;
  faceName?: string;
  //System Message
  systemInfo?: string | Resource;
  //Custom Message
  customInfo?: CustomMessageContent;

  constructor() {
    // 初始化属性
  }
}

export enum MessageListType {
  history,
  pinned,
  replied,
  merged
}

export class MessageGetDirection {
  static readonly Older: number = 0x1;
  static readonly Newer: number = 0x1 << 1;
}

export class MessageFilterType {
  static readonly All: number = 0x1;
  // 消息列表中点击图片或视频，会出现个左右滑动的 UI 界面，该界面只需要加载图片和视频消息
  static readonly Image: number = 0x1 << 1;
  static readonly Video: number = 0x1 << 2;
}

export interface MessageGetOption {
  message?: MessageInfo;
  messageSeq?: number;
  direction?: number;
  filterType?: number;
  pageCount?: number;
}

export enum MessageResourceType {
  thumbImage = 0,
  largeImage,
  originalImage,
  videoSnapshot,
  video,
  sound,
  file
}

// 消息列表变化来源
// UI 上一般会根据消息列表变化来源来决定消息列表的滑动状态
// 1. 当 fetchMessages 时，消息列表一般会滑动到底部，并且不需要动画
// 2. 当 loadMoreMessages 时，消息列表一般不需要滑动
// 3. 当 sendMessage 时，消息列表一般会滑动到底部，并且需要动画
// 4. 当 recvMessage 时，消息列表一般会滑动到底部，并且需要动画
// 5. 当 deleteMessage 时，消息列表一般不需要滑动
export enum MessageListChangeSource {
  unknown = 0,
  fetchMessages,
  loadMoreMessages,
  sendMessage,
  recvMessage,
  deleteMessage,
  revokeMessage
}

////////////////////////////////////////////////////////////
// Message List State
////////////////////////////////////////////////////////////
interface GeneratedTypeLiteralInterface_1 {
  filePath: string;
  exists: boolean;
}

@Observed
export class MessageListState {
  // State 响应式数据
  messageDataSource: MessageDataSource = new MessageDataSource();
  messageListChangeSource?: MessageListChangeSource = MessageListChangeSource.unknown;
  hasMoreOlderMessage?: boolean = false;
  hasMoreNewerMessage?: boolean = false;
  enableReadReceipt?: boolean = false;
  conversationID: string = "";
  messageListType?: MessageListType = MessageListType.history;
  dateMessage?: MessageInfo;
  option?: MessageGetOption;
  listener?: V2TIMAdvancedMsgListener;
  // 消息列表变化来源回调
  onMessageListChangeSourceChanged?: (changeSource: MessageListChangeSource) => void;

  constructor(conversationID: string, messageListType: MessageListType) {
    this.conversationID = conversationID;
    this.messageListType = messageListType;
    this.addListener();
  }

  /**
   * 提供 messageList 属性以兼容现有代码
   * @returns 消息列表
   */
  get messageList(): MessageInfo[] {
    return this.messageDataSource.messageList;
  }

  // State 操作接口
  // messageListType 为 history 时，option 不能为 nil
  // messageListType 为 pinned 时，option 为 nil
  // messageListType 为 replied 时，option 不能为 nil, 且 option 中的 message 不能为 nil

  // messageListType 为 merged 时，option 不能为 nil, 且 option 中的 message 不能为 nil
  public fetchMessages(option?: MessageGetOption): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.fetchMessagesInternal(option)
        .then(() => {
          resolve();
        })
        .catch((error: object) => {
          reject(error);
        });
    });
  }

  public loadMoreMessages(direction: number): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.loadMoreMessagesInternal(direction)
        .then(() => {
          resolve();
        })
        .catch((error: object) => {
          reject(error);
        });
    });
  }

  public downloadMessageResource(message: MessageInfo, resourceType: MessageResourceType): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.downloadMessageResourceInternal(message, resourceType)
        .then(() => {
          resolve();
        })
        .catch((error: object) => {
          reject(error);
        });
    });
  }

  addListener() {
    // 使用notificationCenter代替emitter

    this.listener = {
      onRecvNewMessage: (msg: V2TIMMessage) => {
        this.onRecvNewMessage(msg);
      },
      onRecvMessageReadReceipts: (receiptList: V2TIMMessageReceipt[]) => {
        this.onRecvMessageReadReceipts(receiptList);
      },
      onRecvMessageRevoked: (msgID: string, operateUser: V2TIMUserInfo, reason?: string) => {
        this.onRecvMessageRevoked(msgID, operateUser, reason);
      },
      onRecvMessageModified: (msg: V2TIMMessage) => {
        this.onRecvMessageModified(msg);
      },
      onRecvMessageReactionsChanged: (changeList: V2TIMMessageReactionChangeInfo[]) => {
        this.onRecvMessageReactionsChanged(changeList);
      },
      onRecvMessageExtensionsDeleted: (msgID: string, extensionKeys: string[]) => {
        this.onRecvMessageExtensionsDeleted(msgID, extensionKeys);
      },
      onGroupMessagePinned: (groupID: string, message: V2TIMMessage, isPinned: Boolean,
        opUser: V2TIMGroupMemberInfo) => {
        this.onGroupMessagePinned(groupID, message, isPinned, opUser);
      }
    }

    // 注册消息发送相关的事件监听
    notificationCenter.addObserver(MessageSendNotifyKey.SEND_BEGIN, this, (data: Object) => {
      this.onRecvMessageSendBegin(data);
    });

    notificationCenter.addObserver(MessageSendNotifyKey.SEND_PROGRESS, this, (data: Object) => {
      this.onRecvMessageSendProgress(data);
    });

    notificationCenter.addObserver(MessageSendNotifyKey.SEND_SUCCESS, this, (data: Object) => {
      this.onRecvMessageSendSuccess(data);
    });

    notificationCenter.addObserver(MessageSendNotifyKey.SEND_FAILED, this, (data: Object) => {
      this.onRecvMesssageSendFailed(data);
    });

    // 注册消息操作相关的事件监听
    notificationCenter.addObserver(MessageActionNotifyKey.DELETE_MESSAGE, this, (data: Object) => {
      this.onRecvMessageDelete(data);
    });

    notificationCenter.addObserver(MessageActionNotifyKey.REVOKE_MESSAGE, this, (data: Object) => {
      this.onRecvMessageRevoke(data);
    });

    notificationCenter.addObserver(MessageActionNotifyKey.EDIT_MESSAGE, this, (data: Object) => {
      this.onRecvMessageEdit(data);
    });

    notificationCenter.addObserver(MessageActionNotifyKey.PIN_MESSAGE, this, (data: Object) => {
      this.onRecvMessagePin(data);
    });

    notificationCenter.addObserver(MessageActionNotifyKey.UNPIN_MESSAGE, this, (data: Object) => {
      this.onRecvMessageUnpin(data);
    });

    // 添加消息高级监听器
    V2TIMManager.getMessageManager().addAdvancedMsgListener(this.listener);
  }

  async fetchMessagesInternal(option?: MessageGetOption): Promise<void> {
    this.option = option;

    // 根据消息列表类型加载对应消息
    try {
      let result: void;
      switch (this.messageListType) {
        case MessageListType.history:
          if (!option) {
            return Promise.reject({ code: -1, message: "Message option not found" });
          }
          this.hasMoreOlderMessage = true;
          this.hasMoreNewerMessage = true;
          result = await this.fetchHistoryMessageList(option);
          break;
        case MessageListType.pinned:
          result = await this.fetchPinnedMessageList();
          break;
        case MessageListType.replied:
          if (!option?.message) {
            return Promise.reject({ code: -1, message: "Message not found for operation" });
          }
          result = await this.fetchRepliedMessageList(option.message);
          break;
        case MessageListType.merged:
          if (!option?.message) {
            return Promise.reject({ code: -1, message: "Message not found for operation" });
          }
          result = await this.fetchMergedMessageList(option.message);
          break;
      }

      // 补齐消息已读回执和表情回复信息
      this.setMessageListChangeSource(MessageListChangeSource.fetchMessages);
      if (this.enableReadReceipt) {
        await this.fetchMessageReadReceipts();
      }
      await this.fetchMessageReactions();
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }

  async fetchHistoryMessageList(option: MessageGetOption): Promise<void> {
    if (option.direction === MessageGetDirection.Older || option.direction === MessageGetDirection.Newer) {
      return this.fetchOneSideMessageList(option);
    } else {
      return this.fetchTwoSideMessageList(option);
    }
  }

  async loadMoreMessagesInternal(direction: number): Promise<void> {
    if (!this.option) {
      return Promise.reject({ code: -1, message: "Please call fetchMessagesInternal first" });
    }

    let option: MessageGetOption = {};
    // 鸿蒙不支持展开运算符，需要手动复制属性
    if (this.option.message) {
      option.message = this.option.message;
    }
    if (this.option.messageSeq !== undefined) {
      option.messageSeq = this.option.messageSeq;
    }
    if (this.option.filterType !== undefined) {
      option.filterType = this.option.filterType;
    }
    if (this.option.pageCount !== undefined) {
      option.pageCount = this.option.pageCount;
    }


    if (direction === MessageGetDirection.Older) {
      if (!this.hasMoreOlderMessage) {
        return Promise.reject({ code: -1, message: "No more older message" });
      }

      // 查找第一条包含imMessage的消息，而不是简单地获取索引为0的消息
      let firstMessageWithImMessage: MessageInfo | undefined = undefined;

      // 遍历查找第一条包含imMessage的消息
      for (let i = 0; i < this.messageDataSource.totalCount(); i++) {
        const msg = this.messageDataSource.getData(i);
        if (msg && msg.imMessage) {
          firstMessageWithImMessage = msg;
          break;
        }
      }

      // 如果没有找到包含imMessage的消息，则返回错误
      if (!firstMessageWithImMessage) {
        return Promise.reject({ code: -1, message: "No more older message" });
      }

      option.message = firstMessageWithImMessage;
    }

    if (direction === MessageGetDirection.Newer) {
      if (!this.hasMoreNewerMessage) {
        return Promise.reject({ code: -1, message: "No more newer message" });
      }

      // 使用 messageDataSource 获取所有包含 imMessage 的消息
      const messages: MessageInfo[] = [];
      for (let i = 0; i < this.messageDataSource.totalCount(); i++) {
        const msg = this.messageDataSource.getData(i);
        if (msg && msg.imMessage) {
          messages.push(msg);
        }
      }

      const message = messages.length > 0 ? messages[messages.length - 1] : undefined;

      if (!message) {
        return Promise.reject({ code: -1, message: "No more newer message" });
      }
      option.message = message;
    }

    option.direction = direction;

    try {
      await this.fetchOneSideMessageList(option);
      this.setMessageListChangeSource(MessageListChangeSource.loadMoreMessages);
      if (this.enableReadReceipt) {
        await this.fetchMessageReadReceipts();
      }
      await this.fetchMessageReactions();
      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }

  async fetchOneSideMessageList(option: MessageGetOption): Promise<void> {
    const getOption: V2TIMMessageListGetOption = {
      userID: Util.getUserID(this.conversationID) ?? undefined,
      groupID: Util.getGroupID(this.conversationID) ?? undefined,
      lastMsg: option.message?.imMessage,
      count: option.pageCount || 20,
      messageTypeList: this.getMessageTypeList(option),
      getType: V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG
    };

    if (option.direction === MessageGetDirection.Newer) {
      getOption.getType = getOption.messageTypeList && getOption.messageTypeList.length > 0 ?
      V2TIMMessageGetType.V2TIM_GET_LOCAL_NEWER_MSG :
      V2TIMMessageGetType.V2TIM_GET_CLOUD_NEWER_MSG;
    } else if (option.direction === MessageGetDirection.Older) {
      getOption.getType = getOption.messageTypeList && getOption.messageTypeList.length > 0 ?
      V2TIMMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG :
      V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG;
    }

    try {
      const msgs = await V2TIMManager.getMessageManager().getHistoryMessageList(getOption);
      // 在ArkTS中，我们需要创建一个新数组来反转，而不是使用reverse()方法，因为它可能会修改原始数组
      const reversedMsgs = [...msgs].reverse();
      const copyMsgs = [...msgs];
      if (option.direction === MessageGetDirection.Older) {
        const tuiMsgs = this.convertToUIMessageList(reversedMsgs);
        this.messageDataSource.insertData(0, tuiMsgs, false);
      } else {
        const tuiMsgs = this.convertToUIMessageList(copyMsgs);
        this.messageDataSource.addData(tuiMsgs, true);
      }

      if (option.direction === MessageGetDirection.Newer) {
        if (msgs.length < (option.pageCount || 20)) {
          this.hasMoreNewerMessage = false;
        }
      } else {
        if (msgs.length < (option.pageCount || 20)) {
          this.hasMoreOlderMessage = false;
        }
      }

      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }

  async fetchTwoSideMessageList(option: MessageGetOption): Promise<void> {
    let olderMsgs: V2TIMMessage[] = [];
    let newerMsgs: V2TIMMessage[] = [];
    const messageTypeList = this.getMessageTypeList(option);

    try {
      // Load the oldest pageCount messages starting from locating message
      const oldOption: V2TIMMessageListGetOption = {
        groupID: Util.getGroupID(this.conversationID) ?? undefined,
        userID: Util.getUserID(this.conversationID) ?? undefined,
        count: option.pageCount || 20,
        lastMsg: option.message?.imMessage,
        lastMsgSeq: option.messageSeq,
        messageTypeList: messageTypeList,
        getType: messageTypeList && messageTypeList.length > 0 ?
        V2TIMMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG :
        V2TIMMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG
      };

      const olderResult = await V2TIMManager.getMessageManager().getHistoryMessageList(oldOption);
      // 在ArkTS中，我们需要创建一个新数组来反转，而不是使用reverse()方法
      olderMsgs = [...olderResult].reverse();
      if (olderMsgs.length < (option.pageCount || 20)) {
        this.hasMoreOlderMessage = false;
      }

      // Load the latest pageCount messages starting from the locating message
      const newOption: V2TIMMessageListGetOption = {
        groupID: Util.getGroupID(this.conversationID) ?? undefined,
        userID: Util.getUserID(this.conversationID) ?? undefined,
        count: option.pageCount || 20,
        lastMsg: option.message?.imMessage,
        lastMsgSeq: option.messageSeq,
        messageTypeList: messageTypeList,
        getType: messageTypeList && messageTypeList.length > 0 ?
        V2TIMMessageGetType.V2TIM_GET_LOCAL_NEWER_MSG :
        V2TIMMessageGetType.V2TIM_GET_CLOUD_NEWER_MSG
      };

      const newerResult = await V2TIMManager.getMessageManager().getHistoryMessageList(newOption);
      newerMsgs = newerResult;
      if (newerMsgs.length < (option.pageCount || 20)) {
        this.hasMoreNewerMessage = false;
      }

      let results: V2TIMMessage[] = [];
      results.push(...olderMsgs);
      if (option.message?.imMessage) {
        results.push(option.message.imMessage);
      } else {
        if (results.length > 0) {
          // 移除最后一个消息，类似于Swift中的removeLast()
          results.pop();
        }
      }
      results.push(...newerMsgs);

      // 清空当前消息列表
      // 使用 messageDataSource 代替直接操作数组
      const reversedResults = [...results].reverse();
      const uiMessages = this.convertToUIMessageList(reversedResults);
      this.messageDataSource.setData(uiMessages);
      this.setMessageListChangeSource(MessageListChangeSource.fetchMessages);

      return Promise.resolve();
    } catch (error) {
      return Promise.reject(error);
    }
  }

  async fetchMessageReadReceipts(): Promise<void> {
    // 从 messageDataSource 中获取所有消息
    const imMessageList: V2TIMMessage[] = [];
    for (let i = 0; i < this.messageDataSource.totalCount(); i++) {
      const message = this.messageDataSource.getData(i);
      if (message && message.imMessage) {
        imMessageList.push(message.imMessage);
      }
    }

    if (imMessageList.length === 0) {
      return;
    }

    try {
      const resultList: V2TIMMessageReceipt[] =
        await V2TIMManager.getMessageManager().getMessageReadReceipts(imMessageList);
      for (const result of resultList) {
        const index = this.messageDataSource.getIndex(result.msgID);
        if (index !== -1) {
          // 获取消息引用
          const message = this.messageDataSource.getData(index);
          if (message) {
            // 直接修改原对象的属性
            message.readCount = result.readCount;
            message.unreadCount = result.unreadCount;
            // 通知数据源有变化
            this.messageDataSource.notifyDataChange(index);
          }
        }
      }
    } catch (error) {
      console.error("fetchMessageReadReceipts fail:", error);
      // 不中断流程，即使失败也继续
    }
  }

  async fetchMessageReactions(): Promise<void> {
    // 从 messageDataSource 中获取所有消息
    const imMessageList: V2TIMMessage[] = [];
    for (let i = 0; i < this.messageDataSource.totalCount(); i++) {
      const message = this.messageDataSource.getData(i);
      if (message && message.imMessage) {
        imMessageList.push(message.imMessage);
      }
    }

    if (imMessageList.length === 0) {
      return;
    }
    try {
      const result = await V2TIMManager.getMessageManager().getMessageReactions(imMessageList, 5);
      for (const reaction of result.reactionList) {
        const index = this.messageDataSource.getIndex(result.msgID);
        if (index !== -1) {
          // 获取消息引用
          const message = this.messageDataSource.getData(index);
          if (message) {
            // 直接修改原对象的属性
            message.reactions = this.convertToUIMessageReactionList([reaction]);
            // 通知数据源有变化
            this.messageDataSource.notifyDataChange(index);
          }
        }
      }
    } catch (error) {
      console.error("fetchMessageReactions fail:", error);
      // 不中断流程，即使失败也继续
    }
  }

  getMessageTypeList(option: MessageGetOption): V2TIMElemType[] {
    const messageTypeList: V2TIMElemType[] = [];
    if (option.filterType === MessageFilterType.Image) {
      messageTypeList.push(V2TIMElemType.V2TIM_ELEM_TYPE_IMAGE);
    }
    if (option.filterType === MessageFilterType.Video) {
      messageTypeList.push(V2TIMElemType.V2TIM_ELEM_TYPE_VIDEO);
    }
    return messageTypeList;
  }

  async fetchPinnedMessageList(): Promise<void> {
    try {
      const messageList = await V2TIMManager.getMessageManager().getPinnedGroupMessageList(this.conversationID);
      const uiMessages = this.convertToUIMessageList(messageList);
      this.messageDataSource.setData(uiMessages);
      this.setMessageListChangeSource(MessageListChangeSource.fetchMessages);
    } catch (error) {
      console.error("fetchPinnedMessageList fail:", error);
    }
  }

  async fetchRepliedMessageList(message: MessageInfo): Promise<void> {
    // 检查messageBody和customInfo是否存在
    if (!message.messageBody?.customInfo) {
      console.error("Message custom info not found");
      return;
    }

    // 获取自定义消息内容
    const customInfo = message.messageBody.customInfo;

    // 使用类型安全的方式访问replies属性
    if (!customInfo.replies) {
      console.error("Reply information of the message not found");
      return;
    }

    // 确保replies属性内部有replies数组
    const repliesArray = customInfo.replies.replies;
    if (!repliesArray || repliesArray.length === 0) {
      console.error("No replies found in message");
      return;
    }

    const messageIDList: string[] = [];
    for (const param of repliesArray) {
      if (param.messageID && param.messageID !== "") {
        messageIDList.push(param.messageID);
      }
    }

    if (messageIDList.length === 0) {
      console.error("No valid message IDs found in replies");
      return;
    }

    try {
      const msgs = await V2TIMManager.getMessageManager().findMessages(messageIDList);
      const uiMessages = this.convertToUIMessageList(msgs);
      this.messageDataSource.setData(uiMessages);
      this.setMessageListChangeSource(MessageListChangeSource.fetchMessages);
    } catch (error) {
      console.error("fetchRepliedMessageList fail:", error);
    }
  }

  async fetchMergedMessageList(message: MessageInfo): Promise<void> {
    if (!message.imMessage?.mergerElem) {
      console.error("Message not found for operation");
      return; // 使用返回代替throw
    }

    try {
      const msgs = await message.imMessage.mergerElem.downloadMergerMessage();
      const uiMessages = this.convertToUIMessageList(msgs);
      this.messageDataSource.setData(uiMessages);
      this.setMessageListChangeSource(MessageListChangeSource.fetchMessages);
    } catch (error) {
      console.error("fetchMergedMessageList fail:", error);
    }
  }

  async downloadMessageResourceInternal(message: MessageInfo, resourceType: MessageResourceType): Promise<void> {
    if (!message.imMessage) {
      return Promise.reject({ code: -1, message: "Message not found for operation" });
    }

    const messageID = message.ID;

    // 通用方法：更新消息体路径并通知数据变化
    const updateMessagePath = (index: number, path: string, updateField: string) => {
      if (index === -1) {
        return;
      }

      const foundMessage = this.messageDataSource.getData(index);
      if (!foundMessage || !foundMessage.messageBody) {
        return;
      }

      // 使用formatFilePath方法处理路径
      path = this.formatFilePath(path);

      // 动态更新指定字段
      if (updateField === 'thumbImagePath') {
        foundMessage.messageBody.thumbImagePath = path;
      } else if (updateField === 'largeImagePath') {
        foundMessage.messageBody.largeImagePath = path;
      } else if (updateField === 'originalImagePath') {
        foundMessage.messageBody.originalImagePath = path;
      } else if (updateField === 'videoPath') {
        foundMessage.messageBody.videoPath = path;
      } else if (updateField === 'videoSnapshotPath') {
        foundMessage.messageBody.videoSnapshotPath = path;
      } else if (updateField === 'soundPath') {
        foundMessage.messageBody.soundPath = path;
      } else if (updateField === 'filePath') {
        foundMessage.messageBody.filePath = path;
      }

      // 更新进度
      foundMessage.progress = 100;

    };

    // 通用方法：处理下载失败
    const handleDownloadFailure = (index: number, error: object) => {
      if (index === -1) {
        return;
      }

      const foundMessage = this.messageDataSource.getData(index);
      if (!foundMessage) {
        return;
      }

      // 设置进度为0（失败）
      foundMessage.progress = 0;
      console.error(`[MessageListState] Download failed for message ${messageID}, error:`, error);
    };

    // 获取消息在列表中的索引
    const index = this.messageDataSource.getIndex(messageID);

    switch (resourceType) {
      // 图片类型处理
      case MessageResourceType.thumbImage: {
        if (!message.imMessage.imageElem?.imageList) {
          return Promise.reject({ code: -1, message: "Image element not found" });
        }

        for (const image of message.imMessage.imageElem.imageList) {
          if (image.type === V2TIMImageType.V2TIM_IMAGE_TYPE_THUMB) {
            const result = this.getActualMediaPath(
              MessageType.Image,
              message.messageBody?.thumbImagePath,
              image.uuid,
              `${image.type}`
            );

            if (result.exists) {
              updateMessagePath(index, result.filePath, 'thumbImagePath');
              return Promise.resolve();
            }

            try {
              await image.downloadImage(result.filePath);
              updateMessagePath(index, result.filePath, 'thumbImagePath');
              return Promise.resolve();
            } catch (error) {
              handleDownloadFailure(index, error);
              return Promise.reject(error);
            }
          }
        }
        break;
      }

      case MessageResourceType.largeImage: {
        if (!message.imMessage.imageElem?.imageList) {
          return Promise.reject({ code: -1, message: "Image element not found" });
        }

        for (const image of message.imMessage.imageElem.imageList) {
          if (image.type === V2TIMImageType.V2TIM_IMAGE_TYPE_LARGE) {
            const result = this.getActualMediaPath(
              MessageType.Image,
              message.messageBody?.largeImagePath,
              image.uuid,
              `${image.type}`
            );

            if (result.exists) {
              updateMessagePath(index, result.filePath, 'largeImagePath');
              return Promise.resolve();
            }

            try {
              await image.downloadImage(result.filePath);
              updateMessagePath(index, result.filePath, 'largeImagePath');
              return Promise.resolve();
            } catch (error) {
              handleDownloadFailure(index, error);
              return Promise.reject(error);
            }
          }
        }
        break;
      }

      case MessageResourceType.originalImage: {
        if (!message.imMessage.imageElem?.imageList) {
          return Promise.reject({ code: -1, message: "Image element not found" });
        }

        for (const image of message.imMessage.imageElem.imageList) {
          if (image.type === V2TIMImageType.V2TIM_IMAGE_TYPE_ORIGIN) {
            const result = this.getActualMediaPath(
              MessageType.Image,
              message.messageBody?.originalImagePath,
              image.uuid,
              `${image.type}`
            );

            if (result.exists) {
              updateMessagePath(index, result.filePath, 'originalImagePath');
              return Promise.resolve();
            }

            try {
              await image.downloadImage(result.filePath);
              updateMessagePath(index, result.filePath, 'originalImagePath');
              return Promise.resolve();
            } catch (error) {
              handleDownloadFailure(index, error);
              return Promise.reject(error);
            }
          }
        }
        break;
      }

    // 视频类型处理
      case MessageResourceType.videoSnapshot: {
        if (!message.imMessage.videoElem?.snapshotUUID) {
          return Promise.reject({ code: -1, message: "Video snapshot not found" });
        }

        const result = this.getActualMediaPath(
          MessageType.Video,
          message.messageBody?.videoSnapshotPath,
          message.imMessage.videoElem.snapshotUUID,
          undefined
        );

        if (result.exists) {
          updateMessagePath(index, result.filePath, 'videoSnapshotPath');
          return Promise.resolve();
        }

        try {
          await message.imMessage.videoElem.downloadSnapshot(result.filePath);
          updateMessagePath(index, result.filePath, 'videoSnapshotPath');
          return Promise.resolve();
        } catch (error) {
          handleDownloadFailure(index, error);
          return Promise.reject(error);
        }
      }

      case MessageResourceType.video: {
        if (!message.imMessage.videoElem?.videoUUID) {
          return Promise.reject({ code: -1, message: "Video not found" });
        }

        const result = this.getActualMediaPath(
          MessageType.Video,
          message.messageBody?.videoPath,
          message.imMessage.videoElem.videoUUID,
          message.imMessage.videoElem.videoPath?.split('.').pop() || "mp4"
        );

        if (result.exists) {
          updateMessagePath(index, result.filePath, 'videoPath');
          return Promise.resolve();
        }

        try {
          await message.imMessage.videoElem.downloadVideo(result.filePath);
          updateMessagePath(index, result.filePath, 'videoPath');
          return Promise.resolve();
        } catch (error) {
          handleDownloadFailure(index, error);
          return Promise.reject(error);
        }
      }

    // 语音类型处理
      case MessageResourceType.sound: {
        if (!message.imMessage.soundElem?.uuid) {
          return Promise.reject({ code: -1, message: "Sound not found" });
        }

        const result = this.getActualMediaPath(
          MessageType.Sound,
          message.messageBody?.soundPath,
          message.imMessage.soundElem.uuid,
          message.imMessage.soundElem.path?.split('.').pop() || "mp3"
        );

        if (result.exists) {
          updateMessagePath(index, result.filePath, 'soundPath');
          return Promise.resolve();
        }

        try {
          await message.imMessage.soundElem.downloadSound(result.filePath);
          updateMessagePath(index, result.filePath, 'soundPath');
          return Promise.resolve();
        } catch (error) {
          handleDownloadFailure(index, error);
          return Promise.reject(error);
        }
      }

    // 文件类型处理
      case MessageResourceType.file: {
        if (!message.imMessage.fileElem?.uuid) {
          return Promise.reject({ code: -1, message: "File not found" });
        }

        const result = this.getActualMediaPath(
          MessageType.File,
          message.messageBody?.filePath,
          message.imMessage.fileElem.uuid,
          ""
        );

        if (result.exists) {
          updateMessagePath(index, result.filePath, 'filePath');
          return Promise.resolve();
        }

        try {
          await message.imMessage.fileElem.downloadFile(result.filePath);
          updateMessagePath(index, result.filePath, 'filePath');
          return Promise.resolve();
        } catch (error) {
          handleDownloadFailure(index, error);
          return Promise.reject(error);
        }
      }

      default:
        return Promise.reject({ code: -1, message: "Unsupported resource type" });
    }

    return Promise.reject({ code: -1, message: "Resource not found" });
  }

  convertToUIMessageList(imMessages: V2TIMMessage[]): MessageInfo[] {
    const messageList: MessageInfo[] = [];
    for (const imMessage of imMessages) {
      const dateMessage = this.convertToUIDateMessage(imMessage.timestamp);
      if (dateMessage) {
        messageList.push(dateMessage);
      }
      const message = this.convertToUIMessage(imMessage);
      messageList.push(message);
    }
    return messageList;
  }

  convertToUIMessage(imMessage: V2TIMMessage): MessageInfo {
    const message = new MessageInfo();
    message.ID = imMessage.msgID;
    message.status = this.convertoUIMessageStatus(imMessage);
    message.sender = imMessage.sender;
    message.isSelf = (imMessage.sender === ChatEngine.getInstance().currentUserInfo?.userID);
    message.receiver = imMessage.userID;
    message.groupID = imMessage.groupID;
    message.dateTime = new Date(imMessage.timestamp);
    message.messageType = this.getMessageType(imMessage);
    message.messageBody = this.getMessageBody(imMessage);

    const quoteInfo = this.getQuoteMessage(imMessage);
    if (quoteInfo) {
      message.quoteMessageInfo = quoteInfo;
    }

    message.imMessage = imMessage;
    return message;
  }

  convertoUIMessageStatus(imMessage: V2TIMMessage): MessageStatus {
    if (imMessage.hasRiskContent) {
      return MessageStatus.violation;
    }

    switch (imMessage.status) {
      case V2TIMMessageStatus.V2TIM_MSG_STATUS_SENDING:
        return MessageStatus.sending;
      case V2TIMMessageStatus.V2TIM_MSG_STATUS_SEND_SUCC:
        return MessageStatus.sendSuccess;
      case V2TIMMessageStatus.V2TIM_MSG_STATUS_SEND_FAIL:
        return MessageStatus.sendFail;
      case V2TIMMessageStatus.V2TIM_MSG_STATUS_HAS_DELETED:
        return MessageStatus.deleted;
      case V2TIMMessageStatus.V2TIM_MSG_STATUS_LOCAL_IMPORTED:
        return MessageStatus.localImported;
      case V2TIMMessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED:
        return MessageStatus.revoked;
      default:
        return MessageStatus.initStatus;
    }
  }

  convertToUIDateMessage(date: Date | number): MessageInfo | undefined {
    // 将number类型的时间戳转换为Date对象
    const dateObj: Date = typeof date === 'number' ? new Date(date * 1000) : date;

    const maxDateDelay: number = 5 * 60 * 1000; // 5 minutes in milliseconds
    if (!this.dateMessage ||
      Math.abs(dateObj.getTime() - (this.dateMessage.dateTime?.getTime() || 0)) > maxDateDelay) {
      const message = new MessageInfo();
      message.ID = String(Math.floor(Math.random() * 100000)); // 模拟arc4random
      message.dateTime = dateObj;
      message.messageBody = new MessageBody();
      message.messageType = MessageType.System;

      // 确保messageBody已初始化后再访问
      message.messageBody.systemInfo = Util.convertDateToSeparatorInfo(dateObj);

      this.dateMessage = message;
      return message;
    }
    return undefined;
  }

  getMessageBody(imMessage: V2TIMMessage): MessageBody | undefined {
    // 消息被撤回
    if (imMessage.status === V2TIMMessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
      const messageBody: MessageBody = new MessageBody();
      messageBody.systemInfo = Util.getRevokeDispayString(imMessage, undefined, undefined);
      return messageBody;
    }

    // 消息类型
    switch (imMessage.elemType) {
      case V2TIMElemType.V2TIM_ELEM_TYPE_TEXT: {
        const messageBody: MessageBody = new MessageBody();
        messageBody.text = imMessage.textElem?.text;
        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_IMAGE: {
        if (!imMessage.imageElem) {
          break;
        }
        const messageBody: MessageBody = new MessageBody();
        if (imMessage.imageElem.path) {
          messageBody.originalImagePath = this.formatFilePath(imMessage.imageElem.path);
        }
        for (const image of imMessage.imageElem.imageList || []) {
          if (image.type === V2TIMImageType.V2TIM_IMAGE_TYPE_ORIGIN) {
            messageBody.originalImageSize = image.size;
            messageBody.originalImageWidth = image.width;
            messageBody.originalImageHeight = image.height;

            // 检查原图是否存在
            const originalImageResult = this.getActualMediaPath(
              MessageType.Image,
              imMessage.imageElem.path,
              image.uuid,
              `${image.type}`
            );
            if (originalImageResult.exists) {
              messageBody.originalImagePath = this.formatFilePath(originalImageResult.filePath);
            }
          } else if (image.type === V2TIMImageType.V2TIM_IMAGE_TYPE_THUMB) {
            // 检查缩略图是否存在
            const thumbImageResult = this.getActualMediaPath(
              MessageType.Image,
              imMessage.imageElem.path,
              image.uuid,
              `${image.type}`
            );
            if (thumbImageResult.exists) {
              messageBody.thumbImagePath = this.formatFilePath(thumbImageResult.filePath);
            }
          } else if (image.type === V2TIMImageType.V2TIM_IMAGE_TYPE_LARGE) {
            // 检查大图是否存在
            const largeImageResult = this.getActualMediaPath(
              MessageType.Image,
              imMessage.imageElem.path,
              image.uuid,
              `${image.type}`
            );
            if (largeImageResult.exists) {
              messageBody.largeImagePath = this.formatFilePath(largeImageResult.filePath);
            }
          }
        }
        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_SOUND: {
        if (!imMessage.soundElem) {
          break;
        }
        const messageBody: MessageBody = new MessageBody();
        messageBody.soundSize = imMessage.soundElem.dataSize;
        messageBody.soundDuration = imMessage.soundElem.duration;

        // 检查语音文件是否存在
        const soundResult = this.getActualMediaPath(
          MessageType.Sound,
          imMessage.soundElem.path,
          imMessage.soundElem.uuid,
          "amr"
        );
        if (soundResult.exists) {
          messageBody.soundPath = this.formatFilePath(soundResult.filePath);
        }

        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_FILE: {
        if (!imMessage.fileElem) {
          break;
        }
        const messageBody: MessageBody = new MessageBody();
        messageBody.fileName = imMessage.fileElem.filename;
        messageBody.fileSize = imMessage.fileElem.fileSize;

        // 检查文件是否存在
        const fileResult = this.getActualMediaPath(
          MessageType.File,
          imMessage.fileElem.path,
          imMessage.fileElem.uuid,
          imMessage.fileElem.filename
        );
        if (fileResult.exists) {
          messageBody.filePath = this.formatFilePath(fileResult.filePath);
        }

        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_VIDEO: {
        if (!imMessage.videoElem) {
          break;
        }
        const messageBody: MessageBody = new MessageBody();
        messageBody.videoSize = imMessage.videoElem.videoSize;
        messageBody.videoDuration = imMessage.videoElem.duration;
        messageBody.videoSnapshotWidth = imMessage.videoElem.snapshotWidth;
        messageBody.videoSnapshotHeight = imMessage.videoElem.snapshotHeight;
        messageBody.videoSnapshotSize = imMessage.videoElem.snapshotSize;

        // 检查视频缩略图是否存在
        const snapshotResult = this.getActualMediaPath(
          MessageType.Video,
          imMessage.videoElem.snapshotPath,
          imMessage.videoElem.snapshotUUID,
          undefined
        );
        if (snapshotResult.exists) {
          messageBody.videoSnapshotPath = this.formatFilePath(snapshotResult.filePath);
        }

        // 检查视频文件是否存在
        const videoResult = this.getActualMediaPath(
          MessageType.Video,
          imMessage.videoElem.videoPath,
          imMessage.videoElem.videoUUID,
          imMessage.videoElem.videoType
        );
        if (videoResult.exists) {
          messageBody.videoPath = this.formatFilePath(videoResult.filePath);
        }

        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_FACE: {
        if (!imMessage.faceElem) {
          break;
        }
        const messageBody: MessageBody = new MessageBody();
        messageBody.faceIndex = imMessage.faceElem.index;
        if (imMessage.faceElem.data) {
          // 在ArkTS中，使用TextEncoder/TextDecoder代替String(data: data, encoding: .utf8)
          const textDecoder = new util.TextDecoder('utf-8');
          // 将ArrayBuffer转换为Uint8Array
          const uint8Array = new Uint8Array(imMessage.faceElem.data);
          messageBody.faceName = textDecoder.decode(uint8Array);
        }
        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_CUSTOM: {
        if (!imMessage.customElem) {
          break;
        }
        const messageBody: MessageBody = new MessageBody();
        try {
          // 将data转为字符串
          if (imMessage.customElem.data) {
            const textDecoder = new util.TextDecoder('utf-8');
            const dataStr = textDecoder.decode(new Uint8Array(imMessage.customElem.data));
            // 解析JSON字符串为对象
            messageBody.customInfo = JSON.parse(dataStr) as CustomMessageContent;
          } else {
            messageBody.customInfo = {} as CustomMessageContent;
          }
        } catch (error) {
          console.error("解析自定义消息失败:", error);
          messageBody.customInfo = {} as CustomMessageContent;
        }
        return messageBody;
      }
      case V2TIMElemType.V2TIM_ELEM_TYPE_GROUP_TIPS: {
        if (!imMessage.groupTipsElem) {
          break;
        }
        if (imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_JOIN ||
          imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_INVITE ||
          imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_KICKED ||
          imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE ||
          imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_QUIT ||
          imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED ||
          imMessage.groupTipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED) {
          const messageBody: MessageBody = new MessageBody();
          messageBody.systemInfo = Util.getGroupTipsDisplayString(imMessage.groupTipsElem);
          return messageBody;
        }
        break;
      }
    }

    return undefined;
  }

  getMessageType(imMessage: V2TIMMessage): MessageType {
    // 消息被撤回
    if (imMessage.status === V2TIMMessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
      return MessageType.System;
    }

    // 根据元素类型确定消息类型
    switch (imMessage.elemType) {
      case V2TIMElemType.V2TIM_ELEM_TYPE_TEXT:
        return MessageType.Text;
      case V2TIMElemType.V2TIM_ELEM_TYPE_IMAGE:
        return MessageType.Image;
      case V2TIMElemType.V2TIM_ELEM_TYPE_SOUND:
        return MessageType.Sound;
      case V2TIMElemType.V2TIM_ELEM_TYPE_FILE:
        return MessageType.File;
      case V2TIMElemType.V2TIM_ELEM_TYPE_VIDEO:
        return MessageType.Video;
      case V2TIMElemType.V2TIM_ELEM_TYPE_FACE:
        return MessageType.Face;
      case V2TIMElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return MessageType.Custom;
      case V2TIMElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        return MessageType.System;
      default:
        return MessageType.Unknown;
    }
  }

  getQuoteMessage(imMessage: V2TIMMessage): MessageReplyInfo | undefined {
    // 转换cloudCustomData
    if (imMessage.cloudCustomData) {
      try {
        // 在ArkTS中，使用TextDecoder代替String(data: data, encoding: .utf8)
        const textDecoder = new util.TextDecoder('utf-8');
        // 将ArrayBuffer转换为Uint8Array
        const uint8Array = new Uint8Array(imMessage.cloudCustomData);
        const cloudCustomDataStr = textDecoder.decode(uint8Array);
        // 明确类型为CloudCustomData
        const customInfo = JSON.parse(cloudCustomDataStr) as CloudCustomData;

        if (customInfo && customInfo.reply) {
          const messageReply = customInfo.reply as Record<string, string | number>;
          const messageID = messageReply["messageID"] as string;
          const messageAbstract = messageReply["messageAbstract"] as string;
          const messageSender = messageReply["messageSender"] as string;

          if (messageID && typeof messageID === "string" &&
            messageAbstract && typeof messageAbstract === "string" &&
            messageSender && typeof messageSender === "string") {
            // 创建回复消息
            const replyMessage: MessageReplyInfo = new MessageReplyInfo();
            replyMessage.msgID = messageID;
            replyMessage.msgSender = messageSender;
            replyMessage.msgAbstract = messageAbstract;

            // 设置消息类型
            if (messageReply["messageType"] !== undefined && typeof messageReply["messageType"] === "number") {
              const messageType = messageReply["messageType"] as number;
              replyMessage.messageType = messageType as MessageType;
            }

            // 创建消息体
            const messageBody: MessageBody = new MessageBody();
            messageBody.text = messageAbstract;
            replyMessage.messageBody = messageBody;

            return replyMessage;
          }
        }
      } catch (e) {
        console.error("Error parsing cloudCustomData:", e);
      }
    }
    return undefined;
  }

  convertToUIMessageReactionList(v2Reactions: V2TIMMessageReaction[]): MessageReaction[] {
    return v2Reactions.map(reaction => this.convertToUIMessageReaction(reaction));
  }

  convertToUIMessageReaction(v2Reaction: V2TIMMessageReaction): MessageReaction {
    return {
      id: v2Reaction.reactionID,
      resourcePath: "",
      reactedByMyself: v2Reaction.reactedByMyself,
      totalUserCount: v2Reaction.totalUserCount
    };
  }

  getActualMediaPath(messageType: MessageType, mediaPath?: string, uuid?: string,
    extension?: string): GeneratedTypeLiteralInterface_1 {
    // 初始化结果
    let isFileExists = false;
    let actualMediaPath: string = "";
    const mediaHomePath = Util.getMediaHomePath(messageType);

    if (mediaPath && mediaPath !== "") {
      actualMediaPath = mediaPath;
      // 使用 fs API 检查文件是否存在
      try {
        const stats = fs.statSync(actualMediaPath);
        isFileExists = stats.isFile() && stats.size > 0;
        console.info(`[MessageListState] File exists check: ${actualMediaPath}, exists: ${isFileExists}, size: ${stats.size}`);
      } catch (error) {
        // 文件不存在或无法访问
        isFileExists = false;
        console.info(`[MessageListState] File doesn't exist: ${mediaPath}, error: ${JSON.stringify(error)}`);

        // 尝试处理特殊路径格式
        if (mediaPath.startsWith('file://')) {
          // 如果是 file:// 开头的URI格式，尝试转换为本地路径
          const localPath = mediaPath.substring(7); // 移除 'file://'
          try {
            const localStats = fs.statSync(localPath);
            if (localStats.isFile() && localStats.size > 0) {
              isFileExists = true;
              actualMediaPath = localPath; // 使用本地路径
              console.info(`[MessageListState] Found file using local path: ${localPath}`);
            }
          } catch (localError) {
            console.info(`[MessageListState] Local path also doesn't exist: ${localPath}`);
          }
        }
      }
    }

    if (!isFileExists) {
      // 文件路径的组成对齐老的版本，防止 app 升级出现读取不到本地文件的问题
      if (messageType === MessageType.Image) {
        actualMediaPath = `${mediaHomePath}${uuid || ""}_${extension || ""}`;
      } else if (messageType === MessageType.File) {
        actualMediaPath = `${mediaHomePath}${uuid || ""}${extension || ""}`;
      } else if (messageType === MessageType.Video || messageType === MessageType.Sound) {
        actualMediaPath = `${mediaHomePath}${uuid || ""}.${extension || ""}`;
      }

      // 确保目录存在
      if (actualMediaPath !== "") {
        const dirPath = actualMediaPath.substring(0, actualMediaPath.lastIndexOf('/') + 1);
        Util.ensureDirectoryExists(dirPath);
      }

      // 检查生成的路径文件是否存在
      if (actualMediaPath !== "") {
        try {
          const stats = fs.statSync(actualMediaPath);
          isFileExists = stats.isFile() && stats.size > 0;
          console.info(`[MessageListState] Generated file check: ${actualMediaPath}, exists: ${isFileExists}, size: ${stats.size}`);
        } catch (error) {
          // 文件不存在或无法访问
          isFileExists = false;
          console.info(`[MessageListState] Generated file doesn't exist: ${actualMediaPath}, error: ${JSON.stringify(error)}`);
        }
      }
    }

    // 返回文件路径和是否存在的状态
    return {
      filePath: actualMediaPath,
      exists: isFileExists
    };
  }

  setMessageListChangeSource(source: MessageListChangeSource): void {
    this.messageListChangeSource = source;

    // 触发回调通知外部
    if (this.onMessageListChangeSourceChanged) {
      this.onMessageListChangeSourceChanged(source);
    }

    // setTimeout代替DispatchQueue.main.async
    setTimeout(() => {
      this.messageListChangeSource = MessageListChangeSource.unknown;
    }, 0);
  }

  // MARK: - ChatEngine 消息内部通知
  onRecvMessageSendBegin(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const conversationID = userInfo.get('conversationID') as string;
    const message = userInfo.get('message') as MessageInfo;

    if (!conversationID || !message || conversationID !== this.conversationID) {
      return;
    }

    // 添加日期系统消息
    const dateMessage = this.convertToUIDateMessage(new Date());
    if (dateMessage) {
      this.messageDataSource.addData([dateMessage]);
    }

    // 如果是重发消息，则删除消息列表中原有的消息
    if (message.status !== undefined && message.status !== MessageStatus.initStatus) {
      const index = this.messageDataSource.getIndex(message.ID);
      if (index !== -1) {
        this.messageDataSource.deleteDataByIndex(index);
      }
    }

    if (message.imMessage) {
      message.messageBody = this.getMessageBody(message.imMessage);
    }
    // 添加新消息到列表
    this.messageDataSource.addData([message]);
    // 更新消息列表变更来源
    this.setMessageListChangeSource(MessageListChangeSource.sendMessage);
  }

  onRecvMessageSendProgress(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const conversationID = userInfo.get('conversationID') as string;
    const messageID = userInfo.get('messageID') as string;
    const progress = userInfo.get('progress') as number;

    if (!conversationID || !messageID || conversationID !== this.conversationID) {
      return;
    }

    const index = this.messageDataSource.getIndex(messageID);

    if (index !== -1) {
      // 获取消息引用
      const message = this.messageDataSource.getData(index);
      if (message) {
        // 更新发送进度
        message.progress = progress;
        // 通知数据源有变化
        this.messageDataSource.notifyDataChange(index);
      }
    }
  }

  onRecvMessageSendSuccess(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const conversationID = userInfo.get('conversationID') as string;
    const messageID = userInfo.get('messageID') as string;

    if (!conversationID || !messageID || conversationID !== this.conversationID) {
      return;
    }

    const index = this.messageDataSource.getIndex(messageID);

    if (index !== -1) {
      // 获取消息引用
      const message = this.messageDataSource.getData(index);

      if (message) {
        // 消息发送成功后，imMessage 数据会自动更新，需要重新根据 imMessage 更新消息
        const imMessage = message.imMessage;
        if (imMessage) {
          // 转换为更新后的消息对象
          const updateMessage = this.convertToUIMessage(imMessage);
          // 更新消息列表
          this.messageDataSource.deleteDataByIndex(index);
          this.messageDataSource.insertData(index, [updateMessage]);
        }
      }
    }
  }

  onRecvMesssageSendFailed(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const conversationID = userInfo.get('conversationID') as string;
    const messageID = userInfo.get('messageID') as string;

    if (!conversationID || !messageID || conversationID !== this.conversationID) {
      return;
    }

    const index = this.messageDataSource.getIndex(messageID);

    if (index !== -1) {
      // 获取消息引用
      const message = this.messageDataSource.getData(index);
      if (message) {
        // 设置发送失败状态
        message.status = MessageStatus.sendFail;
        // 通知数据源有变化
        this.messageDataSource.notifyDataChange(index);
      }
    }
  }

  onRecvMessageDelete(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const messageID = userInfo.get('messageID') as string;

    if (!messageID) {
      return;
    }

    const index = this.messageDataSource.getIndex(messageID);

    if (index !== -1) {
      this.messageDataSource.deleteDataByIndex(index);
      this.setMessageListChangeSource(MessageListChangeSource.deleteMessage);
    }
  }

  onRecvMessageRevoke(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const messageID = userInfo.get('messageID') as string;

    if (!messageID) {
      return;
    }

    const index = this.messageDataSource.getIndex(messageID);

    if (index !== -1) {
      // 获取消息引用
      const message = this.messageDataSource.getData(index);

      if (message && message.status !== MessageStatus.revoked) {
        // 设置状态为已撤回
        message.status = MessageStatus.revoked;
        // 转换为系统消息类型
        message.messageType = MessageType.System;

        // 确保messageBody存在
        if (!message.messageBody) {
          message.messageBody = new MessageBody();
        }

        // 只需要message.imMessage存在就可以设置撤回消息
        if (message.imMessage) {
          // 设置系统消息文本
          message.messageBody.systemInfo = Util.getRevokeDispayString(
            message.imMessage,
            undefined,
            undefined
          );
        }

        // 通知数据源有变化
        this.messageDataSource.notifyDataChange(index);
        this.setMessageListChangeSource(MessageListChangeSource.revokeMessage);

      }
    }
  }

  onRecvMessageEdit(eventData: Object): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const messageID = userInfo.get('messageID') as string;
    const imMessage = userInfo.get('imMessage') as V2TIMMessage;

    if (!messageID || !imMessage) {
      return;
    }

    const index = this.messageDataSource.getIndex(messageID);

    if (index !== -1) {
      // 使用转换函数处理编辑后的消息
      const newMessage = this.convertToUIMessage(imMessage);
      // 更新消息列表
      this.messageDataSource.deleteDataByIndex(index);
      this.messageDataSource.insertData(index, [newMessage]);
    }
  }

  onRecvMessagePin(eventData: Object): void {
    if (this.messageListType !== MessageListType.pinned) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const imMessage = userInfo.get('imMessage') as V2TIMMessage;

    if (!imMessage) {
      return;
    }

    const existingIndex = this.messageDataSource.getIndex(imMessage.msgID);

    if (existingIndex !== -1) {
      return;
    } else {
      const pinnedMessage = this.convertToUIMessage(imMessage);
      this.messageDataSource.addData([pinnedMessage]);
    }
  }

  onRecvMessageUnpin(eventData: Object): void {
    if (this.messageListType !== MessageListType.pinned) {
      return;
    }

    // Convert to Map to safely access properties
    const userInfo = eventData as Map<string, Object>;
    const imMessage = userInfo.get('imMessage') as V2TIMMessage;

    if (!imMessage) {
      return;
    }

    this.messageDataSource.deleteDataByID([imMessage.msgID]);
  }

  // MARK: - V2TIMAdvancedMsgListener
  onRecvNewMessage(msg: V2TIMMessage): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    // 消息不属于当前会话，直接忽略
    if (msg.userID != Util.getUserID(this.conversationID) &&
      msg.groupID != Util.getGroupID(this.conversationID)) {

      return;
    }

    // 添加日期系统消息
    const dateMessage = this.convertToUIDateMessage(new Date());
    if (dateMessage) {
      this.messageDataSource.addData([dateMessage]);
    }

    // 添加消息
    const message = this.convertToUIMessage(msg);
    this.messageDataSource.addData([message]);
    this.setMessageListChangeSource(MessageListChangeSource.recvMessage);
  }

  onRecvMessageReadReceipts(receiptList: V2TIMMessageReceipt[]): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    for (const receipt of receiptList) {
      const index = this.messageDataSource.getIndex(receipt.msgID);
      if (index !== -1) {
        // 获取消息引用
        const message = this.messageDataSource.getData(index);
        if (message) {
          // 更新已读回执信息
          message.readCount = receipt.readCount;
          message.unreadCount = receipt.unreadCount;
          // 通知数据源有变化
          this.messageDataSource.notifyDataChange(index);
        }
      }
    }
  }

  onRecvMessageRevoked(msgID: string, operateUser: V2TIMUserInfo, reason?: string): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    const index = this.messageDataSource.getIndex(msgID);
    if (index !== -1) {
      // 获取消息引用
      const message = this.messageDataSource.getData(index);

      if (message && message.status !== MessageStatus.revoked) {
        // 设置状态为已撤回
        message.status = MessageStatus.revoked;
        // 转换为系统消息类型
        message.messageType = MessageType.System;

        // 确保messageBody存在
        if (!message.messageBody) {
          message.messageBody = new MessageBody();
        }

        // 只需要message.imMessage存在就可以设置撤回消息
        if (message.imMessage) {
          // 设置系统消息文本
          message.messageBody.systemInfo = Util.getRevokeDispayString(
            message.imMessage,
            operateUser,
            reason
          );
        }

        // 通知数据源有变化
        this.messageDataSource.notifyDataChange(index);
        this.setMessageListChangeSource(MessageListChangeSource.revokeMessage);
      }
    }
  }

  onRecvMessageModified(msg: V2TIMMessage): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    const index = this.messageDataSource.getIndex(msg.msgID);
    if (index !== -1) {
      // 使用转换函数处理修改后的消息
      const updatedMessage = this.convertToUIMessage(msg);
      // 更新消息列表
      this.messageDataSource.deleteDataByIndex(index);
      this.messageDataSource.insertData(index, [updatedMessage]);
    }
  }

  onRecvMessageReactionsChanged(changeList: V2TIMMessageReactionChangeInfo[]): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    for (const change of changeList) {
      const index = this.messageDataSource.getIndex(change.msgID);
      if (index !== -1) {
        // 获取消息引用
        const message = this.messageDataSource.getData(index);
        if (message) {
          // 更新表情反应信息
          message.reactions = this.convertToUIMessageReactionList(change.reactionList);
          // 通知数据源有变化
          this.messageDataSource.notifyDataChange(index);
        }
      }
    }
  }

  onRecvMessageExtensionsDeleted(msgID: string, extensionKeys: string[]): void {
    if (this.messageListType !== MessageListType.history) {
      return;
    }

    const index = this.messageDataSource.getIndex(msgID);
    if (index !== -1) {
      // 获取对消息对象的引用
      const message = this.messageDataSource.getData(index);
      if (message && message.reactions && Array.isArray(message.reactions)) {
        // 直接修改原对象的属性
        message.reactions = message.reactions.filter(reaction =>
        !extensionKeys.includes(reaction.id)
        );
        // 通知数据源有变化
        this.messageDataSource.notifyDataChange(index);
      }
    }
  }

  onGroupMessagePinned(groupID: string, message: V2TIMMessage, isPinned: Boolean, opUser: V2TIMGroupMemberInfo): void {
    if (this.messageListType !== MessageListType.pinned) {
      return;
    }
    // 消息不属于当前群组，直接忽略
    if (groupID != Util.getGroupID(this.conversationID)) {
      return;
    }
    if (isPinned) {
      // 检查消息是否已在置顶列表中
      const existingIndex = this.messageDataSource.getIndex(message.msgID);
      if (existingIndex !== -1) {
        // 消息已经存在，不需要重复添加
        return;
      } else {
        // 将新的置顶消息添加到列表
        const pinnedMessage = this.convertToUIMessage(message);
        this.messageDataSource.addData([pinnedMessage]);
      }
    } else {
      // 取消置顶时从列表中移除消息
      this.messageDataSource.deleteDataByID([message.msgID]);
    }
  }

  /**
   * 格式化文件路径，确保本地文件路径有 file:// 前缀
   * @param path 原始路径
   * @returns 格式化后的路径，确保以 file:// 或 http:// 或 https:// 开头
   */
  private formatFilePath(path: string): string {
    if (!path) {
      return path;
    }

    // 如果路径不是以 http://, https://, file:// 开头的，则添加 file:// 前缀
    if (!path.startsWith('file://') && !path.startsWith('http://') && !path.startsWith('https://')) {
      return 'file://' + path;
    }

    return path;
  }
}
