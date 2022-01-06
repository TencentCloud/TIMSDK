import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';

class MockTencentPlatformInterface extends Fake
    with MockPlatformInterfaceMixin
    implements ImFlutterPlatform {
  dynamic arguments;
  dynamic responses;

  void setExpections(dynamic arguments) {
    this.arguments = arguments;
  }

  void setResponses(dynamic responses) {
    this.responses = responses;
  }

  @override
  Future<V2TimValueCallback<bool>> initSDK(
      {required int sdkAppID,
      required int loglevel,
      V2TimSDKListener? listener,
      String? listenerUuid}) async {
    final arg = {"sdkAppID": sdkAppID, "loglevel": loglevel};
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimCallback> unInitSDK() {
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<String>> getVersion() {
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<int>> getServerTime() {
    return this.responses;
  }

  @override
  Future<V2TimCallback> login({
    required String userID,
    required String userSig,
  }) {
    final arg = {"userID": userID, "userSig": userSig};
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimCallback> logout() async {
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<String>> getLoginUser() async {
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<int>> getLoginStatus() async {
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CTextMessage({
    required String text,
    required String userID,
  }) async {
    final arg = {"text": text, "userID": userID};
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupTextMessage({
    required String text,
    required String groupID,
    int priority = 0,
  }) async {
    final arg = {'text': text, 'groupID': groupID, 'priority': priority};
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendC2CCustomMessage({
    required String customData,
    required String userID,
  }) async {
    final arg = {
      "customData": customData,
      "userID": userID,
    };
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<V2TimMessage>> sendGroupCustomMessage({
    required String customData,
    required String groupID,
    int priority = 0,
  }) async {
    final arg = {
      "customData": customData,
      "groupID": groupID,
      "priority": priority
    };
    expect(arg, this.arguments);
    return this.responses;
  }

  // @override
  // Future<V2TimValueCallback<String>> createGroup({
  //   required String groupType,
  //   required String groupName,
  //   String? groupID,
  // }) async {
  //   return ImFlutterPlatform.instance.createGroup(
  //       groupType: groupType, groupName: groupName, groupID: groupID);
  // }

  @override
  Future<V2TimCallback> joinGroup({
    required String groupID,
    required String message,
    String? groupType,
  }) async {
    final arg = {
      "groupID": groupID,
      "message": message,
      "groupType": groupType,
    };
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimCallback> quitGroup({
    required String groupID,
  }) async {
    final arg = {
      "groupID": groupID,
    };
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimCallback> dismissGroup({
    required String groupID,
  }) async {
    final arg = {
      "groupID": groupID,
    };
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<List<V2TimUserFullInfo>>> getUsersInfo({
    required List<String> userIDList,
  }) async {
    final arg = {
      "userIDList": userIDList,
    };
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimCallback> setSelfInfo({
    required V2TimUserFullInfo userFullInfo,
  }) async {
    final arg = {"userFullInfo": userFullInfo};
    expect(arg, this.arguments);
    return this.responses;
  }

  @override
  Future<V2TimValueCallback<Object>> callExperimentalAPI({
    required String api,
    Object? param,
  }) async {
    final arg = {"api": api};
    expect(arg, this.arguments);
    return this.responses;
  }
}
