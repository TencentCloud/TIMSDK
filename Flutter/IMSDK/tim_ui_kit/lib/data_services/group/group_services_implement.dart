import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/ui/utils/optimize_utils.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

class GroupServicesImpl extends GroupServices {
  static List<Function?> groupInfoCallBackList = [];
  final CoreServicesImpl _coreService = serviceLocator<CoreServicesImpl>();
  final throttleGetGroupInfo = OptimizeUtils.throttle((val) async {
    String groupID = val["groupID"];
    List<String> memberList = val["memberList"];
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupMembersInfo(groupID: groupID, memberList: memberList);
    emitGroupCbList(res.data ?? []);
    clearGroupCbList();
  }, 1000);

  static emitGroupCbList(List<V2TimGroupMemberFullInfo?> list) {
    for (var cb in groupInfoCallBackList) {
      cb!(list);
    }
  }

  static clearGroupCbList() {
    groupInfoCallBackList = [];
  }

  @override
  Future<List<V2TimGroupInfo>?> getJoinedGroupList() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getJoinedGroupList();
    if (res.code == 0) {
      return res.data;
    } else {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: res.desc,
          errorCode: res.code));
      return null;
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
    } else {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: res.desc,
          errorCode: res.code));
      return null;
    }
  }

  @override
  void getGroupMembersInfoThrottle(
      {required String groupID,
      required List<String> memberList,
      Function? callBack}) async {
    if (callBack != null) {
      groupInfoCallBackList.add(callBack);
      throttleGetGroupInfo({"groupID": groupID, "memberList": memberList});
    }
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberFullInfo>>>
      getGroupMembersInfo(
          {required String groupID, required List<String> memberList}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupMembersInfo(groupID: groupID, memberList: memberList);
    if (res.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: res.desc,
          errorCode: res.code));
    }
    return res;
  }

  @override
  Future<V2TimValueCallback<V2TimGroupMemberInfoResult>> getGroupMemberList({
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
    if (res.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: res.desc,
          errorCode: res.code));
    }
    return res;
  }

  @override
  Future<V2TimCallback> setGroupInfo({
    required V2TimGroupInfo info,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupInfo(info: info);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> setGroupMemberRole({
    required String groupID,
    required String userID,
    required GroupMemberRoleTypeEnum role,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberRole(groupID: groupID, userID: userID, role: role);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> muteGroupMember({
    required String groupID,
    required String userID,
    required int seconds,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .muteGroupMember(groupID: groupID, userID: userID, seconds: seconds);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> setGroupMemberInfo({
    required String groupID,
    required String userID,
    String? nameCard,
    Map<String, String>? customInfo,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberInfo(
            groupID: groupID,
            userID: userID,
            nameCard: nameCard,
            customInfo: customInfo);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> kickGroupMember({
    required String groupID,
    required List<String> memberList,
    String? reason,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .kickGroupMember(
            groupID: groupID, memberList: memberList, reason: reason);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupMemberOperationResult>>>
      inviteUserToGroup({
    required String groupID,
    required List<String> userList,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .inviteUserToGroup(groupID: groupID, userList: userList);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimValueCallback<List<V2TimGroupInfo>>> searchGroups({
    required V2TimGroupSearchParam searchParam,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .searchGroups(searchParam: searchParam);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .joinGroup(groupID: groupID, message: message);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimValueCallback<V2GroupMemberInfoSearchResult>> searchGroupMembers({
    required V2TimGroupMemberSearchParam searchParam,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .searchGroupMembers(param: searchParam);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<void> addGroupListener({
    required V2TimGroupListener listener,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .addGroupListener(listener: listener);
    return result;
  }

  @override
  Future<void> removeGroupListener({
    V2TimGroupListener? listener,
  }) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .removeGroupListener(listener: listener);
    return result;
  }

  @override
  Future<V2TimValueCallback<V2TimGroupApplicationResult>>
      getGroupApplicationList() async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .getGroupApplicationList();
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> acceptGroupApplication(
      {required String groupID,
      required String fromUser,
      required String toUser,
      required int type,
      required int addTime,
      String? reason}) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .acceptGroupApplication(
          groupID: groupID,
          fromUser: fromUser,
          toUser: toUser,
          addTime: addTime,
          type: GroupApplicationTypeEnum.values[type],
          reason: reason ?? "",
        );
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }

  @override
  Future<V2TimCallback> refuseGroupApplication(
      {String? reason,
      required int addTime,
      required String groupID,
      required String fromUser,
      required String toUser,
      required GroupApplicationTypeEnum type}) async {
    final result = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .refuseGroupApplication(
            groupID: groupID,
            fromUser: fromUser,
            toUser: toUser,
            type: type,
            addTime: addTime,
            reason: reason);
    if (result.code != 0) {
      _coreService.callOnCallback(TIMCallback(
          type: TIMCallbackType.API_ERROR,
          errorMsg: result.desc,
          errorCode: result.code));
    }
    return result;
  }
}
