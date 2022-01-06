import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_add_opt_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/history_message_get_type.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/receive_message_opt_enum.dart';

class EnumUtils {
  static int convertLogLevelEnum(LogLevelEnum loglevel) {
    if (loglevel == LogLevelEnum.V2TIM_LOG_DEBUG) {
      return LogLevel.V2TIM_LOG_DEBUG;
    }

    if (loglevel == LogLevelEnum.V2TIM_LOG_ERROR) {
      return LogLevel.V2TIM_LOG_ERROR;
    }

    if (loglevel == LogLevelEnum.V2TIM_LOG_INFO) {
      return LogLevel.V2TIM_LOG_INFO;
    }

    if (loglevel == LogLevelEnum.V2TIM_LOG_NONE) {
      return LogLevel.V2TIM_LOG_NONE;
    }

    if (loglevel == LogLevelEnum.V2TIM_LOG_WARN) {
      return LogLevel.V2TIM_LOG_WARN;
    }

    return LogLevel.V2TIM_LOG_NONE;
  }

  static int convertMessagePriorityEnum(MessagePriorityEnum priority) {
    if (priority == MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT) {
      return MessagePriority.V2TIM_PRIORITY_DEFAULT;
    }
    if (priority == MessagePriorityEnum.V2TIM_PRIORITY_HIGH) {
      return MessagePriority.V2TIM_PRIORITY_HIGH;
    }
    if (priority == MessagePriorityEnum.V2TIM_PRIORITY_LOW) {
      return MessagePriority.V2TIM_PRIORITY_LOW;
    }
    if (priority == MessagePriorityEnum.V2TIM_PRIORITY_NORMAL) {
      return MessagePriority.V2TIM_PRIORITY_NORMAL;
    }
    return MessagePriority.V2TIM_PRIORITY_NORMAL;
  }

  static int convertReceiveMsgOptEnum(ReceiveMsgOptEnum opt) {
    if (opt == ReceiveMsgOptEnum.V2TIM_NOT_RECEIVE_MESSAGE) {
      return 1;
    }
    if (opt == ReceiveMsgOptEnum.V2TIM_RECEIVE_MESSAGE) {
      return 0;
    }
    if (opt == ReceiveMsgOptEnum.V2TIM_RECEIVE_NOT_NOTIFY_MESSAGE) {
      return 2;
    }

    return 0;
  }

  static int convertHistoryMsgGetTypeEnum(HistoryMsgGetTypeEnum getType) {
    if (getType == HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_NEWER_MSG) {
      return HistoryMessageGetType.V2TIM_GET_CLOUD_NEWER_MSG;
    }
    if (getType == HistoryMsgGetTypeEnum.V2TIM_GET_CLOUD_OLDER_MSG) {
      return HistoryMessageGetType.V2TIM_GET_CLOUD_OLDER_MSG;
    }
    if (getType == HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_NEWER_MSG) {
      return HistoryMessageGetType.V2TIM_GET_LOCAL_NEWER_MSG;
    }
    if (getType == HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG) {
      return HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG;
    }

    return HistoryMessageGetType.V2TIM_GET_LOCAL_OLDER_MSG;
  }

  static int? convertGroupAddOptEnum(GroupAddOptTypeEnum? addOpt) {
    if (addOpt == GroupAddOptTypeEnum.V2TIM_GROUP_ADD_ANY) {
      return GroupAddOptType.V2TIM_GROUP_ADD_ANY;
    }
    if (addOpt == GroupAddOptTypeEnum.V2TIM_GROUP_ADD_AUTH) {
      return GroupAddOptType.V2TIM_GROUP_ADD_AUTH;
    }
    if (addOpt == GroupAddOptTypeEnum.V2TIM_GROUP_ADD_FORBID) {
      return GroupAddOptType.V2TIM_GROUP_ADD_FORBID;
    }
  }

  static int convertGroupMemberFilterEnum(GroupMemberFilterTypeEnum filter) {
    if (filter == GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ADMIN) {
      return GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ADMIN;
    }
    if (filter == GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_ALL) {
      return GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL;
    }
    if (filter == GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_COMMON) {
      return GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_COMMON;
    }
    if (filter == GroupMemberFilterTypeEnum.V2TIM_GROUP_MEMBER_FILTER_OWNER) {
      return GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_OWNER;
    }
    return GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL;
  }

  static int convertGroupMemberRoleTypeEnum(GroupMemberRoleTypeEnum role) {
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_ADMIN) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_ADMIN;
    }
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_MEMBER) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
    }
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_ROLE_OWNER) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_OWNER;
    }
    if (role == GroupMemberRoleTypeEnum.V2TIM_GROUP_MEMBER_UNDEFINED) {
      return GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
    }
    return GroupMemberRoleType.V2TIM_GROUP_MEMBER_UNDEFINED;
  }

  static int? convertGroupApplicationTypeEnum(GroupApplicationTypeEnum? type) {
    if (type ==
        GroupApplicationTypeEnum.V2TIM_GROUP_APPLICATION_GET_TYPE_INVITE) {
      return GroupApplicationType.V2TIM_GROUP_APPLICATION_GET_TYPE_INVITE;
    }

    if (type ==
        GroupApplicationTypeEnum.V2TIM_GROUP_APPLICATION_GET_TYPE_JOIN) {
      return GroupApplicationType.V2TIM_GROUP_APPLICATION_GET_TYPE_JOIN;
    }
  }

  static int convertFriendTypeEnum(FriendTypeEnum type) {
    if (type == FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH) {
      return FriendType.V2TIM_FRIEND_TYPE_BOTH;
    }
    if (type == FriendTypeEnum.V2TIM_FRIEND_TYPE_SINGLE) {
      return FriendType.V2TIM_FRIEND_TYPE_SINGLE;
    }
    return FriendType.V2TIM_FRIEND_TYPE_SINGLE;
  }

  static int? convertFriendResponseTypeEnum(
      FriendResponseTypeEnum responseType) {
    if (responseType == FriendResponseTypeEnum.V2TIM_FRIEND_ACCEPT_AGREE) {
      return FriendApplicationType.V2TIM_FRIEND_ACCEPT_AGREE;
    }
    if (responseType ==
        FriendResponseTypeEnum.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD) {
      return FriendApplicationType.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD;
    }
  }

  static int? convertFriendApplicationTypeEnum(FriendApplicationTypeEnum type) {
    if (type == FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH) {
      return FriendApplicationType.V2TIM_FRIEND_APPLICATION_BOTH;
    }
    if (type == FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_COME_IN) {
      return FriendApplicationType.V2TIM_FRIEND_APPLICATION_COME_IN;
    }
    if (type == FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_SEND_OUT) {
      return FriendApplicationType.V2TIM_FRIEND_APPLICATION_SEND_OUT;
    }
  }
}
