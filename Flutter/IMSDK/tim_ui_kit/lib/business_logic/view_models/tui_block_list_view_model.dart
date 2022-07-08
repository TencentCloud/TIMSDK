import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/block_list_life_cycle.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TUIBlockListViewModel extends ChangeNotifier {
  List<V2TimFriendInfo> _blackList = [];
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  late BlockListLifeCycle? _lifeCycle;

  set lifeCycle(BlockListLifeCycle? value) {
    _lifeCycle = value;
  }

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
    if (_lifeCycle?.shouldDeleteFromBlockList != null &&
        await _lifeCycle!.shouldDeleteFromBlockList(userIDList) == false) {
      return null;
    }
    final res =
        await _friendshipServices.deleteFromBlackList(userIDList: userIDList);
    if (res != null) {
      return res;
    }
    return null;
  }
}
