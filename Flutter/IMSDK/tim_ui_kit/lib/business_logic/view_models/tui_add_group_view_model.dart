import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/add_group_life_cycle.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIAddGroupViewModel extends ChangeNotifier {
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  List<V2TimGroupInfo>? groupResult = [];
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();
  AddGroupLifeCycle? _lifeCycle;

  set lifeCycle(AddGroupLifeCycle? value) {
    _lifeCycle = value;
  }

  V2TimUserFullInfo? loginUserInfo;

  TUIAddGroupViewModel() {
    loginUserInfo = _coreServicesImpl.loginUserInfo;
  }

  searchGroup(String params) async {
    final res = await _groupServices.getGroupsInfo(groupIDList: [params]);
    if (res != null) {
      groupResult =
          res.where((e) => e.resultCode == 0).map((e) => e.groupInfo!).toList();
    } else {
      groupResult = [];
    }
    notifyListeners();
  }

  Future<V2TimCallback?> addGroup(String groupID, String message) async {
    if (_lifeCycle?.shouldAddGroup != null &&
        await _lifeCycle!.shouldAddGroup(groupID, message) == false) {
      return null;
    }
    return _groupServices.joinGroup(groupID: groupID, message: message);
  }
}
