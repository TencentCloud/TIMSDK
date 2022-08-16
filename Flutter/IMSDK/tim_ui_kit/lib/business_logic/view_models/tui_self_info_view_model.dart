import 'package:flutter/cupertino.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
import 'package:tim_ui_kit/data_services/core/tim_uikit_config.dart';

class TUISelfInfoViewModel extends ChangeNotifier {
  V2TimUserFullInfo? _loginInfo;
  TIMUIKitConfig? _globalConfig;

  TIMUIKitConfig? get globalConfig => _globalConfig;

  set globalConfig(TIMUIKitConfig? value) {
    _globalConfig = value;
    notifyListeners();
  }

  V2TimUserFullInfo? get loginInfo {
    return _loginInfo;
  }

  setLoginInfo(V2TimUserFullInfo value) {
    _loginInfo = value;
    notifyListeners();
  }
}
