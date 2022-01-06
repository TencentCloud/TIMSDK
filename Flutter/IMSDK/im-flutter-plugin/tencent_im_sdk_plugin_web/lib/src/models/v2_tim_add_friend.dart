import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class AddFriend {
  static Object formateParams(Map<String, dynamic> params) {
    return mapToJSObj({
      "to": params["userID"],
      "source": params["addSource"].toString().startsWith("AddSource_Type_")
          ? params["addSource"]
          : "AddSource_Type_${params["addSource"]}",
      "remark": params["remark"],
      "groupName": params["friendGroup"],
      "wording": params["addWording"],
      "type": FriendTypeWeb.convertWebFriendType(params["addType"]),
    });
  }

  static Map<String, dynamic> formateResult(Map<String, dynamic> object) {
    return <String, dynamic>{
      "userID": object['userID'],
      "resultCode": object['code'] ?? null,
      "resultInfo": object['message'] ?? null,
    };
  }
}

class FriendApplication {
  static Map<String, dynamic> formateResult(Map<String, dynamic> data) {
    List<dynamic> friendApplicationList = [];
    int unreadCount = data['unreadCount'];
    data['friendApplicationList'].forEach((item) =>
        friendApplicationList.add(formateApplicationItem(jsToMap(item))));

    return {
      "unreadCount": unreadCount,
      "friendApplicationList": friendApplicationList
    };
  }

  static Map<String, dynamic> formateApplicationItem(
      Map<String, dynamic> params) {
    return <String, dynamic>{
      "userID": params['userID'],
      "addSource": params['source'],
      "addWording": params['wording'],
      "type": FriendTypeWeb.convertFromApplicationFriendType(params['type']),
      "nickname": params['nick'],
      "faceUrl": params['avatar'],
      "addTime": params['time'],
    };
  }
}

// 这里type和responseType是一样的目的是为了底层兼容
class AcceptFriendApplication {
  static Object formateParams(Map<String, dynamic> params) {
    return mapToJSObj({
      "userID": params["userID"],
      "type": FriendTypeWeb.convertToAcceptFriendType(
          params["responseType"] ?? params["type"]),
    });
  }
}
