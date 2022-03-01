import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIGroupViewModel extends ChangeNotifier {
  List<V2TimGroupInfo> _groupList = [];
  final GroupServices _groupServices = serviceLocator<GroupServices>();

  List<V2TimGroupInfo> get groupList {
    return _groupList;
  }

  loadData() async {
    final groupListRes = await _groupServices.getJoinedGroupList();
    _groupList = groupListRes ?? [];
    if (_groupList.isNotEmpty) {
      notifyListeners();
    }
  }

  deleteGroup() async {}
}
