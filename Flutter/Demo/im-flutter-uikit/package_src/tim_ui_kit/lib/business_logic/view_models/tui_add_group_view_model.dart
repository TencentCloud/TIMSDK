import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/group/group_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIAddGroupViewModel extends ChangeNotifier {
  final GroupServices _groupServices = serviceLocator<GroupServices>();
  List<V2TimGroupInfo>? groupResult = [];
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();

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

  Future<V2TimCallback> addGroup(String groupID, String message) async {
    return _groupServices.joinGroup(groupID: groupID, message: message);
  }
}
