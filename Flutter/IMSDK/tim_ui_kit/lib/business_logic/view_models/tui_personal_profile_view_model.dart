// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:tencent_im_base/tencent_im_base.dart';
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

  Future<V2TimCallback> changeFriendVerificationMethod(int allowType) async {
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
    return res;
  }

  // 1：男 女：2
  Future<V2TimCallback> updateGender(int gender) async {
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
    return res;
  }

  Future<V2TimCallback> updateNickName(String nickName) async {
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
    return res;
  }

  Future<V2TimCallback> updateSelfSignature(String selfSignature) async {
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
    return res;
  }

  updateUserInfo(String key, dynamic value) {
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

  Future<V2TimCallback> updateSelfInfo(Map<String, dynamic> newSelfInfo) async {
    final res = await _coreServices.setSelfInfo(
      userFullInfo: V2TimUserFullInfo.fromJson(
        newSelfInfo,
      ),
    );
    if (res.code == 0) {
      newSelfInfo.forEach((key, value) {
        updateUserInfo(key, value);
      });

      notifyListeners();
    } else {
      print("${res.code},${res.desc}");
    }
    return res;
  }
}
