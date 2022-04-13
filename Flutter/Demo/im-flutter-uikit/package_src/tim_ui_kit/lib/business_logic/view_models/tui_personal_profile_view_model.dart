import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tim_ui_kit/business_logic/view_models/tui_self_info_view_model.dart';
import 'package:tim_ui_kit/data_services/core/core_services_implements.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUIPersonalProfileViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  final CoreServicesImpl _coreServices = serviceLocator<CoreServicesImpl>();
  final TUISelfInfoViewModel _selfInfoViewModel =
      serviceLocator<TUISelfInfoViewModel>();

  V2TimUserFullInfo? _userInfo;

  String? userID;

  V2TimUserFullInfo? get userInfo {
    notifyListeners();
    return _userInfo ?? _selfInfoViewModel.loginInfo;
  }

  loadData({String? userID}) async {
    V2TimFriendInfo? friendUserInfo;
    if (userID != null) {
      final userInfoList =
          await _friendshipServices.getFriendsInfo(userIDList: [userID]);

      if (userInfoList != null) {
        friendUserInfo = userInfoList[0].friendInfo;
      }
    }

    _userInfo = friendUserInfo?.userProfile ??
        _selfInfoViewModel.loginInfo ??
        _coreServices.loginUserInfo;

    notifyListeners();
  }

  changeFriendVerificationMethod(int allowType) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        {"allowType": allowType},
      ),
    );

    if (res.code == 0) {
      _userInfo?.allowType = allowType;
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
      _userInfo?.gender = gender;
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
      _userInfo?.nickName = nickName;
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
      _userInfo?.selfSignature = selfSignature;
      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
  }

  _updatUserInfo(String key, dynamic value) {
    if (key == "nickName") {
      userInfo?.nickName = value;
    }
    if (key == "faceUrl") {
      userInfo?.faceUrl = value;
    }
    if (key == "nickName") {
      userInfo?.nickName = value;
    }
    if (key == "selfSignature") {
      userInfo?.selfSignature = value;
    }
    if (key == "gender") {
      userInfo?.gender = value;
    }
    if (key == "allowType") {
      userInfo?.allowType = value;
    }
    if (key == "customInfo") {
      userInfo?.customInfo = value;
    }
    if (key == "role") {
      userInfo?.role = value;
    }
    if (key == "level") {
      userInfo?.level = value;
    }
    if (key == "birthday") {
      userInfo?.birthday = value;
    }
  }

  updateSelfInfo(Map<String, dynamic> newSelfInfo) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        newSelfInfo,
      ),
    );
    if (res.code == 0) {
      newSelfInfo.forEach((key, value) {
        _updatUserInfo(key, value);
      });

      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
  }
}
