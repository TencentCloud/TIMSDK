import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';

class FriendApplicationModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<V2TimFriendApplication> _friendApplicationList =
      List.empty(growable: true);
  get friendApplicationList => _friendApplicationList;
  setFriendApplicationResult(newInfo) {
    _friendApplicationList = newInfo;
    notifyListeners();
    return _friendApplicationList;
  }

  clear() {
    _friendApplicationList = List.empty(growable: true);
    notifyListeners();
    return _friendApplicationList;
  }

  removeApplicationByuserId(String userId) {
    int? index;
    for (int i = 0; i < _friendApplicationList.length; i++) {
      if (_friendApplicationList[i].userID == userId) {
        index = i;
        break;
      }
    }
    if (index != null) {
      _friendApplicationList.removeAt(index);
    }
    notifyListeners();
    return _friendApplicationList;
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('friendApplicationList', friendApplicationList));
  }
}
