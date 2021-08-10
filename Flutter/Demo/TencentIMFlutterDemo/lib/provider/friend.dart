import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';

class FriendListModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<V2TimFriendInfo?> _friendList = List.empty(growable: true);
  get friendList => _friendList;
  List<V2TimFriendInfo?> setFriendList(List<V2TimFriendInfo?>? newLst) {
    _friendList = (newLst != null ? newLst : List.empty());
    notifyListeners();
    return _friendList;
  }

  clear() {
    _friendList = List.empty(growable: true);
    notifyListeners();
    return _friendList;
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('friendList', friendList));
  }
}
