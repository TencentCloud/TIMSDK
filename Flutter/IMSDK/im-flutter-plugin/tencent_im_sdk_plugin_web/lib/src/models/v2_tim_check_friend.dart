import 'package:tencent_im_sdk_plugin_web/src/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class CheckFriend {
  static Object formateParams(Map<String, dynamic> params) {
    final formateParams = {
      "userIDList": params["userIDList"],
      "type": FriendTypeWeb.convertWebFriendType(params["checkType"]),
    };

    return mapToJSObj(formateParams);
  }

  static formateResult(Map<String, dynamic> params) {
    final successUserIDList = params['successUserIDList'];
    List<dynamic> resultArr = [];
    successUserIDList.forEach((item) {
      final formatedItem = jsToMap(item);
      resultArr.add({
        "userID": formatedItem['userID'],
        "resultCode": formatedItem['code'],
        "resultInfo": formatedItem['resultInfo'],
        "resultType": FriendTypeWeb.convertFromWebCheckFriendType(
            formatedItem['relation'])
      });
    });

    return resultArr;
  } // convertFromWebCheckFriendType

}
