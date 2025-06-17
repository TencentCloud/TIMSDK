import {
  V2TIMManager,
  V2TIMConversation,
  V2TIMConversationListFilter,
  V2TIMConversationType
} from '@tencentcloud/imsdk'
import { Util } from './Util'
import { ErrorResult } from './ChatEngine'
import CommonData from '../datasource/CommonData'
import ConversationDataSource from '../datasource/ConversationDataSource'

////////////////////////////////////////////////////////////
// 数据定义
////////////////////////////////////////////////////////////

/**
 * 会话类型
 */
export enum ConversationType {
  UNKNOWN = 0, // 未知
  C2C = 1, // 单聊
  GROUP = 2 // 群聊
}

/**
 * 会话信息
 */
@Observed
export class ConversationInfo extends CommonData {
  // ID?: string = '' // 会话唯一标识
  type?: ConversationType = ConversationType.UNKNOWN
  avatarUrl?: string = '' // 头像
  title?: string = '' // 标题
  subTitle?: string | Resource = '' // 子标题
  draft?: string = '' // 草稿
  formatTime?: string = '' // 格式化的时间
  unreadCount?: number = 0 // 未读数
  isPinned?: boolean = false // 是否置顶
  orderKey?: number = 0; // 排序键值
}

/**
 * 会话操作类型
 */
export enum ConversationActionType {
  DELETE, // 删除会话
  MARK_READ, // 标记已读
  MARK_UNREAD, // 标记未读
  MARK_HIDDEN, // 标记隐藏
  CLEAR_UNREAD_COUNT,
  CLEAR_MESSAGE, // 清除历史
  SET_DRAFT, // 设置草稿
  PIN, // 置顶
  UNPIN // 取消置顶
}

/**
 * 会话操作
 */
export class ConversationAction {
  type?: ConversationActionType
  draft?: string = '' // 仅当type为SET_DRAFT时有效

  constructor(type: ConversationActionType) {
    this.type = type
  }
}

/**
 * 会话获取选项
 */
export class ConversationGetOption {
  type?: ConversationType = ConversationType.UNKNOWN
  count?: number = 100 // 分页大小

  constructor() {
  }
}

/**
 * 会话监听器接口
 */
export interface ConversationListener {
  onConversationChanged?: (conversationList: V2TIMConversation[]) => void
  onNewConversation?: (conversationList: V2TIMConversation[]) => void
  onConversationDeleted?: (conversationIDList: string[]) => void
  onTotalUnreadMessageCountChanged?: (totalUnreadCount: number) => void
}

////////////////////////////////////////////////////////////
// 会话列表状态管理
////////////////////////////////////////////////////////////
@Observed
export class ConversationListState {
  conversationDataSource: ConversationDataSource = new ConversationDataSource()
  hasMoreConversation: boolean = true
  conversationTotalUnreadCount: number = 0
  private option: ConversationGetOption | null = null
  private nextSeq: number = 0
  private listener?: ConversationListener
  private onUnreadCountChangedCallback?: () => void

  constructor() {
    this.init();
  }

  destroy() {
    V2TIMManager.getConversationManager().removeConversationListener(this.listener);
    console.info('ConversationListState class 已销毁');
  }

  /**
   * 获取会话列表
   * @param option 会话获取选项
   * @returns Promise<void>
   */
  fetchConversationList(option: ConversationGetOption): Promise<void> {
    return this.fetchConversationListInternal(option);
  }

  /**
   * 加载更多会话
   * @returns Promise<void>
   */
  loadMoreConversationList(): Promise<void> {
    return this.loadMoreConversationListInternal();
  }

  /**
   * 执行会话操作
   * @param conversation 会话信息对象
   * @param action 会话操作对象
   * @returns Promise<void>
   */
  setConversationAction(
    conversation: ConversationInfo,
    action: ConversationAction
  ): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const that = this

      if (!conversation.ID) {
        reject(new ErrorResult(-1, "Conversation ID is required"))
        return
      }

      if (action.type === undefined) {
        reject(new ErrorResult(-1, "Action type is required"))
        return
      }

      switch (action.type) {
        case ConversationActionType.DELETE:
          V2TIMManager.getConversationManager().deleteConversation(conversation.ID)
            .then(() => {
              // 使用dataSource删除数据
              that.conversationDataSource.deleteDataByID([conversation.ID]);
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_delete_failed').toString()))
            })
          break

        case ConversationActionType.CLEAR_UNREAD_COUNT:
          V2TIMManager.getConversationManager().cleanConversationUnreadMessageCount(conversation.ID, null)
            .then(() => {
              // 更新会话对象的未读数量
              const index = that.conversationDataSource.getIndex(conversation.ID);
              if (index !== -1) {
                const item = that.conversationDataSource.getData(index);
                if (item) {
                  item.unreadCount = 0;
                  that.conversationDataSource.notifyDataChange(index);
                }
              }
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_clear_unread_failed').toString()))
            })
          break
        case ConversationActionType.CLEAR_MESSAGE:
          // 清除会话历史消息
          // 根据会话 ID 判断是单聊还是群聊
          // 单聊会话 ID 格式为: "c2c_userID"
          // 群聊会话 ID 格式为: "group_groupID"
          if (!conversation.ID) {
            reject(new ErrorResult(-1, "Invalid conversationID"));
            return;
          }

          // 提取 userID 或 groupID
          let userID = '';
          let groupID = '';

          if (conversation.ID.startsWith('c2c_')) {
            userID = Util.getUserID(conversation.ID) ?? ''; // 去掉 "c2c_" 前缀
          } else if (conversation.ID.startsWith('group_')) {
            groupID = Util.getGroupID(conversation.ID) ?? ''; // 去掉 "group_" 前缀
          } else {
            reject(new ErrorResult(-1, "Invalid conversationID format"));
            return;
          }

          // 根据会话类型调用不同的清除历史消息方法
          if (userID && userID.length > 0) {
            // 清除单聊历史消息
            V2TIMManager.getMessageManager().clearC2CHistoryMessage(userID)
              .then(() => {
                console.info(`成功清除单聊历史消息: ${userID}`);
                resolve();
              })
              .catch((error: ErrorResult) => {
                console.error(`清除单聊历史消息失败: ${error.message}`);
                reject(new ErrorResult(error.code || -1,
                  error.message || $r('app.string.conversation_clear_message_failed').toString() ||
                    "清除历史消息失败"));
              });
          } else if (groupID && groupID.length > 0) {
            // 清除群聊历史消息
            V2TIMManager.getMessageManager().clearGroupHistoryMessage(groupID)
              .then(() => {
                console.info(`成功清除群聊历史消息: ${groupID}`);
                resolve();
              })
              .catch((error: ErrorResult) => {
                console.error(`清除群聊历史消息失败: ${error.message}`);
                reject(new ErrorResult(error.code || -1,
                  error.message || $r('app.string.conversation_clear_message_failed').toString() ||
                    "清除历史消息失败"));
              });
          }
          break

        case ConversationActionType.MARK_HIDDEN:
          // 隐藏会话
          // 使用 SDK 提供的 markConversation 方法标记会话为隐藏
          // 对应 V2TIMConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_HIDE (0x1 << 3)
          const V2TIM_CONVERSATION_MARK_TYPE_HIDE = 0x1 << 3; // 会话隐藏标记类型

          V2TIMManager.getConversationManager()
            .markConversation([conversation.ID], V2TIM_CONVERSATION_MARK_TYPE_HIDE, true)
            .then((results) => {
              // 检查标记操作结果
              let allSuccess = true;
              for (const result of results) {
                if (result.resultCode !== 0) {
                  allSuccess = false;
                  console.error(`标记会话隐藏失败: ${result.resultInfo} (code: ${result.resultCode})`);
                }
              }

              if (allSuccess) {
                // 如果服务器标记成功，也从UI层面隐藏会话
                that.conversationDataSource.deleteDataByID([conversation.ID]);
                resolve();
              } else {
                reject(new ErrorResult(-1, $r('app.string.conversation_hide_failed').toString() || "隐藏会话失败"));
              }
            })
            .catch((error: ErrorResult) => {
              console.error(`标记会话为隐藏失败: ${error.message}`);
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_hide_failed').toString() || "隐藏会话失败"));
            });
          break

        case ConversationActionType.SET_DRAFT:
          V2TIMManager.getConversationManager().setConversationDraft(conversation.ID, action.draft || '')
            .then(() => {
              // 更新会话对象的草稿字段
              const index = that.conversationDataSource.getIndex(conversation.ID);
              if (index !== -1) {
                const item = that.conversationDataSource.getData(index);
                if (item) {
                  item.draft = action.draft || '';
                  that.conversationDataSource.notifyDataChange(index);
                }
              }
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_set_draft_failed').toString()))
            })
          break

        case ConversationActionType.PIN:
          V2TIMManager.getConversationManager().pinConversation(conversation.ID, true)
            .then(() => {
              // 更新会话对象的置顶状态
              const index = that.conversationDataSource.getIndex(conversation.ID);
              if (index !== -1) {
                const item = that.conversationDataSource.getData(index);
                if (item) {
                  item.isPinned = true;
                  // 排序会自动在DataSource内完成
                  that.conversationDataSource.notifyDataChange(index);
                }
              }
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_pin_failed').toString()))
            })
          break

        case ConversationActionType.UNPIN:
          V2TIMManager.getConversationManager().pinConversation(conversation.ID, false)
            .then(() => {
              // 更新会话对象的置顶状态
              const index = that.conversationDataSource.getIndex(conversation.ID);
              if (index !== -1) {
                const item = that.conversationDataSource.getData(index);
                if (item) {
                  item.isPinned = false;
                  // 排序会自动在DataSource内完成
                  that.conversationDataSource.notifyDataChange(index);
                }
              }
              resolve()
            })
            .catch((error: ErrorResult) => {
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_unpin_failed').toString()))
            })
          break

        case ConversationActionType.MARK_READ:
          // 标记会话为已读
          // 使用 markConversation 方法来标记会话为非未读
          // 对应 V2TIMConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_UNREAD (0x1 << 1)
          const V2TIM_CONVERSATION_MARK_TYPE_UNREAD_READ = 0x1 << 1; // 会话标记未读类型

          V2TIMManager.getConversationManager()
            .markConversation([conversation.ID], V2TIM_CONVERSATION_MARK_TYPE_UNREAD_READ, false)
            .then((results) => {
              // 检查标记操作结果
              let allSuccess = true;
              for (const result of results) {
                if (result.resultCode !== 0) {
                  allSuccess = false;
                  console.error(`标记会话为已读失败: ${result.resultInfo} (code: ${result.resultCode})`);
                }
              }

              if (allSuccess) {
                // 同时清除会话的未读消息数
                V2TIMManager.getConversationManager().cleanConversationUnreadMessageCount(conversation.ID, null)
                  .then(() => {
                    // 更新会话对象的未读数量
                    const index = that.conversationDataSource.getIndex(conversation.ID);
                    if (index !== -1) {
                      const item = that.conversationDataSource.getData(index);
                      if (item) {
                        item.unreadCount = 0;
                        that.conversationDataSource.notifyDataChange(index);
                      }
                    }
                    resolve();
                  })
                  .catch((error: ErrorResult) => {
                    console.error(`清除会话未读数失败: ${error.message}`);
                    // 即使清除未读数失败，标记已读操作仍然成功
                    resolve();
                  });
              } else {
                reject(new ErrorResult(-1,
                  $r('app.string.conversation_mark_read_failed').toString() || "标记会话为已读失败"));
              }
            })
            .catch((error: ErrorResult) => {
              console.error(`标记会话为已读失败: ${error.message}`);
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_mark_read_failed').toString() || "标记会话为已读失败"));
            });
          break

        case ConversationActionType.MARK_UNREAD:
          // 标记会话为未读
          // 使用 markConversation 方法来标记会话为未读
          // 对应 V2TIMConversationMarkType.V2TIM_CONVERSATION_MARK_TYPE_UNREAD (0x1 << 1)
          const V2TIM_CONVERSATION_MARK_TYPE_UNREAD = 0x1 << 1; // 会话标记未读类型

          V2TIMManager.getConversationManager()
            .markConversation([conversation.ID], V2TIM_CONVERSATION_MARK_TYPE_UNREAD, true)
            .then((results) => {
              // 检查标记操作结果
              let allSuccess = true;
              for (const result of results) {
                if (result.resultCode !== 0) {
                  allSuccess = false;
                  console.error(`标记会话为未读失败: ${result.resultInfo} (code: ${result.resultCode})`);
                }
              }

              if (allSuccess) {
                // 标记为未读时，在UI上增加未读数量
                const index = that.conversationDataSource.getIndex(conversation.ID);
                if (index !== -1) {
                  const item = that.conversationDataSource.getData(index);
                  if (item) {
                    // 如果当前未读数为0，则设置为1，否则保持不变（因为已经是未读状态）
                    if (item.unreadCount === 0) {
                      item.unreadCount = 1;
                    }
                    that.conversationDataSource.notifyDataChange(index);
                    // that.conversationDataSource?.changedData([item]);
                  }
                }
                resolve();
              } else {
                reject(new ErrorResult(-1,
                  $r('app.string.conversation_mark_unread_failed').toString() || "标记会话为未读失败"));
              }
            })
            .catch((error: ErrorResult) => {
              console.error(`标记会话为未读失败: ${error.message}`);
              reject(new ErrorResult(error.code || -1,
                error.message || $r('app.string.conversation_mark_unread_failed').toString() || "标记会话为未读失败"));
            });
          break

        default:
          reject(new ErrorResult(-1, $r('app.string.conversation_unsupported_action').toString()))
          break
      }
    })
  }

  /**
   * 设置未读数变化回调
   */
  setOnUnreadCountChangedCallback(callback: () => void) {
    this.onUnreadCountChangedCallback = callback;
  }

  /**
   * 获取会话列表内部实现
   * @param option 会话获取选项
   * @returns Promise<void>
   */
  private fetchConversationListInternal(option: ConversationGetOption): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      const filter: V2TIMConversationListFilter = {
        type: 0
      }
      const that = this

      V2TIMManager.getConversationManager().getConversationListByFilter(0, option.count, filter)
        .then((result) => {
          const list = that.convertToConversationList(result.conversationList)
          that.conversationDataSource.setData(list)
          that.hasMoreConversation = !result.isFinished
          that.nextSeq = result.nextSeq
          that.option = option
          console.info(`getConversationListByFilter: ${that.conversationDataSource.totalCount()} ，listcount: ${list.length} ,  result.conversationList :${result.conversationList.length}`);
          resolve()
        })
        .catch((error: ErrorResult) => {
          reject(new ErrorResult(error.code || -1,
            error.message || $r('app.string.conversation_fetch_failed').toString()))
        })
    })
  }

  /**
   * 加载更多会话内部实现
   * @returns Promise<void>
   */
  private loadMoreConversationListInternal(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      if (!this.hasMoreConversation) {
        reject(new ErrorResult(-1, $r('app.string.conversation_no_more').toString()))
        return
      }

      if (!this.option) {
        reject(new ErrorResult(-1, $r('app.string.conversation_fetch_first').toString()))
        return
      }

      const filter: V2TIMConversationListFilter = {
        type: 0
      }
      const that = this

      V2TIMManager.getConversationManager().getConversationListByFilter(this.nextSeq, this.option.count, filter)
        .then((result) => {
          const list = that.convertToConversationList(result.conversationList)
          that.conversationDataSource.addData(list)
          that.hasMoreConversation = !result.isFinished
          that.nextSeq = result.nextSeq
          resolve()
        })
        .catch((error: ErrorResult) => {
          reject(new ErrorResult(error.code || -1,
            error.message || $r('app.string.conversation_load_more_failed').toString()))
        })
    })
  }

  /**
   * 初始化会话监听器
   */
  private addConversationListenerInternal() {
    const that = this
    this.listener = {
      onConversationChanged: (conversationList: V2TIMConversation[]) => {
        console.info('onConversationChanged', conversationList)

        // 转换会话数据
        const list = that.convertToConversationList(conversationList)
        // 更新会话列表（将会自动进行排序和去重）
        that.conversationDataSource.changedData(list, true)
      },
      onNewConversation: (conversationList: V2TIMConversation[]) => {
        console.info('onNewConversation', conversationList)

        // 转换会话数据
        const list = that.convertToConversationList(conversationList)
        // 添加到会话列表（将会自动进行排序）
        that.conversationDataSource.addData(list)
      },
      onConversationDeleted: (conversationIDList: string[]) => {
        console.info('onConversationDeleted', conversationIDList)

        // 从会话列表中删除
        that.conversationDataSource.deleteDataByID(conversationIDList)

      },
      onTotalUnreadMessageCountChanged: (totalUnreadCount: number) => {
        console.info('onTotalUnreadMessageCountChanged', totalUnreadCount)
        that.conversationTotalUnreadCount = totalUnreadCount
        // 通知 UI 层未读数发生变化
        if (that.onUnreadCountChangedCallback) {
          that.onUnreadCountChangedCallback();
        }
      }
    }

    V2TIMManager.getConversationManager().addConversationListener(this.listener);
  }

  private getConversationTotalUnreadCountInternal() {
    V2TIMManager.getConversationManager().getTotalUnreadMessageCount()
      .then((result) => {
        this.conversationTotalUnreadCount = result || 0
      })
      .catch((error: ErrorResult) => {
        console.error(`获取会话总未读消息数失败: ${error.message}`);
      })
  }

  private init() {
    // 这里写初始化逻辑
    this.addConversationListenerInternal();
    this.getConversationTotalUnreadCountInternal();
  }

  private convertToConversationList(v2List: V2TIMConversation[]): Array<ConversationInfo> {
    let list: Array<ConversationInfo> = []
    for (let i = 0; i < v2List.length; i++) {
      const item = v2List[i]
      list.push(this.convertToConversation(item))
    }
    return list
  }

  private convertToConversation(imConversation: V2TIMConversation): ConversationInfo {
    if (!imConversation.conversationID) {
      imConversation.conversationID = '';
    }

    let conversation = new ConversationInfo();
    conversation.ID = imConversation.conversationID;
    conversation.type = this.convertToUIConversationType(imConversation.type)
    conversation.avatarUrl = imConversation.faceUrl || ''
    conversation.title = imConversation.showName || ''
    conversation.subTitle = Util.getMessageAbstract(imConversation.lastMessage) || ''
    conversation.formatTime = this.convertToUIFormatTime(imConversation)
    conversation.unreadCount = imConversation.unreadCount || 0
    conversation.isPinned = imConversation.isPinned || false
    conversation.orderKey = Number.parseInt(imConversation.orderKey.toString());
    conversation.draft = imConversation.draftText || ''
    return conversation
  }

  private convertToUIConversationType(v2Type: number): ConversationType {
    switch (v2Type) {
      case V2TIMConversationType.V2TIM_C2C:
        return ConversationType.C2C
      case V2TIMConversationType.V2TIM_GROUP:
        return ConversationType.GROUP
      default:
        return ConversationType.UNKNOWN
    }
  }

  private convertToUIFormatTime(imConversation: V2TIMConversation): string {
    let date = new Date(0) // distant past
    if (imConversation.draftText && imConversation.draftTimestamp) {
      date = new Date(imConversation.draftTimestamp)
    }
    if (imConversation.lastMessage) {
      date = new Date(imConversation.lastMessage.timestamp)
    }
    return Util.convertDateToHMStr(date) || ''
  }
}
