import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIAddFriendViewModel extends ChangeNotifier {
  final CoreServicesImpl _coreServicesImpl = serviceLocator<CoreServicesImpl>();
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  V2TimUserFullInfo? loginUserInfo;
  List<V2TimUserFullInfo>? _friendInfoResult;
  List<V2TimUserFullInfo>? get friendInfoResult {
    return _friendInfoResult;
  }

  TUIAddFriendViewModel() {
    loginUserInfo = _coreServicesImpl.loginUserInfo;
  }

  searchFriend(String params) async {
    final response = await _coreServicesImpl.getUsersInfo(userIDList: [params]);
    if (response.code == 0) {
      _friendInfoResult = response.data;
    } else {
      _friendInfoResult = null;
    }
    notifyListeners();
  }

  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend(
      String userID, String? remark, String? friendGroup, String? addWording) {
    final res = _friendshipServices.addFriend(
        userID: userID,
        addType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH,
        remark: remark,
        addWording: addWording,
        friendGroup: friendGroup);
    return res;
  }
}
