import {
  V2TIMManager,
  V2TIMMessage,
  V2TIMMessagePriority,
  V2TIMTextElem,
  V2TIMCustomElem
} from '@tencentcloud/imsdk'
import { MessageInfo, MessageType, MessageStatus, MessageBody, MessageReaction } from './MessageListState'
import { Util } from './Util'
import { ChatEngine, ErrorResult } from './ChatEngine'
import util from '@ohos.util'
import { data } from '@kit.TelephonyKit'
import notificationCenter from './NotificationCenter'


/**
 * 自定义消息扩展类
 */
class CustomExtension {
  description: string
  extension: string

  constructor(description: string = '', extension: string = '') {
    this.description = description
    this.extension = extension
  }
}

/**
 * 消息发送通知Key
 */
export enum MessageSendNotifyKey {
  SEND_BEGIN = 'sendBegin',
  SEND_PROGRESS = 'sendProgress',
  SEND_SUCCESS = 'sendSuccess',
  SEND_FAILED = 'sendFailed'
}

/**
 * 消息自定义信息Key
 */
export enum MessageCustomInfoKey {
  reply = "reply",
  replies = "replies"
}

/**
 * 消息发送选项
 */
interface MessageSendOption {
  userID?: string // 接收者ID，单聊时使用
  groupID?: string // 群组ID，群聊时使用
  priority?: V2TIMMessagePriority // 消息优先级
  onlineUserOnly?: boolean // 是否仅在线用户接收
  isExcludedFromUnreadCount?: boolean // 是否计入未读数
  isExcludedFromLastMessage?: boolean // 是否更新会话最新消息
}

/**
 * 消息回复信息接口定义
 */
interface MessageReplyInfo {
  messageID?: string
  messageSender?: string
  messageAbstract?: string
  messageType?: number
  messageTime?: number
  isQuote?: boolean
  version?: number
}

/**
 * 自定义云数据接口定义
 */
interface CloudCustomData {
  reply?: MessageReplyInfo
}

/**
 * 消息输入状态管理
 */
@Observed
export class MessageInputState {
  inputText?: string = ''
  replyMessage?: MessageInfo | null = null
  quoteMessage?: MessageInfo | null = null
  private conversationID?: string
  private userID?: string
  private groupID?: string

  constructor(conversationID: string) {
    this.conversationID = conversationID
    this.userID = Util.getUserID(conversationID) ?? undefined
    this.groupID = Util.getGroupID(conversationID) ?? undefined
  }

  private static async convertToIMMessage(message: MessageInfo): Promise<V2TIMMessage | undefined> {
    const messageBody = message.messageBody
    if (!messageBody) {
      return undefined
    }

    let imMessage: V2TIMMessage | undefined = undefined
    const messageManager = V2TIMManager.getMessageManager()

    try {
      switch (message.messageType) {
        case MessageType.Text:
          if (messageBody.text) {
            imMessage = messageManager.createTextMessage(messageBody.text)
          }
          break

        case MessageType.Image:
          if (messageBody.originalImagePath) {
            imMessage = messageManager.createImageMessage(messageBody.originalImagePath)
          }
          break

        case MessageType.Sound:
          if (messageBody.soundPath) {
            imMessage = messageManager.createSoundMessage(
              messageBody.soundPath,
              messageBody.soundDuration || 0
            )
          }
          break

        case MessageType.File:
          if (messageBody.filePath && messageBody.fileName) {
            imMessage = messageManager.createFileMessage(
              messageBody.filePath,
              messageBody.fileName
            )
          }
          break

        case MessageType.Video:
          if (messageBody.videoPath && messageBody.videoSnapshotPath) {
            imMessage = messageManager.createVideoMessage(
              messageBody.videoPath,
              messageBody.videoType || 'mp4',
              messageBody.videoDuration || 0,
              messageBody.videoSnapshotPath
            )
          }
          break

        case MessageType.Face:
          if (messageBody.faceName) {
            imMessage = messageManager.createFaceMessage(
              messageBody.faceIndex || 0,
              new util.TextEncoder().encode(messageBody.faceName)
            )
          }
          break

        case MessageType.Custom:
          if (messageBody.customInfo) {
            let data = new util.TextEncoder().encode(JSON.stringify(messageBody.customInfo));
            imMessage = messageManager.createCustomMessage(
              data,
              new CustomExtension('', '')
            )
          }
          break
      }
    } catch (error) {
      console.error('创建消息失败:', error.message)
    }

    return imMessage
  }

  private static createMessageReplyInfo(
    message: MessageInfo,
    isQuote: boolean
  ): MessageReplyInfo {
    return {
      messageID: message.ID,
      messageSender: message.sender,
      messageAbstract: message.messageBody?.text || '',
      messageType: message.messageType,
      messageTime: message.dateTime?.getTime() || 0,
      isQuote: isQuote,
      version: 1
    }
  }

  /**
   * 发送消息（公共接口）
   */
  public sendMessage(message: MessageInfo): Promise<void> {
    return this.sendMessageInternal(message);
  }

  /**
   * 发送消息的内部实现
   */
  private sendMessageInternal(message: MessageInfo): Promise<void> {
    return new Promise<void>(async (resolve, reject) => {
      try {
        // 将 null 明确转换为 undefined
        let imMessage: V2TIMMessage | undefined = message.imMessage === null ? undefined : message.imMessage
        if (!imMessage) {
          imMessage = await MessageInputState.convertToIMMessage(message)
        }

        if (!imMessage) {
          throw new Error("消息对象为空，无法发送")
        }

        // 处理回复和引用
        if (this.replyMessage || this.quoteMessage) {
          // 确保使用的消息对象不为 null 或 undefined
          const messageToUse = this.replyMessage || this.quoteMessage
          // 只有当 messageToUse 不为 null 且不为 undefined 时才进行处理
          if (messageToUse) {
            const cloudCustomData: CloudCustomData = {
              reply: MessageInputState.createMessageReplyInfo(
                messageToUse,
                this.quoteMessage !== null && this.quoteMessage !== undefined
              )
            }
            // 将 JSON 字符串转换为 ArrayBuffer
            imMessage.cloudCustomData = new util.TextEncoder().encode(JSON.stringify(cloudCustomData))
          }
        }

        // 设置进度回调
        const progressCallback = (progress: number) => {
          // 确保 imMessage 不为 undefined
          if (imMessage) {
            const progressData = new Map<string, Object>();
            progressData.set('conversationID', this.conversationID ?? "");
            progressData.set('messageID', imMessage.msgID);
            progressData.set('progress', progress);
            notificationCenter.post(MessageSendNotifyKey.SEND_PROGRESS, progressData);
          }
        }

        // 发送消息
        const result = await V2TIMManager.getMessageManager().sendMessage(imMessage, {
          receiver: this.userID,
          groupID: this.groupID,
          priority: V2TIMMessagePriority.V2TIM_PRIORITY_NORMAL,
          onlineUserOnly: false,
          callback: progressCallback
        })

        // 确保处理返回结果
        if (!result || !result.msgID) {
          throw new Error("消息发送失败，未获取到消息ID")
        }

        const msgID = result.msgID

        console.info('[MessageInputState] Sending SEND_BEGIN notification with conversationID:', this.conversationID,
          'messageID:', msgID);

        let copyMessage = message;
        copyMessage.ID = msgID;
        copyMessage.isSelf = true;
        copyMessage.imMessage = imMessage;
        copyMessage.sender = ChatEngine.getInstance().currentUserInfo?.userID;

        const beginData = new Map<string, Object>();
        beginData.set('conversationID', this.conversationID ?? "");
        beginData.set('message', copyMessage);
        beginData.set('messageID', msgID);
        notificationCenter.post(MessageSendNotifyKey.SEND_BEGIN, beginData);

        result.promise.then((v2Message: V2TIMMessage) => {
          // 发送消息已完成，直接发送成功事件
          copyMessage.imMessage = v2Message;
          const successData = new Map<string, Object>();
          successData.set('conversationID', this.conversationID ?? "");
          successData.set('messageID', msgID);
          notificationCenter.post(MessageSendNotifyKey.SEND_SUCCESS, successData);
          resolve()
        }).catch((error: ErrorResult) => {

          const failedData = new Map<string, Object>();
          failedData.set('conversationID', this.conversationID ?? "");
          failedData.set('messageID', message.ID);
          notificationCenter.post(MessageSendNotifyKey.SEND_FAILED, failedData);

          reject(new ErrorResult(-1 || error.code, error.message || "消息发送失败"))
        })

        this.replyMessage = null
        this.quoteMessage = null
      } catch (error) {
        const failedData = new Map<string, Object>();
        failedData.set('conversationID', this.conversationID ?? "");
        failedData.set('messageID', message.ID);
        notificationCenter.post(MessageSendNotifyKey.SEND_FAILED, failedData);
        reject(new ErrorResult(-1, error.message || "消息发送失败"))
      }
    })
  }
}
