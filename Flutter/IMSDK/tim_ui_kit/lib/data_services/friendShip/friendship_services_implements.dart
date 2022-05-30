import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_search_param.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class FriendshipServicesImpl with FriendshipServices {
  @override
  Future<List<V2TimFriendInfoResult>?> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getFriendsInfo(userIDList: userIDList);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<List<V2TimFriendOperationResult>?> addToBlackList({
    required List<String> userIDList,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .addToBlackList(userIDList: userIDList);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    required FriendTypeEnum addType,
    String? remark,
    String? friendGroup,
    String? addSource,
    String? addWording,
  }) async {
    return TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriend(
          userID: userID,
          addType: addType,
          remark: remark,
          addWording: addWording,
          friendGroup: friendGroup,
          addSource: addSource,
        );
  }

  @override
  Future<List<V2TimFriendOperationResult>?> deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFromBlackList(userIDList: userIDList);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<List<V2TimFriendOperationResult>?> deleteFromFriendList({
    required List<String> userIDList,
    required FriendTypeEnum deleteType,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .deleteFromFriendList(userIDList: userIDList, deleteType: deleteType);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<List<V2TimFriendInfo>?> getFriendList() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getFriendList();
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<List<V2TimFriendInfo>?> getBlackList() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getBlackList();
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<List<V2TimFriendCheckResult>?> checkFriend({
    required List<String> userIDList,
    required FriendTypeEnum checkType,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .checkFriend(userIDList: userIDList, checkType: checkType);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<void> setFriendshipListener({
    required V2TimFriendshipListener listener,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .addFriendListener(listener: listener);
  }

  @override
  Future<void> removeFriendListener({
    V2TimFriendshipListener? listener,
  }) {
    return TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .removeFriendListener(listener: listener);
  }

  @override
  Future<V2TimFriendApplicationResult?> getFriendApplicationList() async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .getFriendApplicationList();
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimFriendOperationResult?> acceptFriendApplication({
    required FriendResponseTypeEnum responseType,
    required FriendApplicationTypeEnum type,
    required String userID,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .acceptFriendApplication(
          responseType: responseType,
          type: type,
          userID: userID,
        );
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimFriendOperationResult?> refuseFriendApplication(
      {required FriendApplicationTypeEnum type, required String userID}) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .refuseFriendApplication(type: type, userID: userID);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }

  @override
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .setFriendInfo(
            friendRemark: friendRemark,
            friendCustomInfo: friendCustomInfo,
            userID: userID);
    if (res.code == 0) {
      return res;
    }
    return res;
  }

  @override
  Future<List<V2TimFriendInfoResult>?> searchFriends({
    required V2TimFriendSearchParam searchParam,
  }) async {
    final res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .searchFriends(searchParam: searchParam);
    if (res.code == 0) {
      return res.data;
    }
    return null;
  }
}
