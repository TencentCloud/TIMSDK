import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TUIContactViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  List<V2TimFriendInfo>? _friendList;

  V2TimFriendshipListener? _friendshipListener;

  List<V2TimFriendInfo>? get friendList {
    return _friendList;
  }

  loadData() async {
    final res = await _friendshipServices.getFriendList();
    _friendList = res;
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
