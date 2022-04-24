// ignore_for_file: file_names

import 'package:flutter/widgets.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class LoginUserInfo with ChangeNotifier {
  V2TimUserFullInfo _loginUserInfo = V2TimUserFullInfo();
  V2TimUserFullInfo get loginUserInfo {
    return _loginUserInfo;
  }

  setLoginUserInfo(V2TimUserFullInfo info) {
    _loginUserInfo = info;
    notifyListeners();
  }
}
