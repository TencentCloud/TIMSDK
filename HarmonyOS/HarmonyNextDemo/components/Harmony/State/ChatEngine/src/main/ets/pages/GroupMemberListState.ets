import {
  V2TIMManager,
  V2TIMGroupMemberInfo,
  V2TIMGroupMemberFilter,
  V2TIMGroupMessageReadMembersFilter,
  V2TIMMessage
} from '@tencentcloud/imsdk'
import { MessageInfo } from './MessageListState'
import { ErrorResult } from './ChatEngine'
import notificationCenter from './NotificationCenter'

////////////////////////////////////////////////////////////
// 数据定义
////////////////////////////////////////////////////////////

/**
 * 群成员信息类
 */
export class GroupMemberInfo {
  userID?: string = '' // 用户ID
  nickName?: string = '' // 昵称
  faceURL?: string = '' // 头像URL
  nameCard?: string = '' // 群名片

  constructor(userID: string) {
    this.userID = userID
  }
}

/**
 * 群成员获取类型枚举
 */
export enum GroupMemberGetType {
  BY_GROUP_ID, // 通过群ID获取
  BY_MESSAGE   // 通过消息获取已读/未读成员
}

/**
 * 群成员获取选项类
 */
export class GroupMemberGetOption {
  getType?: GroupMemberGetType = GroupMemberGetType.BY_GROUP_ID

  // 通过 groupID 获取群成员
  groupID?: string = ''

  // 通过 message 获取消息已读|未读群成员
  message?: MessageInfo
  isRead?: boolean = false

  // 分页参数
  nextSeq?: number = 0
  count?: number = 100

  constructor() {}
}

// 事件类型定义
export enum GroupMemberEventKey {
  MEMBER_LIST_UPDATED = 'memberListUpdated',
  MEMBER_LIST_LOADED_MORE = 'memberListLoadedMore'
}

// 事件数据定义
export class GroupMemberEventData {
  memberList?: Array<GroupMemberInfo>
}

////////////////////////////////////////////////////////////
// 群成员列表状态
////////////////////////////////////////////////////////////
export class GroupMemberListState {
  groupMemberList: Array<GroupMemberInfo> = []
  hasMoreGroupMember: boolean = true

  private option?: GroupMemberGetOption

  /**
   * 获取群成员列表
   * @param option 群成员获取选项
   * @returns Promise<void>
   */
  fetchGroupMembers(option: GroupMemberGetOption): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.fetchGroupMembersInternal(option, resolve, reject)
    })
  }

  /**
   * 加载更多群成员
   * @returns Promise<void>
   */
  loadMoreGroupMembers(): Promise<void> {
    return new Promise<void>((resolve, reject) => {
      this.loadMoreGroupMembersInternal(resolve, reject)
    })
  }

  /**
   * 获取群成员列表内部实现
   */
  private fetchGroupMembersInternal(
    option: GroupMemberGetOption,
    resolve: () => void,
    reject: (error: ErrorResult) => void
  ): void {
    switch (option.getType) {
      case GroupMemberGetType.BY_GROUP_ID:
        if (!option.groupID) {
          reject(new ErrorResult(-1, $r('app.string.group_id_empty').toString()))
          return
        }
        this.fetchGroupMembersByGroupID(option.groupID, option, resolve, reject)
        break
      case GroupMemberGetType.BY_MESSAGE:
        if (!option.message) {
          reject(new ErrorResult(-1, $r('app.string.message_empty').toString()))
          return
        }
        // Ensure isRead is a boolean by using !! or providing a default
        const isRead = option.isRead !== undefined ? option.isRead : false
        this.fetchGroupMembersByMessage(option.message, isRead, option, resolve, reject)
        break
    }
  }

  /**
   * 加载更多群成员内部实现
   */
  private loadMoreGroupMembersInternal(resolve: () => void, reject: (error: ErrorResult) => void): void {
    if (!this.hasMoreGroupMember) {
      resolve()
      return
    }

    if (!this.option) {
      reject(new ErrorResult(-1, $r('app.string.fetch_members_first').toString()))
      return
    }

    this.fetchGroupMembers(this.option)
      .then(() => {
        resolve()
      })
      .catch((error:ErrorResult) => {
        reject(error)
      })
  }

  /**
   * 通过群组ID获取群成员
   */
  private fetchGroupMembersByGroupID(
    groupID: string,
    option: GroupMemberGetOption,
    resolve: () => void,
    reject: (error: ErrorResult) => void
  ): void {
    const that = this

    V2TIMManager.getGroupManager().getGroupMemberList(
      groupID,
      V2TIMGroupMemberFilter.V2TIM_GROUP_MEMBER_FILTER_ALL,
      option.nextSeq || 0
    )
    .then((result) => {
      // 保存选项以便加载更多
      that.option = option

      // 添加新成员并更新状态
      const newMembers = that.convertToUIGroupMemberList(result.memberInfoList)
      that.groupMemberList = [...that.groupMemberList, ...newMembers]
      if (that.option) {
        that.option.nextSeq = result.nextSequence
      }
      that.hasMoreGroupMember = result.nextSequence !== 0

      // 发送事件通知
      const eventData = new Map<string, Object>();
      eventData.set('memberList', newMembers);
      notificationCenter.post(GroupMemberEventKey.MEMBER_LIST_UPDATED, eventData);

      resolve()
    })
    .catch((error: ErrorResult) => {
      reject(new ErrorResult(error.code || -1, error.message || $r('app.string.fetch_members_failed').toString()))
    })
  }

  /**
   * 通过消息获取群成员
   */
  private fetchGroupMembersByMessage(
    message: MessageInfo,
    isRead: boolean,
    option: GroupMemberGetOption,
    resolve: () => void,
    reject: (error: ErrorResult) => void
  ): void {
    if (!message.imMessage) {
      reject(new ErrorResult(-1, $r('app.string.message_not_found').toString()))
      return
    }

    const that = this
    const filter = isRead ?
      V2TIMGroupMessageReadMembersFilter.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_READ :
      V2TIMGroupMessageReadMembersFilter.V2TIM_GROUP_MESSAGE_READ_MEMBERS_FILTER_UNREAD

    V2TIMManager.getMessageManager().getGroupMessageReadMemberList(
      message.imMessage,
      filter,
      option.nextSeq || 0,
      option.count || 100
    )
    .then((result) => {
      // 保存选项以便加载更多
      that.option = option
      
      // 添加新成员并更新状态
      const newMembers = that.convertToUIGroupMemberList(result.members)
      that.groupMemberList = [...that.groupMemberList, ...newMembers]
      if (that.option) {
        that.option.nextSeq = result.nextSeq
      }
      that.hasMoreGroupMember = !result.isFinished

      // 发送事件通知
      const eventData = new Map<string, Object>();
      eventData.set('memberList', newMembers);
      notificationCenter.post(GroupMemberEventKey.MEMBER_LIST_UPDATED, eventData);

      resolve()
    })
    .catch((error: ErrorResult) => {
      reject(new ErrorResult(error.code || -1, error.message || $r('app.string.fetch_members_failed').toString()))
    })
  }

  /**
   * 转换群成员列表
   */
  private convertToUIGroupMemberList(imMembers: V2TIMGroupMemberInfo[]): Array<GroupMemberInfo> {
    return imMembers.map(member => this.convertToUIGroupMember(member))
  }

  /**
   * 转换单个群成员
   */
  private convertToUIGroupMember(imMember: V2TIMGroupMemberInfo): GroupMemberInfo {
    const member = new GroupMemberInfo(imMember.userID)
    member.nameCard = imMember.nameCard || ''
    member.nickName = imMember.nickName || ''
    member.faceURL = imMember.faceURL || ''
    return member
  }
}
