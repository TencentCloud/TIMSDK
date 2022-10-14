// ignore_for_file: file_names

import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class LoginUserInfo with ChangeNotifier {
  V2TimUserFullInfo _loginUserInfo = V2TimUserFullInfo();
  final CoreServicesImpl _coreServices = TIMUIKitCore.getInstance();
  V2TimUserFullInfo get loginUserInfo {
    return _loginUserInfo;
  }

  setLoginUserInfo(V2TimUserFullInfo info) {
    _loginUserInfo = info;
    if (_loginUserInfo.faceUrl == null || _loginUserInfo.faceUrl!.isEmpty) {
      setRandomAvatar();
    }
    notifyListeners();
  }

  final List<String> avatarURL = [
    "https://qcloudimg.tencent-cloud.cn/raw/3f574fd5dd7d3d253e23148f6dbb9d6c.png",
    "https://qcloudimg.tencent-cloud.cn/raw/9c6b6806f88ee33b3685f0435fe9a8b3.png",
    "https://qcloudimg.tencent-cloud.cn/raw/2c6e4177fcca03de1447a04d8ff76d9c.png",
    "https://qcloudimg.tencent-cloud.cn/raw/af98ae3d5c4094d2061612bea8fda4da.png",
    "https://qcloudimg.tencent-cloud.cn/raw/bd41d21551407655a01bba48894d33ad.png",
    "https://qcloudimg.tencent-cloud.cn/raw/f9b6638581718fefb101eaabf7f76a2e.png",
  ];

  setRandomAvatar() async {
    String avatar = avatarURL[Random().nextInt(6)];
    await _coreServices.setSelfInfo(
        userFullInfo: V2TimUserFullInfo.fromJson({
          "faceUrl": avatar,
        }));
    _loginUserInfo.faceUrl = avatar;
    notifyListeners();
  }
}
