import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIPersonalProfileViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();

  V2TimFriendInfo? _userInfo;

  V2TimFriendInfo? get userInfo {
    return _userInfo;
  }

  loadData({required String userID}) async {
    V2TimFriendInfo? friendUserInfo;
    final userInfoList =
        await _friendshipServices.getFriendsInfo(userIDList: [userID]);

    if (userInfoList != null) {
      friendUserInfo = userInfoList[0].friendInfo;
    }
    _userInfo = friendUserInfo;

    notifyListeners();
  }

  changeFriendVerificationMethod(int allowType) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        {"allowType": allowType},
      ),
    );

    if (res.code == 0) {
      _userInfo?.userProfile!.allowType = allowType;
      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
  }

  // 1：男 女：2
  updateGender(int gender) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        {"gender": gender},
      ),
    );
    if (res.code == 0) {
      _userInfo?.userProfile!.gender = gender;
      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
  }

  updateNickName(String nickName) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        {"nickName": nickName},
      ),
    );

    if (res.code == 0) {
      _userInfo?.userProfile!.nickName = nickName;
      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
  }

  updateSelfSignature(String selfSignature) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        {"selfSignature": selfSignature},
      ),
    );
    if (res.code == 0) {
      _userInfo?.userProfile!.selfSignature = selfSignature;
      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
  }
}
