import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';

class GroupApplicationModel with ChangeNotifier, DiagnosticableTreeMixin {
  List<V2TimGroupApplication> _groupApplicationList =
      List.empty(growable: true);
  get groupApplicationList => _groupApplicationList;
  setGroupApplicationResult(newInfo) {
    _groupApplicationList = newInfo;
    notifyListeners();
    return _groupApplicationList;
  }

  clear() {
    _groupApplicationList = List.empty(growable: true);
    notifyListeners();
    return _groupApplicationList;
  }

  removeApplicationByuserId(String groupID) {
    int? index;
    for (int i = 0; i < _groupApplicationList.length; i++) {
      if (_groupApplicationList[i].groupID == groupID) {
        index = i;
        break;
      }
    }
    if (index != null) {
      _groupApplicationList.removeAt(index);
    }
    notifyListeners();
    return _groupApplicationList;
  }

  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(IntProperty('groupApplicationList', groupApplicationList));
  }
}
