import 'package:flutter/material.dart';
import 'package:tim_ui_kit/business_logic/life_cycle/friend_list_life_cycle.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TUIContactViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  List<V2TimFriendInfo>? _friendList;
  FriendListLifeCycle? _lifeCycle;

  set lifeCycle(FriendListLifeCycle? value) {
    _lifeCycle = value;
  }

  V2TimFriendshipListener? _friendshipListener;

  List<V2TimFriendInfo>? get friendList {
    return _friendList;
  }

  loadData() async {
    final List<V2TimFriendInfo> res =
        await _friendshipServices.getFriendList() ?? [];
    final memberList = await _lifeCycle?.friendListWillMount(res) ?? res;
    _friendList = memberList;
    notifyListeners();
  }

  setFriendshipListener({V2TimFriendshipListener? listener}) {
    final friendListener = V2TimFriendshipListener(
      // onBlackListAdd: (infoList) {
      //   listener?.onBlackListAdd(infoList);
      //   loadData();
      // },
      // onBlackListDeleted: (userList) {
      //   listener?.onBlackListDeleted(userList);
      //   loadData();
      // },
      onFriendInfoChanged: (infoList) {
        listener?.onFriendInfoChanged(infoList);
        loadData();
      },
      onFriendListAdded: (users) {
        listener?.onFriendListAdded(users);
        loadData();
      },
      onFriendListDeleted: (userList) {
        listener?.onFriendListDeleted(userList);
        loadData();
      },
    );

    _friendshipListener = friendListener;
    if (_friendshipListener != null) {
      _friendshipServices.setFriendshipListener(listener: _friendshipListener!);
    }
  }

  removeFriendShipListener() {
    _friendshipServices.removeFriendListener(listener: _friendshipListener);
  }
}
