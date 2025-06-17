import {
  V2TIMManager,
  V2TIMMessage,
  V2TIMElemType,
  V2TIMGroupTipsElem,
  V2TIMGroupMemberInfo,
  V2TIMMessageStatus,
  V2TIMGroupTipsType,
  V2TIMUserInfo,
  V2TIMGroupAddOpt,
  V2TIMGroupInfoChangeType,
  V2TIMImageType
} from '@tencentcloud/imsdk'
import resourceManager from '@ohos.resourceManager'
import fileIO from '@ohos.fileio'
import fileio from '@ohos.fileio'
import fs from '@ohos.file.fs'
import util from '@ohos.util'
import { ChatEngine } from './ChatEngine'
import { MessageType } from './MessageListState'

/**
 * 工具类
 */
export class Util {
  private static readonly HOME_PATH: string = '/data/storage/el2/base/haps/entry/files/com_tencent_imsdk_data'
  private static resourceMgr: resourceManager.ResourceManager | null = null

  /**
   * 获取字符串资源的简化辅助函数
   * @param resource 字符串资源ID，例如 $r('app.string.xxx')
   * @returns 字符串资源内容
   */
  static getResourceString(resource: Resource): string {
    return getContext().getApplicationContext().resourceManager.getStringSync(resource);
  }

  /**
   * 获取主目录路径
   */
  static getHomePath(): string {
    return getContext().getApplicationContext().cacheDir + "/com_tencent_imsdk_data";
    return Util.HOME_PATH
  }

  /**
   * 确保目录存在，如果不存在则创建
   * @param dirPath 目录路径
   * @returns 是否成功确保目录存在
   */
  static ensureDirectoryExists(dirPath: string): boolean {
    try {
      // 检查目录是否存在
      try {
        const stats = fs.statSync(dirPath);
        if (stats.isDirectory()) {
          // 目录已存在
          return true;
        }
      } catch (error) {
        // 目录不存在，创建目录
        try {
          // 递归创建目录
          fs.mkdirSync(dirPath, true);
          console.info(`[Util] Directory created: ${dirPath}`);
          return true;
        } catch (mkdirError) {
          console.error(`[Util] Failed to create directory: ${dirPath}, error: ${JSON.stringify(mkdirError)}`);
          return false;
        }
      }
    } catch (error) {
      console.error(`[Util] Failed to ensure directory exists: ${dirPath}, error: ${JSON.stringify(error)}`);
      return false;
    }
    return false;
  }

  /**
   * 获取媒体文件存储路径
   */
  static getMediaHomePath(messageType: MessageType): string {
    let path = "";
    if (messageType === MessageType.Image) {
      path = Util.getHomePath() + '/image/';
    } else if (messageType === MessageType.Video) {
      path = Util.getHomePath() + '/video/';
    } else if (messageType === MessageType.Sound) {
      path = Util.getHomePath() + '/voice/';
    } else if (messageType === MessageType.File) {
      path = Util.getHomePath() + '/file/';
    } else {
      return '';
    }

    // 确保媒体目录存在
    Util.ensureDirectoryExists(path);
    return path;
  }

  /**
   * 生成媒体文件路径
   */
  static generateMediaPath(messageType: MessageType, extension?: string): string {
    const sdkAppID = ChatEngine.getInstance().currentSDKAppID
    const userID = ChatEngine.getInstance().currentUserInfo?.userID
    const uuid = `${Math.floor(Date.now() / 1000)}_${Math.floor(Math.random() * 1000)}`

    if (messageType === MessageType.Image) {
      return Util.getMediaHomePath(MessageType.Image) + `${sdkAppID}_${userID || ''}${uuid}.${extension || ''}`
    } else if (messageType === MessageType.Video) {
      return Util.getMediaHomePath(MessageType.Video) + `${sdkAppID}_${userID || ''}${uuid}.${extension || ''}`
    } else if (messageType === MessageType.Sound) {
      return Util.getMediaHomePath(MessageType.Sound) + `${sdkAppID}_${userID || ''}${uuid}.${extension || ''}`
    } else if (messageType === MessageType.File) {
      return Util.getMediaHomePath(MessageType.File) + `${sdkAppID}_${userID || ''}${uuid}.${extension || ''}`
    }
    return ''
  }

  /**
   * 从会话ID中获取用户ID
   */
  static getUserID(conversationID: string): string | null {
    const c2cPrefix = 'c2c_'
    if (conversationID.startsWith(c2cPrefix)) {
      return conversationID.substring(c2cPrefix.length)
    }
    return null;
  }

  /**
   * 从会话ID中获取群组ID
   */
  static getGroupID(conversationID: string): string | null {
    const groupPrefix = 'group_'
    if (conversationID.startsWith(groupPrefix)) {
      return conversationID.substring(groupPrefix.length)
    }
    return null;
  }

  /**
   * 获取群成员显示名称
   */
  static getMemberShowName(info?: V2TIMGroupMemberInfo): string {
    if (!info) {
      return ''
    }

    if (info.nameCard && info.nameCard.length > 0) {
      return info.nameCard
    } else if (info.nickName && info.nickName.length > 0) {
      return info.nickName
    } else {
      return info.userID
    }
  }

  /**
   * 获取群成员显示名称（从群提示消息中获取）
   */
  static getMemberShowNameFromTips(tips?: V2TIMGroupTipsElem, userId?: string): string {
    if (!tips || !userId) {
      return ''
    }

    const list = tips.memberList
    if (list) {
      for (const info of list) {
        if (info.userID === userId) {
          return Util.getMemberShowName(info)
        }
      }
    }
    return ''
  }

  /**
   * 获取群成员显示名称列表
   */
  static getMembersShowName(infoList?: V2TIMGroupMemberInfo[]): string[] {
    if (!infoList) {
      return []
    }

    const userNameList: string[] = []
    for (const info of infoList) {
      userNameList.push(Util.getMemberShowName(info))
    }
    return userNameList
  }

  /**
   * 获取消息发送者名称
   */
  static getMessageSenderName(message?: V2TIMMessage): string {
    if (!message) {
      return ''
    }

    let showName = message.sender
    if (message.nameCard && message.nameCard.length > 0) {
      showName = message.nameCard
    } else if (message.friendRemark && message.friendRemark.length > 0) {
      showName = message.friendRemark
    } else if (message.nickName && message.nickName.length > 0) {
      showName = message.nickName
    }
    return showName || ''
  }

  /**
   * 获取消息摘要
   */
  static getMessageAbstract(imMessage?: V2TIMMessage): string | Resource {
    if (!imMessage) {
      return ''
    }

    if (imMessage.status === V2TIMMessageStatus.V2TIM_MSG_STATUS_LOCAL_REVOKED) {
      return Util.getRevokeDispayString(imMessage)
    }

    switch (imMessage.elemType) {
      case V2TIMElemType.V2TIM_ELEM_TYPE_TEXT:
        return imMessage.textElem?.text || ''

      case V2TIMElemType.V2TIM_ELEM_TYPE_IMAGE:
        return $r('app.string.message_type_image')

      case V2TIMElemType.V2TIM_ELEM_TYPE_SOUND:
        return $r('app.string.message_type_voice')

      case V2TIMElemType.V2TIM_ELEM_TYPE_FILE:
        return $r('app.string.message_type_file')

      case V2TIMElemType.V2TIM_ELEM_TYPE_VIDEO:
        return $r('app.string.message_type_video')

      case V2TIMElemType.V2TIM_ELEM_TYPE_FACE:
        return $r('app.string.message_type_animate_emoji')

      case V2TIMElemType.V2TIM_ELEM_TYPE_CUSTOM:
        return $r('app.string.message_tips_unsupport_custom')

      case V2TIMElemType.V2TIM_ELEM_TYPE_GROUP_TIPS:
        const tipsElem = imMessage.groupTipsElem
        if (!tipsElem) {
          break
        }

        if (tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_JOIN ||
          tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_INVITE ||
          tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_KICKED ||
          tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE ||
          tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_QUIT ||
          tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED ||
          tipsElem.type === V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED) {
          return Util.getGroupTipsDisplayString(tipsElem) || ''
        }
        break

      default:
        return ''
    }
    return ''
  }

  /**
   * 获取消息撤回的显示文本
   */
  static getRevokeDispayString(message: V2TIMMessage, operateUser?: V2TIMUserInfo, reason?: string): string {
    const revokerInfo = message.revokerInfo || operateUser
    let revoker = message.sender
    const messageSender = message.sender

    if (revokerInfo) {
      revoker = revokerInfo.userID
    }

    let content = Util.getResourceString($r('app.string.message_tips_normal_recall'))
    if (revoker === messageSender) {
      if (message.isSelf) {
        content = Util.getResourceString($r('app.string.message_tips_you_recall'))
      } else {
        if (message.userID && message.userID.length > 0) {
          content = Util.getResourceString($r('app.string.message_tips_others_recall'))
        } else if (message.groupID && message.groupID.length > 0) {
          const userName = Util.getMessageSenderName(message)
          content = `${userName} ${Util.getResourceString($r('app.string.message_tips_recall'))}`
        }
      }
    } else {
      let userName = Util.getMessageSenderName(message)
      if (revokerInfo) {
        userName = revokerInfo.nickName || revokerInfo.userID
      }
      content = `${userName} ${Util.getResourceString($r('app.string.message_tips_recall'))}`
    }
    return content
  }

  /**
   * 获取群提示消息的显示文本
   */
  static getGroupTipsDisplayString(tipsElem: V2TIMGroupTipsElem): string | Resource {
    const opUser = Util.getMemberShowName(tipsElem.opMember)
    const userList = Util.getMembersShowName(tipsElem.memberList)
    let str: string | null = null

    switch (tipsElem.type) {
      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_JOIN:
        if (opUser.length > 0) {
          if (userList.length === 0 || (userList.length === 1 && opUser === userList[0])) {
            str = Util.getResourceString($r('app.string.message_tips_join_group')).replace('%s', opUser)
          } else {
            const users = userList.join('、')
            str = Util.getResourceString($r('app.string.message_tips_invite_join_group'))
              .replace('%s', opUser)
              .replace('%s', users)
          }
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_INVITE:
        if (userList.length > 0) {
          const users = userList.join('、')
          str = Util.getResourceString($r('app.string.message_tips_invite_join_group'))
            .replace('%s', opUser)
            .replace('%s', users)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_QUIT:
        if (opUser.length > 0) {
          str = Util.getResourceString($r('app.string.message_tips_leave_group')).replace('%s', opUser)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_KICKED:
        if (userList.length > 0) {
          const users = userList.join('、')
          str = Util.getResourceString($r('app.string.message_tips_kickoff_group'))
            .replace('%s', opUser)
            .replace('%s', users)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_SET_ADMIN:
        if (userList.length > 0) {
          const users = userList.join('、')
          str = Util.getResourceString($r('app.string.message_tips_set_admin')).replace('%s', users)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN:
        if (userList.length > 0) {
          const users = userList.join('、')
          str = Util.getResourceString($r('app.string.message_tips_cancel_admin')).replace('%s', users)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_GROUP_INFO_CHANGE:
        str = Util.getGroupInfoChangedFormatStr(opUser, userList, tipsElem)
        if (str && str.length > 0) {
          str = str.substring(0, str.length - 1)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE:
        if (tipsElem.memberChangeInfoList && tipsElem.memberChangeInfoList.length > 0) {
          const info = tipsElem.memberChangeInfoList[0]
          const userId = info.userID
          const muteTime = info.muteTime
          const myUserID = ChatEngine.getInstance().currentUserInfo?.userID
          const showName = Util.getMemberShowNameFromTips(tipsElem, userId)

          str = `${userId === myUserID ? Util.getResourceString($r('app.string.you')) : showName} ${
          muteTime === 0 ? Util.getResourceString($r('app.string.message_tips_unmute')) :
          Util.getResourceString($r('app.string.message_tips_mute'))
          }`
          break
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_ADDED:
        if (opUser.length > 0) {
          str = Util.getResourceString($r('app.string.message_tips_group_pin')).replace('%s', opUser)
        }
        break

      case V2TIMGroupTipsType.V2TIM_GROUP_TIPS_TYPE_PINNED_MESSAGE_DELETED:
        if (opUser.length > 0) {
          str = Util.getResourceString($r('app.string.message_tips_group_unpin')).replace('%s', opUser)
        }
        break

      default:
        break
    }

    return str || ''
  }

  /**
   * 获取群信息变更的格式化字符串
   */
  static getGroupInfoChangedFormatStr(opUser: string, userList: string[], tips: V2TIMGroupTipsElem): string {
    let str = opUser

    if (tips.groupChangeInfoList && tips.groupChangeInfoList.length > 0) {
      for (const info of tips.groupChangeInfoList) {
        switch (info.type) {

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_NAME:
            if (info.value) {
              str = Util.getResourceString($r('app.string.message_tips_edit_group_name'))
                .replace('%s', str)
                .replace('%s', info.value)
            }
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_INTRODUCTION:
            if (info.value) {
              str = Util.getResourceString($r('app.string.message_tips_edit_group_intro'))
                .replace('%s', str)
                .replace('%s', info.value)
            }
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_NOTIFICATION:
            if (info.value) {
              str = Util.getResourceString($r('app.string.message_tips_edit_group_announce'))
                .replace('%s', str)
                .replace('%s', info.value)
            } else {
              str = Util.getResourceString($r('app.string.message_tips_delete_group_announce')).replace('%s', str)
            }
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_FACE:
            str = Util.getResourceString($r('app.string.message_tips_edit_group_avatar')).replace('%s', str)
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_OWNER:
            if (userList.length > 0) {
              str = Util.getResourceString($r('app.string.message_tips_edit_group_owner'))
                .replace('%s', str)
                .replace('%s', userList[0])
            } else if (info.value) {
              str = Util.getResourceString($r('app.string.message_tips_edit_group_owner'))
                .replace('%s', str)
                .replace('%s', info.value)
            }
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_SHUT_UP_ALL:
            if (info.boolValue) {
              str = Util.getResourceString($r('app.string.message_tips_shutup_all')).replace('%s', opUser)
            } else {
              str = Util.getResourceString($r('app.string.message_tips_cancel_shutup_all')).replace('%s', opUser)
            }
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_ADD_OPT:
            const addOpt = info.intValue
            let addOptDesc = Util.getResourceString($r('app.string.unknown'))

            if (addOpt === V2TIMGroupAddOpt.V2TIM_GROUP_ADD_FORBID) {
              addOptDesc = Util.getResourceString($r('app.string.group_join_disable'))
            } else if (addOpt === V2TIMGroupAddOpt.V2TIM_GROUP_ADD_AUTH) {
              addOptDesc = Util.getResourceString($r('app.string.group_admin_approve'))
            } else if (addOpt === V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY) {
              addOptDesc = Util.getResourceString($r('app.string.group_auto_approval'))
            }

            str = Util.getResourceString($r('app.string.message_tips_edit_group_join'))
              .replace('%s', str)
              .replace('%s', addOptDesc)
            break

          case V2TIMGroupInfoChangeType.V2TIM_GROUP_INFO_CHANGE_TYPE_GROUP_APPROVE_OPT:
            const approveOpt = info.intValue
            let approveOptDesc = Util.getResourceString($r('app.string.unknown'))

            if (approveOpt === V2TIMGroupAddOpt.V2TIM_GROUP_ADD_FORBID) {
              approveOptDesc = Util.getResourceString($r('app.string.group_invite_disable'))
            } else if (approveOpt === V2TIMGroupAddOpt.V2TIM_GROUP_ADD_AUTH) {
              approveOptDesc = Util.getResourceString($r('app.string.group_admin_approve'))
            } else if (approveOpt === V2TIMGroupAddOpt.V2TIM_GROUP_ADD_ANY) {
              approveOptDesc = Util.getResourceString($r('app.string.group_auto_approval'))
            }

            str = Util.getResourceString($r('app.string.message_tips_edit_group_invite'))
              .replace('%s', str)
              .replace('%s', approveOptDesc)
            break

          default:
            break
        }
      }
    }

    return str
  }

  /**
   * 将字典转换为 JSON 数据
   * @param dictionary 要转换的字典
   * @returns JSON ArrayBuffer 数据，失败返回 null
   */
  static dictionary2JsonData(jsonStr: string): Object | null {
    try {
      return JSON.parse(jsonStr);
    } catch (error) {
      console.error('jsonToData 解析失败:', error);
      return null;
    }
  }

  /**
   * 将 JSON 数据转换为字典
   * @param jsonData JSON ArrayBuffer 数据
   * @returns 转换后的字典，失败返回 null
   */
  static jsonData2Dictionary(jsonData?: Object): string {
    try {
      return JSON.stringify(jsonData);
    } catch (error) {
      console.error('dataToJson 转换失败:', error);
      return '';
    }
  }

  /**
   * 时间格式化为HH:mm
   */
  static convertDateToHMStr(date?: Date): string | null {
    if (!date) {
      return null
    }

    if (date.getTime() === new Date(0).getTime()) {
      return ''
    }

    const hours = date.getHours().toString().padStart(2, '0')
    const minutes = date.getMinutes().toString().padStart(2, '0')
    return `${hours}:${minutes}`
  }

  /**
   * 转换日期为分割线信息
   */
  static convertDateToSeparatorInfo(date: Date): string | Resource {
    if (date.getTime() === new Date(0).getTime()) {
      return ''
    }

    const now = new Date()
    const nowYear = now.getFullYear()
    const nowMonth = now.getMonth()
    const nowDay = now.getDate()
    const nowWeek = Util.getWeekOfMonth(now)

    const dateYear = date.getFullYear()
    const dateMonth = date.getMonth()
    const dateDay = date.getDate()
    const dateWeek = Util.getWeekOfMonth(date)

    if (nowYear === dateYear) {
      if (nowMonth === dateMonth) {
        if (nowWeek === dateWeek) {
          if (nowDay === dateDay) {
            return Util.convertDateToHMStr(date) || ''
          } else {
            return Util.getWeekdayString(date)
          }
        } else {
          return `${dateMonth + 1}/${dateDay}`
        }
      } else {
        return `${dateMonth + 1}/${dateDay}`
      }
    } else {
      return `${dateYear}/${dateMonth + 1}/${dateDay}`
    }
  }

  /**
   * 获取周数
   */
  static getWeekOfMonth(date: Date): number {
    const firstDay = new Date(date.getFullYear(), date.getMonth(), 1)
    const firstDayWeekday = firstDay.getDay() || 7
    const offset = firstDayWeekday - 1
    const dayOfMonth = date.getDate()
    return Math.ceil((dayOfMonth + offset) / 7)
  }

  /**
   * 获取星期字符串
   */
  static getWeekdayString(date: Date): string | Resource {
    const weekday = date.getDay()
    switch (weekday) {
      case 0:
        return $r('app.string.sunday')
      case 1:
        return $r('app.string.monday')
      case 2:
        return $r('app.string.tuesday')
      case 3:
        return $r('app.string.wednesday')
      case 4:
        return $r('app.string.thursday')
      case 5:
        return $r('app.string.friday')
      case 6:
        return $r('app.string.saturday')
      default:
        return ''
    }
  }
}
