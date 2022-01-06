import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_profile.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class FriendList {
  static List<Map<String, dynamic>> formatedFriendListRes(friendList) {
    final List<Map<String, dynamic>> formatedList = List.empty(growable: true);
    friendList.forEach((listItem) {
      final item = jsToMap(listItem);
      final profile = jsToMap(item['profile']);
      final formatedItem = <String, dynamic>{
        'userID': item['userID'],
        'friendGroups': item['groupList'],
        'friendRemark': item['remark'],
        'userProfile': V2TimProfile.userFullInfoExtract(profile),
      };
      formatedList.add(formatedItem);
    });

    return formatedList;
  }
}
