import 'package:flutter/foundation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class UserModel with ChangeNotifier, DiagnosticableTreeMixin {
  V2TimUserFullInfo? _info;
  V2TimUserFullInfo? get info => _info;
  setInfo(newInfo) {
    _info = newInfo;
    notifyListeners();
    return _info;
  }

  clear() {
    _info = null;
    notifyListeners();
  }
}
