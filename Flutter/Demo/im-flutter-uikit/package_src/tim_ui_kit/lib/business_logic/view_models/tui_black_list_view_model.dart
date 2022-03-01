import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TUIBlackListViewModel extends ChangeNotifier {
  List<V2TimFriendInfo> _blackList = [];
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();

  List<V2TimFriendInfo> get blackList {
    return _blackList;
  }

  loadData() async {
    final blackListRes = await _friendshipServices.getBlackList();
    _blackList = blackListRes ?? [];
    notifyListeners();
  }

  Future<List<V2TimFriendOperationResult>?> deleteFromBlackList(
      List<String> userIDList) async {
    final res =
        await _friendshipServices.deleteFromBlackList(userIDList: userIDList);
    if (res != null) {
      return res;
    }
  }
}
