import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';

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
