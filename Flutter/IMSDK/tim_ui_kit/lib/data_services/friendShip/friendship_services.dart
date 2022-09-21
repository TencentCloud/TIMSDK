import 'package:tencent_im_base/tencent_im_base.dart';

abstract class FriendshipServices {
  Future<List<V2TimFriendInfoResult>?> getFriendsInfo({
    required List<String> userIDList,
  });

  Future<List<V2TimUserFullInfo>?> getUsersInfo({
    required List<String> userIDList,
  });

  Future<List<V2TimFriendOperationResult>?> addToBlackList({
    required List<String> userIDList,
  });

  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    required FriendTypeEnum addType,
    String? remark,
    String? friendGroup,
    String? addSource,
    String? addWording,
  });

  Future<List<V2TimFriendOperationResult>?> deleteFromBlackList({
    required List<String> userIDList,
  });

  Future<List<V2TimFriendOperationResult>?> deleteFromFriendList({
    required List<String> userIDList,
    required FriendTypeEnum deleteType,
  });

  Future<List<V2TimFriendInfo>?> getFriendList();

  Future<List<V2TimFriendInfoResult>?> searchFriends({
    required V2TimFriendSearchParam searchParam,
  });

  Future<List<V2TimFriendInfo>?> getBlackList();

  Future<List<V2TimFriendCheckResult>?> checkFriend({
    required List<String> userIDList,
    required FriendTypeEnum checkType,
  });

  Future<void> addFriendListener({
    required V2TimFriendshipListener listener,
  });
  Future<void> removeFriendListener({
    V2TimFriendshipListener? listener,
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

  Future<List<V2TimUserStatus>> getUserStatus({
    required List<String> userIDList,
  });
}
