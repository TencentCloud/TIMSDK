// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_chat_view_model.dart';
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
  final TUIChatViewModel chatViewModel = serviceLocator<TUIChatViewModel>();

  NeedUpdate? get needUpdate => _needUpdate;

  set needUpdate(NeedUpdate? value) {
    _needUpdate = value;
  }

  TUIGroupListenerModel() {
    _groupListener = V2TimGroupListener(onMemberInvited:
        (groupID, opUser, memberList) {
      needUpdate = NeedUpdate(groupID, UpdateType.memberList);
      notifyListeners();
    }, onMemberKicked: (groupID, opUser, memberList) {
      needUpdate = NeedUpdate(groupID, UpdateType.memberList);
      notifyListeners();
    }, onMemberEnter: (String groupID, List<V2TimGroupMemberInfo> memberList) {
      needUpdate = NeedUpdate(groupID, UpdateType.memberList);
      notifyListeners();
    }, onMemberLeave: (String groupID, V2TimGroupMemberInfo member) {
      needUpdate = NeedUpdate(groupID, UpdateType.memberList);
      notifyListeners();
    }, onGroupInfoChanged: (groupID, changeInfos) {
      needUpdate = NeedUpdate(groupID, UpdateType.groupInfo);
      notifyListeners();
    }, onReceiveJoinApplication:
        (String groupID, V2TimGroupMemberInfo member, String opReason) async {
      _onReceiveJoinApplication(groupID, member, opReason);
      needUpdate = NeedUpdate(groupID, UpdateType.joinApplicationList);
      notifyListeners();
    },);
    setGroupListener();
  }

  setGroupListener() {
    _groupServices.addGroupListener(listener: _groupListener!);
  }

  _onReceiveJoinApplication(
      String groupID, V2TimGroupMemberInfo member, String opReason) {
    Future.delayed(const Duration(milliseconds: 500),
        () => chatViewModel.refreshGroupApplicationList());
  }
}
