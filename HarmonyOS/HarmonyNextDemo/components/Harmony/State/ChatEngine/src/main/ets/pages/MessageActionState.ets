import { V2TIMManager, V2TIMMessage } from '@tencentcloud/imsdk'
import { MessageInfo, MessageType, MessageReaction, MessageBody } from './MessageListState'
import { MessageSendNotifyKey } from './MessageInputState'
import { ErrorResult } from './ChatEngine'
import { Util } from './Util'
import notificationCenter from './NotificationCenter'

////////////////////////////////////////////////////////////
// 数据定义
////////////////////////////////////////////////////////////

/**
 * 消息操作通知事件Key
 */
export enum MessageActionNotifyKey {
  DELETE_MESSAGE = 'deleteMessage',
  REVOKE_MESSAGE = 'revokeMessage',
  EDIT_MESSAGE = 'editMessage',
  PIN_MESSAGE = 'pinMessage',
  UNPIN_MESSAGE = 'unpinMessage',
  ADD_EMOJI = 'addEmoji',
  REMOVE_EMOJI = 'removeEmoji'
}

/**
 * 消息操作类型
 */
export enum MessageActionType {
  DELETE = 0,
  REVOKE = 1,
  EDIT = 2,
  PIN = 3,
  UNPIN = 4,
  ADD_EMOJI = 5,
  REMOVE_EMOJI = 6
}

/**
 * 消息操作
 */
export class MessageAction {
  type?: MessageActionType
  text?: string // 编辑时的文本
  emojiID?: string // 添加/移除表情回应时的表情ID

  constructor(type: MessageActionType) {
    this.type = type
  }
}

/**
 * 消息操作事件数据接口
 */
interface MessageActionEventData {
  messageID?: string
  imMessage?: V2TIMMessage
  emojiID?: string
  conversationID?: string
  message?: MessageInfo
}

/**
 * Emitter 事件数据接口
 */
interface EmitterData {
  data: MessageActionEventData
}

/**
 * 消息转发类型
 */
export enum MessageForwardType {
  SINGLE = 0, // 逐条转发
  MERGE = 1 // 合并转发
}

/**
 * 消息操作状态管理
 */
export class MessageActionState {
  forwardConversationList?: string[] = []

  /**
   * 执行消息操作
   */
  setMessageAction(message: MessageInfo, action: MessageAction): Promise<void> {
    return this.setMessageActionInternal(message, action)
  }

  /**
   * 发送消息已读回执
   */
  sendMessageReadReceipt(messageList: MessageInfo[]): Promise<void> {
    return this.sendMessageReadReceiptInternal(messageList)
  }

  /**
   * 转发消息
   */
  forwardMessages(messageList: MessageInfo[], forwardType: MessageForwardType): Promise<void> {
    return this.forwardMessagesInternal(messageList, forwardType)
  }

  /**
   * 创建 MessageInfo 对象的工厂方法
   */
  private createMessageInfo(
    imMessage?: V2TIMMessage,
    id?: string,
    sender?: string,
    receiver?: string,
    groupID?: string
  ): MessageInfo {
    const message = new MessageInfo()
    if (id) {
      message.ID = id
    }
    message.imMessage = imMessage
    message.sender = sender
    message.receiver = receiver
    message.groupID = groupID
    message.messageBody = new MessageBody()
    return message
  }

  /**
   * 内部消息操作处理
   */
  private setMessageActionInternal(message: MessageInfo, action: MessageAction): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      if (!message.ID || !message.imMessage) {
        reject(new ErrorResult(-1, "Message not found for operation"))
        return
      }

      const msgID = message.ID
      const imMessage = message.imMessage

      switch (action.type) {
        case MessageActionType.DELETE: {
          V2TIMManager.getMessageManager().deleteMessages([imMessage])
            .then(() => {
              const deleteData = new Map<string, Object>();
              deleteData.set('messageID', msgID);
              notificationCenter.post(MessageActionNotifyKey.DELETE_MESSAGE, deleteData);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
        case MessageActionType.REVOKE: {
          V2TIMManager.getMessageManager().revokeMessage(imMessage)
            .then(() => {
              const revokeData = new Map<string, Object>();
              revokeData.set('messageID', msgID);
              notificationCenter.post(MessageActionNotifyKey.REVOKE_MESSAGE, revokeData);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
        case MessageActionType.EDIT: {
          if (message.messageType !== MessageType.Text || !message.messageBody) {
            reject(new ErrorResult(-1, "Only text messages can be edited"))
            return
          }
          if (imMessage.textElem) {
            imMessage.textElem.text = action.text ? action.text : ""
          }
          V2TIMManager.getMessageManager().modifyMessage(imMessage)
            .then((result) => {
              if (result.resultCode === 0) {
                const editData = new Map<string, Object>();
                editData.set('messageID', msgID);
                editData.set('imMessage', imMessage);
                notificationCenter.post(MessageActionNotifyKey.EDIT_MESSAGE, editData);
                resolve()
              } else {
                reject(new ErrorResult(result.resultCode, result.resultInfo))
              }
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
        case MessageActionType.PIN: {
          const groupID = imMessage.groupID
          if (!groupID) {
            reject(new ErrorResult(-1, "Group ID not found"))
            return
          }
          V2TIMManager.getMessageManager().pinGroupMessage(
            groupID,
            imMessage,
            true)
            .then(() => {
              const pinData = new Map<string, Object>();
              pinData.set('imMessage', imMessage);
              notificationCenter.post(MessageActionNotifyKey.PIN_MESSAGE, pinData);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
        case MessageActionType.UNPIN: {
          const groupID = imMessage.groupID
          if (!groupID) {
            reject(new ErrorResult(-1, "Group ID not found"))
            return
          }
          V2TIMManager.getMessageManager().pinGroupMessage(
            groupID,
            imMessage,
            false
          )
            .then(() => {
              const unpinData = new Map<string, Object>();
              unpinData.set('imMessage', imMessage);
              notificationCenter.post(MessageActionNotifyKey.UNPIN_MESSAGE, unpinData);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
        case MessageActionType.ADD_EMOJI: {
          if (!action.emojiID) {
            reject(new ErrorResult(-1, "Emoji ID to add not found"))
            return
          }
          V2TIMManager.getMessageManager().addMessageReaction(imMessage, action.emojiID)
            .then(() => {
              const addEmojiData = new Map<string, Object>();
              addEmojiData.set('messageID', msgID);
              addEmojiData.set('emojiID', action.emojiID ?? "");
              notificationCenter.post(MessageActionNotifyKey.ADD_EMOJI, addEmojiData);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
        case MessageActionType.REMOVE_EMOJI: {
          if (!action.emojiID) {
            reject(new ErrorResult(-1, "Emoji ID to remove not found"))
            return
          }
          V2TIMManager.getMessageManager().removeMessageReaction(imMessage, action.emojiID)
            .then(() => {
              const removeEmojiData = new Map<string, Object>();
              removeEmojiData.set('messageID', msgID);
              removeEmojiData.set('emojiID', action.emojiID ?? "");
              notificationCenter.post(MessageActionNotifyKey.REMOVE_EMOJI, removeEmojiData);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(error)
            })
          break
        }
      }
    })
  }

  /**
   * 内部发送消息已读回执处理
   */
  private sendMessageReadReceiptInternal(messageList: MessageInfo[]): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const imMessageList = messageList.filter(msg => msg.imMessage).map(msg => msg.imMessage!)

      V2TIMManager.getMessageManager().sendMessageReadReceipts(imMessageList)
        .then(() => {
          resolve()
        })
        .catch((error: ErrorResult) => {
          reject(error)
        })
    })
  }

  /**
   * 内部转发消息处理
   */
  private forwardMessagesInternal(messageList: MessageInfo[], forwardType: MessageForwardType): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      // Ensure forwardConversationList is initialized
      if (!this.forwardConversationList) {
        this.forwardConversationList = [];
      }

      const filteredMessageList = messageList.filter(msg => msg.messageType !== MessageType.System)
      if (filteredMessageList.length === 0) {
        reject(new ErrorResult(-1, "Message list is empty"))
        return
      }

      const imMessageList = this.getSortedIMMessageList(filteredMessageList) ?? [];

      if (forwardType === MessageForwardType.MERGE) {
        const title = $r('app.string.merge_message_title').toString()
        const abstractList: string[] = []
        const compatibleText = "请升级最新版本" // 保持与Swift一致的硬编码文本

        if (imMessageList.length > 0) {
          let mergeMessage =
            V2TIMManager.getMessageManager().createMergerMessage(imMessageList, title, abstractList, compatibleText)
          for (const conversationID of this.forwardConversationList) {
            // 使用工厂方法创建 MessageInfo 对象
            const message = this.createMessageInfo(mergeMessage)

            const beginData = new Map<string, Object>();
            beginData.set('conversationID', conversationID ?? "");
            beginData.set('message', message);
            notificationCenter.post(MessageSendNotifyKey.SEND_BEGIN, beginData);
          }
        }
      } else {
        // 单条转发逻辑，直接在这里处理，与Swift结构保持一致
        for (const imMessage of imMessageList) {
          let forwardMessage = V2TIMManager.getMessageManager().createForwardMessage(imMessage)
          if (!forwardMessage) {
            continue // 对应Swift的guard let continue逻辑
          }

          for (const conversationID of this.forwardConversationList) {
            // 延时处理，对应Swift的Thread.sleep
            let timeInterval = 50 // 默认50ms，对应Swift的0.05秒
            let groupID = Util.getGroupID(conversationID) ?? "";
            if (groupID.length > 0) {
              timeInterval = 90 // 群组90ms，对应Swift的0.09秒
            }

            // 异步处理，对应Swift的DispatchQueue.global().async + Thread.sleep
            setTimeout(() => {
              // 主线程操作，对应Swift的DispatchQueue.main.async
              // 确保 forwardMessage 不为 null
              if (forwardMessage) {
                const message = this.createMessageInfo(forwardMessage)

                const beginData = new Map<string, Object>();
                beginData.set('conversationID', conversationID ?? "");
                beginData.set('message', message);
                notificationCenter.post(MessageSendNotifyKey.SEND_BEGIN, beginData);
              }
            }, timeInterval)
          }
        }
      }

      resolve() // 对应Swift的completion.onSuccess()
    })
  }

  /**
   * 获取排序后的消息列表
   */
  private getSortedIMMessageList(messageList: MessageInfo[]): V2TIMMessage[] {
    const msgs = messageList.sort((obj1, obj2) => {
      const timestamp1 = obj1.imMessage?.timestamp
      const timestamp2 = obj2.imMessage?.timestamp
      const t1: number = timestamp1 ? timestamp1 : 0
      const t2: number = timestamp2 ? timestamp2 : 0

      if (t1 === t2) {
        const seq1: number = obj1.imMessage?.seq || 0
        const seq2: number = obj2.imMessage?.seq || 0
        return seq1 - seq2
      } else {
        return t1 - t2
      }
    })

    return msgs.filter(msg => msg.imMessage !== undefined && msg.imMessage !== null)
      .map(msg => msg.imMessage!)
  }
}
