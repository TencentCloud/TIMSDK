import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/utils.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tim_ui_kit/data_services/friendShip/friendship_services.dart';
import 'package:tim_ui_kit/data_services/services_locatar.dart';

class TUINewContactViewModel extends ChangeNotifier {
  final FriendshipServices _friendshipServices =
      serviceLocator<FriendshipServices>();
  List<V2TimFriendApplication?>? _friendApplicationList;
  int _unReadCount = 0;

  int get unreadCount => _unReadCount;

  List<V2TimFriendApplication?>? get friendApplicationList =>
      _friendApplicationList;

  loadData() async {
    final newContactRes = await _friendshipServices.getFriendApplicationList();
    // Only Received Application
    _friendApplicationList = newContactRes?.friendApplicationList
        ?.where((item) =>
            item!.type ==
            EnumUtils.convertFriendApplicationTypeEnum(
                    FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_COME_IN)
                as int)
        .toList();
    _unReadCount = newContactRes?.unreadCount ?? 0;
    notifyListeners();
  }

  Future<V2TimFriendOperationResult?> acceptFriendApplication(
      String userID) async {
    final res = await _friendshipServices.acceptFriendApplication(
        responseType: FriendResponseTypeEnum.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD,
        type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH,
        userID: userID);
    if (res != null) {
      return res;
    }
  }

  Future<V2TimFriendOperationResult?> refuseFriendApplication(
      String userID) async {
    final res = await _friendshipServices.refuseFriendApplication(
        type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH,
        userID: userID);
    if (res != null) {
      return res;
    }
  }

  setFriendshipListener({V2TimFriendshipListener? listener}) {
    final convListener = V2TimFriendshipListener(
      onFriendApplicationListAdded: (applicationList) {
        listener?.onFriendApplicationListAdded(applicationList);
        loadData();
      },
      onFriendApplicationListDeleted: (userIDList) {
        listener?.onFriendApplicationListDeleted(userIDList);
        loadData();
      },
      onFriendApplicationListRead: () {
        listener?.onFriendApplicationListRead();
        loadData();
      },
    );

    _friendshipServices.setFriendshipListener(listener: convListener);
  }
}
