import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_search_param.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

/// 群组高级接口，包含了群组的高级功能，例如群成员邀请、非群成员申请进群等操作接口。
///
///[createGroup]创建自定义群组（高级版本：可以指定初始的群成员）
///
///[getJoinedGroupList]获取当前用户已经加入的群列表
///
///[getGroupsInfo]拉取群资料
///
///[setGroupInfo]修改群资料
///
///[setReceiveMessageOpt]修改群消息接收选项
///
///[initGroupAttributes]初始化群属性，会清空原有的群属性列表
///
///[setGroupAttributes]设置群属性。已有该群属性则更新其 value 值，没有该群属性则添加该属性。
///
///[deleteGroupAttributes]删除指定群属性，keys 传 null 则清空所有群属性。
///
///[getGroupAttributes]获取指定群属性，keys 传 null 则获取所有群属性。
///
///[getGroupMemberList]获取群成员列表
///
///[getGroupMembersInfo]获取指定的群成员资料
///
///[setGroupMemberInfo]修改指定的群成员资料
///
///[muteGroupMember]禁言（只有管理员或群主能够调用）
///
///[inviteUserToGroup]邀请他人入群
///
///[kickGroupMember]踢人
///
///[setGroupMemberRole]切换群成员的角色。
///
///[transferGroupOwner]转让群主
///
///[getGroupApplicationList]获取加群的申请列表
///
///[acceptGroupApplication]同意某一条加群申请
///
///[refuseGroupApplication]拒绝某一条加群申请
///
///[setGroupApplicationRead]标记申请列表为已读
///
/// {@category Manager}
///
class V2TIMGroupManager {
  ///@nodoc
  late MethodChannel _channel;

  ///@nodoc
  V2TIMGroupManager(channel) {
    _channel = channel;
  }

  ///创建自定义群组（高级版本：可以指定初始的群成员）
  ///
  /// 参数
  ///
  /// ```
  /// info	自定义群组信息，可以设置 groupID | groupType | groupName | notification | introduction | faceURL 字段
  /// memberList	指定初始的群成员（直播群 AVChatRoom 不支持指定初始群成员，memberList 请传 null）
  /// ```
  ///
  /// 注意
  ///
  /// ```
  /// 其他限制请参考V2TIMManager.createGroup注释
  /// ```
  Future<V2TimValueCallback<String>> createGroup({
    String? groupID,
    required String groupType,
    required String groupName,
    String? notification,
    String? introduction,
    String? faceUrl,
    bool? isAllMuted,
    int? addOpt,
    List<Map>? memberList,
  }) async {
    return V2TimValueCallback<String>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createGroup",
          buildParam(
            {
              "groupID": groupID,
              "groupType": groupType,
              "groupName": groupName,
              "notification": notification,
              "introduction": introduction,
              "faceUrl": faceUrl,
              "isAllMuted": isAllMuted,
              "addOpt": addOpt,
              "memberList": memberList,
            },
          ),
        ),
      ),
    );
  }

  /// 获取当前用户已经加入的群列表
  ///
  /// 注意
  ///
  /// ```
  /// 直播群(AVChatRoom) 不支持该 API。
  /// 该接口有频限检测，SDK 限制调用频率为1 秒 10 次，超过限制后会报 ERR_SDK_COMM_API_CALL_FREQUENCY_LIMIT （7008）错误
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> getJoinedGroupList() async {
    return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getJoinedGroupList",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  /// 拉取群资料
  ///
  /// 参数
  ///
  /// ```
  /// groupIDList	群 ID 列表
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupInfoResult>>> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    return V2TimValueCallback<List<V2TimGroupInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupsInfo",
          buildParam(
            {
              "groupIDList": groupIDList,
            },
          ),
        ),
      ),
    );
  }

  ///修改群资料
  ///
  Future<V2TimCallback> setGroupInfo({
    // required String groupID,
    // String? groupType,
    // String? groupName,
    // String? notification,
    // String? introduction,
    // String? faceUrl,
    // bool? isAllMuted,
    // int? addOpt,
    // Map<String, String>? customInfo,
    required V2TimGroupInfo info,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupInfo",
          buildParam(
            {
              "groupID": info.groupID,
              "groupType": info.groupType,
              "groupName": info.groupName,
              "notification": info.notification,
              "introduction": info.introduction,
              "faceUrl": info.faceUrl,
              "isAllMuted": info.isAllMuted,
              "addOpt": info.groupAddOpt,
              "customInfo": info.customInfo
            },
          ),
        ),
      ),
    );
  }

  /// 这个接口移到messageManager下面去了，2020-6-4
  /// 修改群消息接收选项
  ///
  /// 参数
  ///
  /// ```
  /// opt	三种类型的消息接收选项： V2TIMGroupInfo.V2TIM_GROUP_RECEIVE_MESSAGE：在线正常接收消息，离线时会有厂商的离线推送通知 V2TIMGroupInfo.V2TIM_GROUP_NOT_RECEIVE_MESSAGE：不会接收到群消息 V2TIMGroupInfo.V2TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE：在线正常接收消息，离线不会有推送通知
  /// ```
  // Future<V2TimCallback> setReceiveMessageOpt({
  //   required String groupID,
  //   required int opt,
  // }) async {
  //   return V2TimCallback.fromJson(
  //     formatJson(
  //       await _channel.invokeMethod(
  //         "setReceiveMessageOpt",
  //         buildParam(
  //           {
  //             "groupID": groupID,
  //             "opt": opt,
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  /// 初始化群属性，会清空原有的群属性列表
  ///
  /// 注意
  ///
  /// attributes 的使用限制如下：
  ///
  /// ```
  /// 1、目前只支持 AVChatRoom
  /// 2、key 最多支持16个，长度限制为32字节
  /// 3、value 长度限制为4k
  /// 4、总的 attributes（包括 key 和 value）限制为16k
  /// 5、initGroupAttributes、setGroupAttributes、deleteGroupAttributes 接口合并计算， SDK 限制为5秒10次，超过后回调8511错误码；后台限制1秒5次，超过后返回10049错误码
  /// 6、getGroupAttributes 接口 SDK 限制5秒20次
  /// ```
  Future<V2TimCallback> initGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "initGroupAttributes",
          buildParam(
            {
              "groupID": groupID,
              "attributes": attributes,
            },
          ),
        ),
      ),
    );
  }

  ///设置群属性。已有该群属性则更新其 value 值，没有该群属性则添加该属性。
  ///
  Future<V2TimCallback> setGroupAttributes({
    required String groupID,
    required Map<String, String> attributes,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupAttributes",
          buildParam(
            {
              "groupID": groupID,
              "attributes": attributes,
            },
          ),
        ),
      ),
    );
  }

  ///删除指定群属性，keys 传 null 则清空所有群属性。
  ///
  Future<V2TimCallback> deleteGroupAttributes({
    required String groupID,
    required List<String> keys,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteGroupAttributes",
          buildParam(
            {
              "groupID": groupID,
              "keys": keys,
            },
          ),
        ),
      ),
    );
  }

  ///获取指定群属性，keys 传 null 则获取所有群属性。
  ///
  Future<V2TimValueCallback<Map<String, String>>> getGroupAttributes({
    required String groupID,
    List<String>? keys,
  }) async {
    return V2TimValueCallback<Map<String, String>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupAttributes",
          buildParam(
            {
              "groupID": groupID,
              "keys": keys,
            },
          ),
        ),
      ),
    );
  }

  ///获取指定群属性，keys 传 null 则获取所有群属性。
  ///
  Future<V2TimValueCallback<int>> getGroupOnlineMemberCount({
    required String groupID,
  }) async {
    return V2TimValueCallback<int>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupOnlineMemberCount",
          buildParam(
            {
              "groupID": groupID,
            },
          ),
        ),
      ),
    );
  }

  /// 获取群成员列表
  ///
  /// 参数
  ///
  /// ```
  /// filter	指定群成员类型
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ALL：所有类型
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_OWNER：群主
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_ADMIN：群管理员
  /// V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_FILTER_COMMON：普通群成员
  /// nextSeq	分页拉取标志，第一次拉取填0，回调成功如果 nextSeq 不为零，需要分页，传入再次拉取，直至为0。
  /// ```
  /// 注意
  ///
  /// ```
  /// 直播群（AVChatRoom）的特殊限制：
  /// 不支持管理员角色的拉取，群成员个数最大只支持 31 个（新进来的成员会排前面），程序重启后，请重新加入群组，否则拉取群成员会报 10007 错误码。
  /// 群成员资料信息仅支持 userID | nickName | faceURL | role 字段。
  /// role 字段不支持管理员角色，如果您的业务逻辑依赖于管理员角色，可以使用群自定义字段 groupAttributes 管理该角色。
  /// ```
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
    required String groupID,
    required int filter,
    required String nextSeq,
  }) async {
    return V2TimValueCallback<V2TimGroupMemberInfoResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMemberList",
          buildParam(
            {
              "groupID": groupID,
              "filter": filter,
              "nextSeq": nextSeq,
            },
          ),
        ),
      ),
    );
  }

  ///获取指定的群成员资料
  ///
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo({
    required String groupID,
    required List<String> memberList,
  }) async {
    return V2TimValueCallback<List<V2TimGroupMemberFullInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupMembersInfo",
          buildParam(
            {
              "groupID": groupID,
              "memberList": memberList,
            },
          ),
        ),
      ),
    );
  }

  ///修改指定的群成员资料
  ///
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupMemberInfo",
          buildParam(
            {
              "userID": userID,
              "groupID": groupID,
              "nameCard": nameCard,
              "customInfo": customInfo
            },
          ),
        ),
      ),
    );
  }

  ///禁言（只有管理员或群主能够调用）
  ///
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "muteGroupMember",
          buildParam(
            {
              "groupID": groupID,
              "userID": userID,
              "seconds": seconds,
            },
          ),
        ),
      ),
    );
  }

  /// 邀请他人入群
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：群里的任何人都可以邀请其他人进群。
  /// 会议群（Meeting）和公开群（Public）：只有通过rest api 使用 App 管理员身份才可以邀请其他人进群。
  /// 直播群（AVChatRoom）：不支持此功能。
  /// ```
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    return V2TimValueCallback<List<V2TimGroupMemberOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "inviteUserToGroup",
          buildParam(
            {
              "groupID": groupID,
              "userList": userList,
            },
          ),
        ),
      ),
    );
  }

  /// 踢人
  ///
  /// 注意
  ///
  /// ```
  /// 工作群（Work）：只有群主或 APP 管理员可以踢人。
  /// 公开群（Public）、会议群（Meeting）：群主、管理员和 APP 管理员可以踢人
  /// 直播群（AVChatRoom）：只支持禁言（muteGroupMember），不支持踢人。
  /// ```
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "kickGroupMember",
          buildParam(
            {
              "groupID": groupID,
              "memberList": memberList,
              "reason": reason,
            },
          ),
        ),
      ),
    );
  }

  /// 切换群成员的角色。
  ///
  /// 注意
  ///
  /// ```
  /// 公开群（Public）和会议群（Meeting）：只有群主才能对群成员进行普通成员和管理员之间的角色切换。
  /// 其他群不支持设置群成员角色。
  /// 转让群组请调用 transferGroupOwner 接口。
  /// ```
  ///
  /// 参数
  ///
  /// ```
  /// role	切换的角色支持： V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_MEMBER：普通群成员 V2TIMGroupMemberFullInfo.V2TIM_GROUP_MEMBER_ROLE_ADMIN：管理员
  /// ```
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required int role,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupMemberRole",
          buildParam(
            {
              "groupID": groupID,
              "userID": userID,
              "role": role,
            },
          ),
        ),
      ),
    );
  }

  /// 转让群主
  ///
  /// 注意
  ///
  /// ```
  /// 普通类型的群（Work、Public、Meeting）：只有群主才有权限进行群转让操作。
  /// 直播群（AVChatRoom）：不支持转让群主。
  /// ```
  Future<V2TimCallback> transferGroupOwner({
    required String groupID,
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "transferGroupOwner",
          buildParam(
            {
              "groupID": groupID,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  ///获取加群的申请列表
  ///
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    return V2TimValueCallback<V2TimGroupApplicationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getGroupApplicationList",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  ///同意某一条加群申请
  ///
  Future<V2TimCallback> acceptGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    int? addTime,
    int? type,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "acceptGroupApplication",
          buildParam(
            {
              "groupID": groupID,
              "reason": reason,
              "fromUser": fromUser,
              "toUser": toUser,
              "addTime": addTime,
              "type": type,
            },
          ),
        ),
      ),
    );
  }

  ///拒绝某一条加群申请
  ///
  Future<V2TimCallback> refuseGroupApplication({
    required String groupID,
    String? reason,
    required String fromUser,
    required String toUser,
    required int addTime,
    required int type,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "refuseGroupApplication",
          buildParam(
            {
              "groupID": groupID,
              "reason": reason,
              "fromUser": fromUser,
              "toUser": toUser,
              "addTime": addTime,
              "type": type,
            },
          ),
        ),
      ),
    );
  }

  ///标记申请列表为已读
  ///
  Future<V2TimCallback> setGroupApplicationRead() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setGroupApplicationRead",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  /// 搜索群资料
  ///
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    return V2TimValueCallback<List<V2TimGroupInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "searchGroups",
          buildParam(
            {
              "searchParam": searchParam.toJson(),
            },
          ),
        ),
      ),
    );
  }

  /// 搜索群成员
  /// TODO这里安卓和ios有差异化，ios能根据组名返回key:list但 安卓但key是""为空，我设为default
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam param,
  }) async {
    return V2TimValueCallback<V2GroupMemberInfoSearchResult>.fromJson(
      formatJson(await _channel.invokeMethod(
        "searchGroupMembers",
        buildParam(
          {
            "param": param.toJson(),
          },
        ),
      )),
    );
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "groupManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
