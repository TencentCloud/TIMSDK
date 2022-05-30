import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class FriendGroup {
  static formateParams(Map<String, dynamic> data) {
    return mapToJSObj(
        {"userIDList": data["userIDList"], "name": data["groupName"]});
  }

  static List<dynamic> formateResult(Map<String, dynamic> object) {
    List<dynamic> userIDList = jsToMap(object['friendGroup'])['userIDList'];
    List<dynamic> resultArr = [];
    for (var userID in userIDList) {
      resultArr.add(formateFriendGroupItem(userID));
    }
    return resultArr;
  }

  static List<dynamic> formateGroupResult(list) {
    List<dynamic> resultArr = [];
    list.forEach((item) {
      final formatedItem = jsToMap(item);
      resultArr.add({
        "name": formatedItem['name'],
        "friendCount": formatedItem['count'],
        "friendIDList": formatedItem['userIDList'],
      });
    });

    return resultArr;
  }

  static Map<String, dynamic> formateFriendGroupItem(userID) {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userID'] = userID;
    return data;
  }
}
