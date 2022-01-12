import 'package:discuss/utils/toast.dart';
import 'package:flutter/foundation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class UserInfos with ChangeNotifier {
  final Map<String, V2TimUserFullInfo> _userInfos = {};

  void setUserInfo(String userID, V2TimUserFullInfo userInfo) {
    _userInfos[userID] = userInfo;
    notifyListeners();
  }

  Future<V2TimUserFullInfo?> getUserInfo(String userID) async {
    if (_userInfos[userID] == null) {
      V2TimValueCallback<List<V2TimUserFullInfo>> res = await TencentImSDKPlugin
          .v2TIMManager
          .getUsersInfo(userIDList: [userID]);
      if (res.code == 0) {
        V2TimUserFullInfo info = res.data![0];
        _userInfos[userID] = info;
        return info;
      } else {
        Utils.log("接口也没获取到信息");
        return null;
      }
    } else {
      return _userInfos[userID]!;
    }
  }
}
