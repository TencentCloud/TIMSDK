// ignore_for_file: unnecessary_getters_setters

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_global_model.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

enum UpdateType { groupInfo, memberList, joinApplicationList }

class NeedUpdate {
  final String groupID;
  final UpdateType updateType;

  NeedUpdate(this.groupID, this.updateType);
}

class TUIGroupListenerModel extends ChangeNotifier {
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  V2TimGroupListener? _groupListener;
  NeedUpdate? _needUpdate;
  final TUIChatGlobalModel chatViewModel = serviceLocator<TUIChatGlobalModel>();

  NeedUpdate? get needUpdate => _needUpdate;

  set needUpdate(NeedUpdate? value) {
    Future.delayed(const Duration(seconds: 0), () {
      _needUpdate = value;
    });
  }

  TUIGroupListenerModel() {
    _groupListener = V2TimGroupListener(
      onMemberInvited: (groupID, opUser, memberList) {
        _needUpdate = NeedUpdate(groupID, UpdateType.memberList);
        notifyListeners();
      },
      onMemberKicked: (groupID, opUser, memberList) {
        _needUpdate = NeedUpdate(groupID, UpdateType.memberList);
        notifyListeners();
      },
      onMemberEnter: (String groupID, List<V2TimGroupMemberInfo> memberList) {
        _needUpdate = NeedUpdate(groupID, UpdateType.memberList);
        notifyListeners();
      },
      onMemberLeave: (String groupID, V2TimGroupMemberInfo member) {
        _needUpdate = NeedUpdate(groupID, UpdateType.memberList);
        notifyListeners();
      },
      onGroupInfoChanged: (groupID, changeInfos) {
        _needUpdate = NeedUpdate(groupID, UpdateType.groupInfo);
        notifyListeners();
      },
      onReceiveJoinApplication:
          (String groupID, V2TimGroupMemberInfo member, String opReason) async {
        _onReceiveJoinApplication(groupID, member, opReason);
        chatViewModel.refreshGroupApplicationList();
        notifyListeners();
      },
    );
  }

  setGroupListener() {
    _groupServices.addGroupListener(listener: _groupListener!);
  }

  removeGroupListener() {
    _groupServices.removeGroupListener(listener: _groupListener!);
  }

  getCommunityCategoryList(String groupID) async {
    final Map<String, String>? customInfo =
        await getCommunityCustomInfo(groupID);
    if (customInfo != null) {
      final String? categoryListString = customInfo["categoryList"];
      if (categoryListString != null && categoryListString.isNotEmpty) {
        return jsonDecode(categoryListString);
      }
    }
  }

  Future<Map<String, String>?> getCommunityCustomInfo(String groupID) async {
    V2TimValueCallback<List<V2TimGroupInfoResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupsInfo(groupIDList: [groupID]);
    if (res.code != 0) {
      final V2TimGroupInfoResult? groupInfo = res.data?[0];
      if (groupInfo != null) {
        Map<String, String>? customInfo = groupInfo.groupInfo?.customInfo;
        return customInfo;
      }
    }
    return null;
  }

  setCommunityCategoryList(
      String groupID, String groupType, List<String> newCategoryList) async {
    final Map<String, String>? customInfo =
        await getCommunityCustomInfo(groupID);
    customInfo?["categoryList"] = jsonEncode(newCategoryList);
    TencentImSDKPlugin.v2TIMManager.getGroupManager().setGroupInfo(
            info: V2TimGroupInfo(
          customInfo: customInfo,
          groupID: groupID,
          groupType: groupType,
          // ...其他资料
        ));
  }

  addCategoryForTopic(String groupID, String categoryName) {
    TencentImSDKPlugin.v2TIMManager.getGroupManager().setTopicInfo(
          topicInfo: V2TimTopicInfo(customString: categoryName),
          groupID: groupID, // 话题所在的群组id
        );
  }

  _onReceiveJoinApplication(
      String groupID, V2TimGroupMemberInfo member, String opReason) {
    Future.delayed(const Duration(milliseconds: 500),
        () => chatViewModel.refreshGroupApplicationList());
  }
}
