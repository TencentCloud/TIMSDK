import 'package:js/js_util.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_member_search_result.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/group_add_opt.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/im_sdk_plugin_js.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_delete_group_attributes.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_group_attributes.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_group_member_list.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_get_group_members_info.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_group_create.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_group_join.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_handle_group_application.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_invite_user_to_group.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_kick_group_member.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_mute_group_member.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_set_group_attributes.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_set_group_member_info.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_set_group_member_role.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_transfer_group_owner.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class V2TIMGroupManager {
  late TIM? timeweb;

  V2TIMGroupManager() {
    timeweb = V2TIMManagerWeb.timWeb;
  }

  Future<dynamic> createGroup(Map<String, dynamic> params) async {
    try {
      final formatedParams = V2TimGroupCreate.formateParams(params);
      final res =
          await wrappedPromiseToFuture(timeweb!.createGroup(formatedParams));
      final code = res.code;
      final data = jsToMap(res.data);
      if (code == 0) {
        return CommonUtils.returnSuccess<String>(
            jsToMap(data['group'])['groupID']);
      } else {
        return CommonUtils.returnErrorForValueCb<String>(
            'some errors when create group');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<String>(error.toString());
    }
  }

  Future<dynamic> getJoinedGroupList() async {
    try {
      final res = await wrappedPromiseToFuture(timeweb!.getGroupList());
      log(res);
      var code = res.code;
      var groupList = jsToMap(res.data)['groupList'] as List;
      if (code == 0) {
        final result = V2TimGroupCreate.formateGroupListResult(groupList);
        return CommonUtils.returnSuccess<List<V2TimGroupInfo>>(result);
      } else {
        return CommonUtils.returnErrorForValueCb<List<V2TimGroupInfo>>(
            "getJoinedList Failed");
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimGroupInfo>>(
          error.toString());
    }
  }

  Future<dynamic> joinGroup(Map<String, dynamic> params) async {
    try {
      final formatedParams = V2TimGroupJoin.formatParams(params);
      final res =
          await wrappedPromiseToFuture(timeweb!.joinGroup(formatedParams));
      final code = res.code;
      final data = jsToMap(res.data);
      final result = data['status'] ?? data['groupID'];
      if (code == 0) {
        return CommonUtils.returnSuccessWithDesc(result);
      } else {
        return CommonUtils.returnSuccess("join group failed");
      }
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<Object> getGroupProfile(String groupID) async {
    final res = await wrappedPromiseToFuture(
        timeweb!.getGroupProfile(mapToJSObj({"groupID": groupID})));
    final code = res.code;
    if (code == 0) {
      return jsToMap(res.data)['group'];
    }
    return {};
  }

  Future<dynamic> getGroupsInfo(Map<String, dynamic> params) async {
    try {
      final groupIDs = params['groupIDList'];
      final groupsInfoList = List.empty(growable: true);
      for (String id in groupIDs) {
        final res = await getGroupProfile(id);
        groupsInfoList.add(res);
      }
      final res = groupsInfoList.map((element) {
        final groupInfo =
            V2TimGroupCreate.convertGroupResultFromWebToDart(jsToMap(element));
        return {'resultCode': 0, 'resultMessage': 'OK', 'groupInfo': groupInfo};
      });
      return CommonUtils.returnSuccess<List<V2TimGroupInfoResult>>(
          res.toList());
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimGroupInfoResult>>(
          error.toString());
    }
  }

  Future<dynamic> setGroupInfo(Map<String, dynamic> params) async {
    try {
      final updateGroupParams = {
        "groupID": params['groupID'],
        "name": params['groupName'] ?? '',
        "avatar": params['faceUrl'] ?? '',
        "introduction": params['introduction'] ?? '',
        "notification": params['notification'] ?? '',
        "joinOption": GroupAddOptWeb.convertGroupAddOptToWeb(params['addOpt']),
        "groupCustomField":
            V2TimGroupCreate.convertGroupCustomInfoFromDartToWeb(
                params['customInfo'])
      };
      if (params['groupName'] == '') {
        updateGroupParams.remove("name");
      }
      final res = await wrappedPromiseToFuture(
          timeweb!.updateGroupProfile(mapToJSObj(updateGroupParams)));
      if (res.code == 0) {
        final groupInfo = V2TimGroupCreate.convertGroupResultFromWebToDart(
            jsToMap(jsToMap(res.data)['group']));
        return CommonUtils.returnSuccessForCb(groupInfo);
      } else {
        return CommonUtils.returnError('set group info failed');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> getGroupOnlineMemberCount(Map<String, dynamic> params) async {
    try {
      final groupID = params['groupID'];
      final res = await wrappedPromiseToFuture(
          timeweb!.getGroupOnlineMemberCount(groupID));
      if (res.code == 0) {
        return CommonUtils.returnSuccess<int>(jsToMap(res.data)['memberCount']);
      } else {
        return CommonUtils.returnErrorForValueCb<int>(
            'get online member count failed!');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<int>(error);
    }
  }

  Future<dynamic> getGroupMemberList(Map<String, dynamic> params) async {
    try {
      final getGroupMemberParams = GetGroupMemberList.formateParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.getGroupMemberList(getGroupMemberParams));
      final code = res.code;
      if (code == 0) {
        final memberList = jsToMap(res.data)['memberList'];
        final memberListResult =
            GetGroupMemberList.formateGroupResult(memberList);
        return CommonUtils.returnSuccess<V2TimGroupMemberInfoResult>(
            {"nextSeq": '0', "memberInfoList": memberListResult});
      } else {
        return CommonUtils.returnErrorForValueCb<V2TimGroupMemberInfoResult>(
            'get group member list failed');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<V2TimGroupMemberInfoResult>(
          error);
    }
  }

  Future<dynamic> getGroupMembersInfo(Map<String, dynamic> params) async {
    try {
      final getMembersInfoParams = GetGroupMembersInfo.formatParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.getGroupMemberProfile(getMembersInfoParams));
      if (res.code == 0) {
        final memberList = jsToMap(res.data)['memberList'];
        final memberListResult =
            GetGroupMemberList.formateGroupResult(memberList);
        return CommonUtils.returnSuccess<List<V2TimGroupMemberFullInfo>>(
            memberListResult);
      } else {
        return CommonUtils.returnErrorForValueCb<
            List<V2TimGroupMemberFullInfo>>('get group members info failed');
      }
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<List<V2TimGroupMemberFullInfo>>(
          error);
    }
  }

  Future<JSResult> setNameCard(Object nameCardSettingParams) {
    return wrappedPromiseToFuture(
        timeweb!.setGroupMemberNameCard(nameCardSettingParams));
  }

  Future<JSResult> setCustomInfo(Object customInfoParams) async {
    return wrappedPromiseToFuture(
        timeweb!.setGroupMemberCustomField(customInfoParams));
  }

  Future<dynamic> setGroupMemberInfo(Map<String, dynamic> params) async {
    try {
      final setParams = SetGroupMemberInfo.formateParams(params);
      final customInfo = params['customInfo'];
      final nameCard = params['nameCard'];
      final nameCardParams = setParams['nameCardParams'];
      final customInfoParams = setParams['customInfoParams'];
      final haveBothValue =
          nameCard != null && customInfo != null && customInfo.keys.length > 0;

      if (haveBothValue) {
        final responses = await Future.wait(
            [setNameCard(nameCardParams!), setCustomInfo(customInfoParams!)]);
        if (responses[0].code == 0 && responses[1].code == 0) {
          return CommonUtils.returnSuccessWithDesc('set success');
        }
      }

      if (nameCard != null) {
        final responses = await setNameCard(nameCardParams!);
        if (responses.code == 0) {
          return CommonUtils.returnSuccessWithDesc('set success');
        }
      }

      if (customInfo != null && customInfo.keys.length > 0) {
        final responses = await setCustomInfo(customInfoParams!);
        if (responses.code == 0) {
          return CommonUtils.returnSuccessWithDesc('set success');
        }
      }

      return CommonUtils.returnSuccessWithDesc('set failed');
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> muteGroupMember(Map<String, dynamic> params) async {
    final muteParams = MuteGroupMember.formatParams(params);
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.setGroupMemberMuteTime(muteParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessWithDesc('mute group member success');
      }
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> inviteUserToGroup(Map<String, dynamic> params) async {
    try {
      final addGroupMemberParams = InviteUserToGroup.formatParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.addGroupMember(addGroupMemberParams));
      if (res.code == 0) {
        final result = InviteUserToGroup.formatResult(jsToMap(res.data));
        return CommonUtils.returnSuccess<List<V2TimGroupMemberOperationResult>>(
            result);
      }
      return CommonUtils.returnErrorForValueCb<
          List<V2TimGroupMemberOperationResult>>('invite failed');
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<
          List<V2TimGroupMemberOperationResult>>(error);
    }
  }

  Future<dynamic> kickGroupMember(Map<String, dynamic> params) async {
    try {
      final kickGroupMemberParams = KickGroupMember.formatParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.deleteGroupMember(kickGroupMemberParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessWithDesc('ok');
      }

      return CommonUtils.returnError('kick group member failed');
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> setGroupMemberRole(Map<String, dynamic> params) async {
    try {
      final setGroupMemberRoleParams = SetGroupMemberRole.formatParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.setGroupMemberRole(setGroupMemberRoleParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessWithDesc('ok');
      }
      return CommonUtils.returnError('set group member role failed');
    } catch (error) {
      return CommonUtils.returnError(error);
    }
  }

  Future<dynamic> transferGroupOwner(Map<String, dynamic> params) async {
    try {
      final changeGroupOwnerParams = TransferGroupOwner.formatParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.changeGroupOwner(changeGroupOwnerParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessWithDesc('ok');
      }
      return CommonUtils.returnError('transfer group member failed');
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<dynamic> setGroupAttributes(Map<String, dynamic> params) async {
    try {
      final setGroupAttributesParams = SetGroupAttributes.foramteParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.setGroupAttributes(setGroupAttributesParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb('ok');
      }
      return CommonUtils.returnError('transfer group member failed');
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<dynamic> deleteGroupAttributes(Map<String, dynamic> params) async {
    try {
      final deleteGroupAttributesParams =
          DeleteGroupAttributes.formateParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.deleteGroupAttributes(deleteGroupAttributesParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccessForCb('ok');
      }
      return CommonUtils.returnError('transfer group member failed');
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<dynamic> getGroupAttributes(Map<String, dynamic> params) async {
    try {
      final getroupAttributesParams = GetGroupAttributes.formateParams(params);
      final res = await wrappedPromiseToFuture(
          timeweb!.getGroupAttributes(getroupAttributesParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccess<Map<String, String>>(
            jsToMap(jsToMap(res.data)['groupAttributes']));
      }

      return CommonUtils.returnErrorForValueCb<Map<String, String>>(
          'transfer group member failed');
    } catch (error) {
      return CommonUtils.returnErrorForValueCb<Map<String, String>>(
          error.toString());
    }
  }

  Future<dynamic> acceptGroupApplication(Map<String, dynamic> params) async {
    try {
      final handleApplicationParams =
          HandleGroupApplication.formateParams(params, 'Agree');
      final res = await wrappedPromiseToFuture(
          timeweb!.handleGroupApplication(handleApplicationParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccess(jsToMap(jsToMap(res.data)['group']));
      }

      return CommonUtils.returnError('Accept group application error');
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<dynamic> refuseGroupApplication(Map<String, dynamic> params) async {
    try {
      final handleApplicationParams =
          HandleGroupApplication.formateParams(params, 'Reject');
      final res = await wrappedPromiseToFuture(
          timeweb!.handleGroupApplication(handleApplicationParams));
      if (res.code == 0) {
        return CommonUtils.returnSuccess(jsToMap(jsToMap(res.data)['group']));
      }

      return CommonUtils.returnError('Reject group application error');
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  Future<dynamic> searchGroupByID(Map<String, dynamic> params) async {
    try {
      final res = await wrappedPromiseToFuture(
          timeweb!.searchGroupByID(params['groupID']));
      if (res.code == 0) {
        final groupInFo = V2TimGroupCreate.convertGroupResultFromWebToDart(
            jsToMap(res.data)['group']);
        return CommonUtils.returnSuccess(groupInFo);
      }

      return CommonUtils.returnError('search group error');
    } catch (error) {
      return CommonUtils.returnError(error.toString());
    }
  }

  V2TimValueCallback<List<V2TimGroupInfo>> searchGroups() {
    return CommonUtils.returnErrorForValueCb<List<V2TimGroupInfo>>(
        "searchGroups feature does not exist on the web");
  }

  V2TimValueCallback<V2TimGroupInfo> searchGroupsByID() {
    return CommonUtils.returnErrorForValueCb<V2TimGroupInfo>(
        "searchGroups feature does not exist on the web");
  }

  V2TimValueCallback<V2GroupMemberInfoSearchResult> searchGroupMembers() {
    return CommonUtils.returnErrorForValueCb<V2GroupMemberInfoSearchResult>(
        "searchGroupMembers feature does not exist on the web");
  }

  V2TimCallback setGroupApplicationRead() {
    return CommonUtils.returnError(
        "setGroupApplicationRead feature does not exist on the web");
  }

  V2TimCallback initGroupAttributes() {
    return CommonUtils.returnError(
        "initGroupAttributes feature does not exist on the web");
  }

  V2TimValueCallback<V2TimGroupApplicationResult> getGroupApplicationList() {
    return CommonUtils.returnErrorForValueCb<V2TimGroupApplicationResult>(
        "getGroupApplicationList feature does not exist on the web");
  }
}
