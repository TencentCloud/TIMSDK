import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';

class TUISelfInfoViewModel extends ChangeNotifier {
  V2TimUserFullInfo? _loginInfo;

  V2TimUserFullInfo? get loginInfo {
    return _loginInfo;
  }

  setLoginInfo(V2TimUserFullInfo value) {
    _loginInfo = value;
    notifyListeners();
  }
}
