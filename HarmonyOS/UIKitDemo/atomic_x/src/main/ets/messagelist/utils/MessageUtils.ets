import { MessageInfo, MessageType, SystemInfo, SystemMessageType, GroupJoinOption, V2TIMMessage } from 'chatengine';
import { TextUtils } from '../../basecomponent/Index';

export class MessageUtils {
  private static format(template: string, ...args: string[]): string {
    let result = template;
    for (let i = 0; i < args.length; i++) {
      const idx = result.indexOf('%s');
      if (idx < 0) {
        break;
      }
      result = result.substring(0, idx) + (args[i] ?? '') + result.substring(idx + 2);
    }
    return result;
  }
  static getSystemInfoDisplayString(systemInfo?: SystemInfo): string | Resource {
    if (!systemInfo) {
      return "";
    }
    if (systemInfo.type === SystemMessageType.unknown) {
      return $r('app.string.unknown');
    }
    if (systemInfo.type & SystemMessageType.recallMessage) {
      return MessageUtils.getRecallDisplayString(systemInfo);
    }
    return MessageUtils.getGroupTipsDisplayString(systemInfo);
  }

  static getRecallDisplayString(systemInfo: SystemInfo): string | Resource {
    let content = "";
    if (systemInfo.type & SystemMessageType.recallMessage) {
      const reason = systemInfo.recallReason || "";
      if (systemInfo.isRecalledBySelf) {
        return $r('app.string.message_tips_you_recall');
      } else if (systemInfo.isInGroup) {
        const op = systemInfo.recallMessageOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_recall_format'));
        content = MessageUtils.format(tmpl, op);
      } else {
        return $r('app.string.message_tips_others_recall');
      }

      if (reason) {
        content = `${content}: ${reason}`;
      }
    }
    return content;
  }

  static getGroupTipsDisplayString(systemInfo: SystemInfo): string | Resource {
    let display = "";

    if (systemInfo.type & SystemMessageType.joinGroup) {
      const name = systemInfo.joinMember || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_join_group'));
      return MessageUtils.format(tmpl, name);
    } else if (systemInfo.type & SystemMessageType.inviteToGroup) {
      const inviter = systemInfo.inviter || TextUtils.getResourceString($r('app.string.unknown'));
      const invitees = systemInfo.inviteesShowName || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_invite_join_group'));
      return MessageUtils.format(tmpl, inviter, invitees);
    } else if (systemInfo.type & SystemMessageType.quitGroup) {
      const name = systemInfo.quitMember || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_leave_group'));
      return MessageUtils.format(tmpl, name);
    } else if (systemInfo.type & SystemMessageType.kickedFromGroup) {
      const op = systemInfo.kickOperator || TextUtils.getResourceString($r('app.string.unknown'));
      const kicked = systemInfo.kickedMembersShowName || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_kickoff_group'));
      return MessageUtils.format(tmpl, op, kicked);
    } else if (systemInfo.type & SystemMessageType.setGroupAdmin) {
      const name = systemInfo.setAdminMembersShowName || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_set_admin'));
      return MessageUtils.format(tmpl, name);
    } else if (systemInfo.type & SystemMessageType.cancelGroupAdmin) {
      const name = systemInfo.cancelAdminMembersShowName || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_cancel_admin'));
      return MessageUtils.format(tmpl, name);
    } else if (systemInfo.type & SystemMessageType.muteGroupMember) {
      const muteTime = systemInfo.muteTime || 0;
      const memberShowName = systemInfo.mutedGroupMembersShowName || "";
      const isSelfMuted = systemInfo.isSelfMuted || false;
      const actualShowName = isSelfMuted ? TextUtils.getResourceString($r('app.string.you')) : (memberShowName || TextUtils.getResourceString($r('app.string.unknown')));

      if (muteTime === 0) {
        const unmute = TextUtils.getResourceString($r('app.string.message_tips_unmute'));
        return `${actualShowName} ${unmute}`;
      } else {
        const duration = MessageUtils.formatMuteTime(muteTime);
        const muted = TextUtils.getResourceString($r('app.string.message_tips_mute'));
        return `${actualShowName} ${muted} ${duration}`;
      }
    } else if (systemInfo.type & SystemMessageType.pinGroupMessage) {
      const op = systemInfo.pinGroupMessageOperator || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_group_pin'));
      return MessageUtils.format(tmpl, op);
    } else if (systemInfo.type & SystemMessageType.unpinGroupMessage) {
      const op = systemInfo.unpinGroupMessageOperator || TextUtils.getResourceString($r('app.string.unknown'));
      const tmpl = TextUtils.getResourceString($r('app.string.message_tips_group_unpin'));
      return MessageUtils.format(tmpl, op);
    } else {
      const builder: string[] = [];

      if (systemInfo.type & SystemMessageType.changeGroupName) {
        const op = systemInfo.groupNameOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const name = systemInfo.groupName || '';
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_name'));
        return MessageUtils.format(tmpl, op, name);
      }
      if (systemInfo.type & SystemMessageType.changeGroupIntroduction) {
        const op = systemInfo.groupIntroductionOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const intro = systemInfo.groupIntroduction || '';
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_intro'));
        return MessageUtils.format(tmpl, op, intro);
      }
      if (systemInfo.type & SystemMessageType.changeGroupNotification) {
        const op = systemInfo.groupNotificationOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const announce = systemInfo.groupNotification || '';
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_announce'));
        return MessageUtils.format(tmpl, op, announce);
      }
      if (systemInfo.type & SystemMessageType.changeGroupAvatar) {
        const op = systemInfo.groupAvatarOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_avatar'));
        return MessageUtils.format(tmpl, op);
      }
      if (systemInfo.type & SystemMessageType.changeGroupOwner) {
        const op = systemInfo.groupOwnerOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const owner = systemInfo.groupOwner || TextUtils.getResourceString($r('app.string.unknown'));
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_owner'));
        return MessageUtils.format(tmpl, op, owner);
      }
      if (systemInfo.type & SystemMessageType.changeGroupMuteAll) {
        const op = systemInfo.groupMuteAllOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const tmpl = systemInfo.isMuteAll ?
          TextUtils.getResourceString($r('app.string.message_tips_shutup_all')) :
          TextUtils.getResourceString($r('app.string.message_tips_cancel_shutup_all'));
        return MessageUtils.format(tmpl, op);
      }
      if (systemInfo.type & SystemMessageType.changeJoinGroupApproval) {
        const op = systemInfo.groupJoinApprovalOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const approvalDesc = MessageUtils.getJoinApprovalDescription(systemInfo.groupJoinOption);
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_join'));
        return MessageUtils.format(tmpl, op, approvalDesc);
      }
      if (systemInfo.type & SystemMessageType.changeInviteToGroupApproval) {
        const op = systemInfo.groupInviteApprovalOperator || TextUtils.getResourceString($r('app.string.unknown'));
        const approvalDesc = MessageUtils.getInviteApprovalDescription(systemInfo.groupInviteOption);
        const tmpl = TextUtils.getResourceString($r('app.string.message_tips_edit_group_invite'));
        return MessageUtils.format(tmpl, op, approvalDesc);
      }

      display = builder.join(", ");
    }

    return display;
  }

  static getMessageAbstract(messageInfo?: MessageInfo): string | Resource {
    if (!messageInfo) {
      return "";
    }

    switch (messageInfo.messageType) {
      case MessageType.Text:
        return messageInfo.messageBody?.text || "";
      case MessageType.Image:
        return $r('app.string.message_type_image');
      case MessageType.Sound:
        return $r('app.string.message_type_voice');
      case MessageType.File:
        return $r('app.string.message_type_file');
      case MessageType.Video:
        return $r('app.string.message_type_video');
      case MessageType.Face:
        return $r('app.string.message_type_animate_emoji');
      case MessageType.Custom:
        const customInfo = messageInfo.messageBody?.customInfo;
        if (customInfo && customInfo["businessID"] === "group_create") {
          const sender = customInfo["opUser"] as string || "";
          const cmd = customInfo["cmd"] as number || 0;
          if (cmd === 1) {
            const tmpl = TextUtils.getResourceString($r('app.string.community_create_tips_format'));
            return MessageUtils.format(tmpl, sender);
          } else {
            const tmpl = TextUtils.getResourceString($r('app.string.group_create_tips_format'));
            return MessageUtils.format(tmpl, sender);
          }
        } else {
          return TextUtils.getResourceString($r('app.string.message_tips_unsupport_custom'));
        }
      case MessageType.System:
        return MessageUtils.getSystemInfoDisplayString(messageInfo.messageBody?.systemInfo);
      default:
        return "";
    }
  }

  static formatMuteTime(seconds: number): string {
    if (seconds <= 0) {
      return "";
    }

    let timeStr = `${seconds} second${seconds > 1 ? 's' : ''}`;

    if (seconds > 60) {
      const second = seconds % 60;
      let min = Math.floor(seconds / 60);
      timeStr = `${min} min ${second} sec`;

      if (min > 60) {
        min = Math.floor(seconds / 60) % 60;
        const hour = Math.floor(Math.floor(seconds / 60) / 60);
        timeStr = `${hour} hour ${min} min ${second} sec`;

        if (hour % 24 === 0) {
          const day = Math.floor(Math.floor(Math.floor(seconds / 60) / 60) / 24);
          timeStr = `${day} day${day > 1 ? 's' : ''}`;
        } else if (hour > 24) {
          const newHour = Math.floor(Math.floor(seconds / 60) / 60) % 24;
          const day = Math.floor(Math.floor(Math.floor(seconds / 60) / 60) / 24);
          timeStr = `${day} day ${newHour} hour ${min} min ${second} sec`;
        }
      }
    }

    return timeStr;
  }

  static convertDateToHMStr(timeStamp?: number): string {
    if (!timeStamp) {
      return "";
    }
    if (timeStamp === 0) {
      return "";
    }

    const date = new Date(timeStamp * 1000);
    const hours = date.getHours().toString().padStart(2, '0');
    const minutes = date.getMinutes().toString().padStart(2, '0');
    return `${hours}:${minutes}`;
  }

  static convertDateToYMDStr(timeStamp?: number): string {
    if (!timeStamp) {
      return "";
    }

    const date = new Date(timeStamp * 1000);
    const now = new Date();

    const nowYear = now.getFullYear();
    const nowMonth = now.getMonth();
    const nowDate = now.getDate();
    const nowWeek = MessageUtils.getWeekOfMonth(now);

    const dateYear = date.getFullYear();
    const dateMonth = date.getMonth();
    const dateDate = date.getDate();
    const dateWeek = MessageUtils.getWeekOfMonth(date);

    if (nowYear !== dateYear) {
      return `${dateYear}/${(dateMonth + 1).toString().padStart(2, '0')}/${dateDate.toString().padStart(2, '0')}`;
    } else if (nowMonth !== dateMonth) {
      return `${(dateMonth + 1).toString().padStart(2, '0')}/${dateDate.toString().padStart(2, '0')}`;
    } else if (nowWeek !== dateWeek) {
      return `${(dateMonth + 1).toString().padStart(2, '0')}/${dateDate.toString().padStart(2, '0')}`;
    } else if (nowDate !== dateDate) {
      return MessageUtils.getWeekdayString(date);
    } else {
      const hours = date.getHours().toString().padStart(2, '0');
      const minutes = date.getMinutes().toString().padStart(2, '0');
      return `${hours}:${minutes}`;
    }
  }

  private static getWeekOfMonth(date: Date): number {
    const firstDay = new Date(date.getFullYear(), date.getMonth(), 1);
    const firstDayOfWeek = firstDay.getDay();
    return Math.ceil((date.getDate() + firstDayOfWeek) / 7);
  }

  private static getWeekdayString(date: Date): string {
    switch (date.getDay()) {
      case 0:
        return TextUtils.getResourceString($r('app.string.sunday'));
      case 1:
        return TextUtils.getResourceString($r('app.string.monday'));
      case 2:
        return TextUtils.getResourceString($r('app.string.tuesday'));
      case 3:
        return TextUtils.getResourceString($r('app.string.wednesday'));
      case 4:
        return TextUtils.getResourceString($r('app.string.thursday'));
      case 5:
        return TextUtils.getResourceString($r('app.string.friday'));
      case 6:
        return TextUtils.getResourceString($r('app.string.saturday'));
      default:
        return TextUtils.getResourceString($r('app.string.unknown'));
    }
  }

  private static getJoinApprovalDescription(option?: GroupJoinOption): string {
    switch (option) {
      case GroupJoinOption.FORBID:
        return TextUtils.getResourceString($r('app.string.group_join_disable'));
      case GroupJoinOption.AUTH:
        return TextUtils.getResourceString($r('app.string.group_admin_approve'));
      case GroupJoinOption.ANY:
        return TextUtils.getResourceString($r('app.string.group_auto_approval'));
      default:
        return TextUtils.getResourceString($r('app.string.unknown'));
    }
  }

  private static getInviteApprovalDescription(option?: GroupJoinOption): string {
    switch (option) {
      case GroupJoinOption.FORBID:
        return TextUtils.getResourceString($r('app.string.group_invite_disable'));
      case GroupJoinOption.AUTH:
        return TextUtils.getResourceString($r('app.string.group_admin_approve'));
      case GroupJoinOption.ANY:
        return TextUtils.getResourceString($r('app.string.group_auto_approval'));
      default:
        return TextUtils.getResourceString($r('app.string.unknown'));
    }
  }
}

export function getMessageSenderDisplayName(imMessage: V2TIMMessage): string {
  if (!imMessage) {
    return "";
  }

  let displayName = "";
  if (imMessage.nameCard) {
    displayName = imMessage.nameCard;
  } else if (imMessage.friendRemark) {
    displayName = imMessage.friendRemark;
  } else if (imMessage.nickName) {
    displayName = imMessage.nickName;
  } else {
    displayName = imMessage.sender || "";
  }

  return displayName;
}
