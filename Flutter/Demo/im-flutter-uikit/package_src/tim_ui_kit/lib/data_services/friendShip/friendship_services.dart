import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';

abstract class FriendshipServices {
  Future<List<V2TimFriendInfoResult>?> getFriendsInfo({
    required List<String> userIDList,
  });

  Future<List<V2TimFriendOperationResult>?> addToBlackList({
    required List<String> userIDList,
  });

  Future<V2TimFriendOperationResult?> addFriend(
      {required String userID, required FriendTypeEnum addType});

  Future<List<V2TimFriendOperationResult>?> deleteFromBlackList({
    required List<String> userIDList,
  });

  Future<List<V2TimFriendOperationResult>?> deleteFromFriendList({
    required List<String> userIDList,
    required FriendTypeEnum deleteType,
  });

  Future<List<V2TimFriendInfo>?> getFriendList();

  Future<List<V2TimFriendInfo>?> getBlackList();

  Future<List<V2TimFriendCheckResult>?> checkFriend({
    required List<String> userIDList,
    required FriendTypeEnum checkType,
  });

  Future<void> setFriendshipListener({
    required V2TimFriendshipListener listener,
  });

  Future<V2TimFriendApplicationResult?> getFriendApplicationList();

  Future<V2TimFriendOperationResult?> acceptFriendApplication(
      {required FriendResponseTypeEnum responseType,
      required FriendApplicationTypeEnum type,
      required String userID});

  Future<V2TimFriendOperationResult?> refuseFriendApplication(
      {required FriendApplicationTypeEnum type, required String userID});

  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  });
}
