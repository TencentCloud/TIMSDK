import 'package:tencent_im_sdk_plugin/enum/group_member_filter_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';

class GroupServicesImpl extends GroupServices {
  @override
  Future<List<V2TimGroupInfo>?> getJoinedGroupList() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    if (res.code == 0) {
      return res.data;
    }
  }

  @override
  Future<List<V2TimGroupInfoResult>?> getGroupsInfo({
    required List<String> groupIDList,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupsInfo(groupIDList: groupIDList);
    if (res.code == 0) {
      return res.data;
    }
  }

  @override
  Future<V2TimGroupMemberInfoResult?> getGroupMemberList({
    required String groupID,
    required GroupMemberFilterTypeEnum filter,
    required String nextSeq,
    int count = 15,
    int offset = 0,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupMemberList(
            groupID: groupID,
            filter: filter,
            nextSeq: nextSeq,
            count: count,
            offset: offset);
    if (res.code == 0) {
      return res.data;
    }
  }

  @override
  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupInfo(info: info);
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required GroupMemberRoleTypeEnum role,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberRole(groupID: groupID, userID: userID, role: role);
  }

  @override
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .muteGroupMember(groupID: groupID, userID: userID, seconds: seconds);
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    return TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupMemberInfo(
        groupID: groupID,
        userID: userID,
        nameCard: nameCard,
        customInfo: customInfo);
  }

  @override
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) {
    return TencentImSDKPlugin.v2TIMManager.getGroupManager().kickGroupMember(
        groupID: groupID, memberList: memberList, reason: reason);
  }
}
