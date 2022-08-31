// ignore_for_file: unused_import

import 'dart:js_util';

import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin_web/src/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/im_sdk_plugin_js.dart';
import 'package:tencent_im_sdk_plugin_web/src/models/v2_tim_profile.dart';
import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

class FriendInfo {
  static Object formateGetInfoParams(Map<String, dynamic> paramJS) {
    return mapToJSObj({"userIDList": paramJS["userIDList"]});
  }

  static getRelationByUserID(String userID, List<dynamic> successUserIDList) {
    for (var i = 0; i < successUserIDList.length; i++) {
      var item = jsToMap(successUserIDList[i]);
      if (item['userID'] == userID) {
        return FriendTypeWeb.convertFromWebCheckFriendType(item['relation']);
      }
    }
  }

  static Future<List> formateFriendInfoResult(list, failureUserIDList) async {
    final formateList = [];
    List<dynamic> userIDList = [];
    list.forEach((element) {
      userIDList.add(jsToMap(element)['userID']);
    });
    failureUserIDList.forEach((element) {
      userIDList.add(jsToMap(element)['userID']);
    });

    final formateParams = mapToJSObj({"userIDList": userIDList});
    if (userIDList.isEmpty) {
      return [];
    }

    final res = await wrappedPromiseToFuture(
        V2TIMManagerWeb.timWeb!.checkFriend(formateParams));
    final successUserIDList = jsToMap(res.data)['successUserIDList'];

    for (int i = 0; i < list.length; i++) {
      final element = jsToMap(list[i]);
      Map<String, dynamic> item = {
        "resultCode": 0, // web没有
        "resultInfo": "OK", // web没有
        "relation":
            getRelationByUserID(element['userID'] as String, successUserIDList),
        "friendInfo": formateFriendInfo(element)
      };

      formateList.add(item);
    }

    formateList.addAll(
        formateFriendInfoFailInfoList(failureUserIDList, successUserIDList));

    return formateList;
  }

  static List<dynamic> formateFriendInfoFailInfoList(
      List<dynamic> faileList, List<dynamic> successUserIDList) {
    return faileList
        .map((e) => {
              "resultCode": jsToMap(e)['code'],
              "resultInfo": jsToMap(e)['message'],
              "relation": getRelationByUserID(
                  jsToMap(e)['userID'] as String, successUserIDList),
              "friendInfo": formateFriendInfo(jsToMap(e))
            })
        .toList();
  }

  static List<dynamic> formateFriendInfoToList(List<dynamic> list) {
    return list.map((e) => formateFriendInfo(jsToMap(e))).toList();
  }

  static Map<String, dynamic> formateFriendInfo(Map<String, dynamic> data) {
    // var data = jsToMap(params);
    log(data);
    Map<String, dynamic> infoMap = {
      "userID": data['userID'],
      "friendRemark": data['remark'],
      "friendGroups": data['groupList'] ?? [],
      "userProfile": V2TimProfile.userFullInfoExtract(jsToMap(data['profile'])),
      "friendCustomInfo": formateFriendCustomField(data['friendCustomField'])
    };

    return infoMap;
  }

  static Map<String, dynamic> formateFriendCustomField(list) {
    Map<String, dynamic> result = {};
    if (list == null || list.length == 0) {
      return result;
    } else {
      for (var i = 0; i < list.length; i++) {
        // 遍历js object
        for (var key in list[i]) {
          result[key] = list[i][key];
        }
      }

      return result;
    }
  }

  static List<Object> formateFriendCustomInfo(Map<String, dynamic>? params) {
    if (params == null) return [];
    List<Object> list = [];
    params.forEach((k, v) => list.add(mapToJSObj({"key": k, "value": v})));

    return list;
  }
}
