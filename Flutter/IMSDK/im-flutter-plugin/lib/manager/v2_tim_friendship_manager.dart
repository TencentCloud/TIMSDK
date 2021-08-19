import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimFriendshipListener.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';

///关系链接口，包含了好友的添加和删除，黑名单的添加和删除等逻辑
///
///[setFriendListener]设置关系链监听器
///
///[getFriendList]获取好友列表
///
///[getFriendsInfo]获取指定好友资料
///
///[setFriendInfo]设置指定好友资料
///
///[addFriend]添加好友
///
///[deleteFromFriendList]删除好友
///
///[checkFriend]检查指定用户的好友关系
///
///[getFriendApplicationList]获取好友申请列表
///
///[acceptFriendApplication]同意好友申请
///
///[refuseFriendApplication]拒绝好友申请
///
///[deleteFriendApplication]删除好友申请
///
///[setFriendApplicationRead]设置好友申请已读
///
///[addToBlackList]添加用户到黑名单
///
///[deleteFromBlackList]把用户从黑名单中删除
///
///[getBlackList]获取黑名单列表
///
///[createFriendGroup]新建好友分组
///
///[getFriendGroups]获取分组信息
///
///[deleteFriendGroup]删除好友分组
///
///[renameFriendGroup]修改好友分组的名称
///
///[addFriendsToFriendGroup]添加好友到一个好友分组
///
///[deleteFriendsFromFriendGroup]从好友分组中删除好友
///
///{@category Manager}
///
class V2TIMFriendshipManager {
  ///@nodoc
  late MethodChannel _channel;

  ///@nodoc
  V2TimFriendshipListener friendListener = new V2TimFriendshipListener();

  ///@nodoc
  V2TIMFriendshipManager(channel) {
    _channel = channel;
  }

  ///设置关系链监听器
  ///
  void setFriendListener({
    required V2TimFriendshipListener listener,
  }) {
    this.friendListener = listener;
    _channel.invokeMethod("setFriendListener", buildParam({}));
  }

  ///获取好友列表
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getFriendList() async {
    return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendList",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  /// 获取指定好友资料
  ///
  /// 参数
  ///
  /// ```
  /// userIDList	好友 userID 列表
  /// ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfoResult>>> getFriendsInfo({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendInfoResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendsInfo",
          buildParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  /// 设置指定好友资料
  ///
  Future<V2TimCallback> setFriendInfo({
    required String userID,
    String? friendRemark,
    Map<String, String>? friendCustomInfo,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setFriendInfo",
          buildParam(
            {
              "userID": userID,
              "friendRemark": friendRemark,
              "friendCustomInfo": friendCustomInfo,
            },
          ),
        ),
      ),
    );
  }

  /// 添加好友
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>> addFriend({
    required String userID,
    String? remark,
    String? friendGroup,
    String? addWording,
    String? addSource,
    required int addType,
  }) async {
    return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addFriend",
          buildParam(
            {
              "userID": userID,
              "remark": remark,
              "friendGroup": friendGroup,
              "addWording": addWording,
              "addSource": addSource,
              "addType": addType,
            },
          ),
        ),
      ),
    );
  }

  ///   删除好友
  ///
  /// 参数
  ///
  /// ```
  /// userIDList	要删除的好友 userID 列表
  /// ID 建议一次最大 100 个，因为数量过多可能会导致数据包太大被后台拒绝，后台限制数据包最大为 1M。
  /// deleteType	删除类型
  /// ```
  ///
  /// ```
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_SINGLE：单向好友
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH：双向好友
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromFriendList({
    required List<String> userIDList,
    required int deleteType,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFromFriendList",
          buildParam(
            {
              "userIDList": userIDList,
              "deleteType": deleteType,
            },
          ),
        ),
      ),
    );
  }

  /// 检查指定用户的好友关系
  ///
  /// 参数
  ///
  /// ```
  /// checkType	检查类型
  /// ```
  ///
  /// ```
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_SINGLE：单向好友
  /// V2TIMFriendInfo.V2TIM_FRIEND_TYPE_BOTH：双向好友
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendCheckResult>>> checkFriend({
    required List<String> userIDList,
    required int checkType,
  }) async {
    return V2TimValueCallback<List<V2TimFriendCheckResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "checkFriend",
          buildParam(
            {
              "userIDList": userIDList,
              "checkType": checkType,
            },
          ),
        ),
      ),
    );
  }

  ///获取好友申请列表
  ///
  Future<V2TimValueCallback<V2TimFriendApplicationResult>>
      getFriendApplicationList() async {
    return V2TimValueCallback<V2TimFriendApplicationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendApplicationList",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  /// 同意好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// responseType	建立单向/双向好友关系
  /// ```
  ///
  /// ```
  /// V2TIMFriendApplication.V2TIM_FRIEND_ACCEPT_AGREE：同意添加单向好友
  /// V2TIMFriendApplication.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD：同意并添加为双向好友
  /// ```
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      acceptFriendApplication({
    required int responseType,
    required int type,
    required String userID,
  }) async {
    return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "acceptFriendApplication",
          buildParam(
            {
              "responseType": responseType,
              "type": type,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  /// 拒绝好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// ```
  ///
  Future<V2TimValueCallback<V2TimFriendOperationResult>>
      refuseFriendApplication({
    required int type,
    required String userID,
  }) async {
    return V2TimValueCallback<V2TimFriendOperationResult>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "refuseFriendApplication",
          buildParam(
            {
              "type": type,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  /// 删除好友申请
  ///
  /// 参数
  ///
  /// ```
  /// application	好友申请信息，getFriendApplicationList 成功后会返回
  /// ```
  ///
  Future<V2TimCallback> deleteFriendApplication({
    required int type,
    required String userID,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendApplication",
          buildParam(
            {
              "type": type,
              "userID": userID,
            },
          ),
        ),
      ),
    );
  }

  ///设置好友申请已读
  ///
  Future<V2TimCallback> setFriendApplicationRead() async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "setFriendApplicationRead",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  ///添加用户到黑名单
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>> addToBlackList({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addToBlackList",
          buildParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  ///把用户从黑名单中删除
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFromBlackList({
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFromBlackList",
          buildParam(
            {
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  ///获取黑名单列表
  ///
  Future<V2TimValueCallback<List<V2TimFriendInfo>>> getBlackList() async {
    return V2TimValueCallback<List<V2TimFriendInfo>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getBlackList",
          buildParam(
            {},
          ),
        ),
      ),
    );
  }

  ///新建好友分组
  ///
  ///参数
  ///
  ///```
  /// groupName	分组名称
  /// userIDList	要添加到分组中的好友 userID 列表
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      createFriendGroup({
    required String groupName,
    List<String>? userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "createFriendGroup",
          buildParam(
            {
              "groupName": groupName,
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  /// 获取分组信息
  ///
  /// 参数
  ///
  /// ```
  /// groupNameList	要获取信息的好友分组名称列表,传入 null 获得所有分组信息
  /// ```
  ///
  Future<V2TimValueCallback<List<V2TimFriendGroup>>> getFriendGroups({
    List<String>? groupNameList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendGroup>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "getFriendGroups",
          buildParam(
            {
              "groupNameList": groupNameList,
            },
          ),
        ),
      ),
    );
  }

  ///删除好友分组
  ///
  Future<V2TimCallback> deleteFriendGroup({
    required List<String> groupNameList,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendGroup",
          buildParam(
            {
              "groupNameList": groupNameList,
            },
          ),
        ),
      ),
    );
  }

  /// 修改好友分组的名称
  ///
  /// 参数
  ///
  /// ```
  /// oldName	旧的分组名称
  /// newName	新的分组名称
  /// callback	回调
  /// ```
  ///
  Future<V2TimCallback> renameFriendGroup({
    required String oldName,
    required String newName,
  }) async {
    return V2TimCallback.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "renameFriendGroup",
          buildParam(
            {
              "oldName": oldName,
              "newName": newName,
            },
          ),
        ),
      ),
    );
  }

  ///添加好友到一个好友分组
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      addFriendsToFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "addFriendsToFriendGroup",
          buildParam(
            {
              "groupName": groupName,
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  ///从好友分组中删除好友
  ///
  Future<V2TimValueCallback<List<V2TimFriendOperationResult>>>
      deleteFriendsFromFriendGroup({
    required String groupName,
    required List<String> userIDList,
  }) async {
    return V2TimValueCallback<List<V2TimFriendOperationResult>>.fromJson(
      formatJson(
        await _channel.invokeMethod(
          "deleteFriendsFromFriendGroup",
          buildParam(
            {
              "groupName": groupName,
              "userIDList": userIDList,
            },
          ),
        ),
      ),
    );
  }

  ///@nodoc
  Map buildParam(Map param) {
    param["TIMManagerName"] = "friendshipManager";
    return param;
  }

  ///@nodoc
  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}
