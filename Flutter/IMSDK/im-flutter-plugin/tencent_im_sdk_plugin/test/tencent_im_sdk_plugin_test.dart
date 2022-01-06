import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/im_flutter_plugin_platform_interface.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_value_callback.dart';

import 'mock_platform_interface.dart';

void main() {
  const MethodChannel channel = MethodChannel('tencent_im_sdk_plugin');
  final MockTencentPlatformInterface mock = MockTencentPlatformInterface();
  ImFlutterPlatform.instance = mock;

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      var a = Map<String, dynamic>();
      a['data'] = true;
      return a;
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  group("V2TimManager", () {
    test(".initSDK should be call with correct arguments", () async {
      final fakeListiner = V2TimSDKListener();
      final fakeSDKAppID = 123456;
      final fakeLogLevel = LogLevelEnum.V2TIM_LOG_DEBUG;
      final mockArguments = {
        'sdkAppID': fakeSDKAppID,
        'loglevel': fakeLogLevel,
      };
      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: true);
      mock
        ..setExpections(mockArguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response = await TencentImSDKPlugin.v2TIMManager.initSDK(
          sdkAppID: fakeSDKAppID,
          loglevel: fakeLogLevel,
          listener: fakeListiner);
      expect(response, fakeReturnValue);
    });

    test(".unInitSDK should call platform interface with correct params",
        () async {
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');
      mock..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager.unInitSDK();
      expect(response, fakeReturnValue);
    });
    test(".getVersion should call platform interface with correct params",
        () async {
      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: '1.1.1');
      mock..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager.getVersion();
      expect(response, fakeReturnValue);
    });
    test(".getServerTime should call platform interface with correct params",
        () async {
      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: 1111);
      mock..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager.getServerTime();
      expect(response, fakeReturnValue);
    });

    test(".login should call platform interface with correct params", () async {
      final fakeUserID = '121405';
      final fakeUserSig = 'xxxxxssss';
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');

      mock
        ..setExpections({"userID": fakeUserID, "userSig": fakeUserSig})
        ..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager
          .login(userID: fakeUserID, userSig: fakeUserSig);
      expect(response, fakeReturnValue);
    });
    test(".logout should call platform interface with correct params",
        () async {
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');
      mock..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager.logout();
      expect(response, fakeReturnValue);
    });

    test(".getLoginUser should call platform interface with correct params",
        () async {
      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: '940928');
      mock..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager.getLoginUser();
      expect(response, fakeReturnValue);
    });
    test(".getLoginStatus should call platform interface with correct params",
        () async {
      final fakeReturnValue = V2TimValueCallback(code: 0, desc: 'ok', data: 0);
      mock..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager.getLoginStatus();
      expect(response, fakeReturnValue);
    });
    test(
        ".sendC2CTextMessage should call platform interface with correct params",
        () async {
      final fakeText = 'test text message';
      final fakeUserID = '940928';
      final fakeMessage = V2TimMessage(elemType: 1);

      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: fakeMessage);
      mock
        ..setExpections({"text": fakeText, "userID": fakeUserID})
        ..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager
          .sendC2CTextMessage(text: fakeText, userID: fakeUserID);
      expect(response, fakeReturnValue);
    });
    test(
        ".sendGroupTextMessage should call platform interface with correct params",
        () async {
      final fakeText = 'test text message';
      final fakeGroupID = '940928';
      final fakePriority = 1;
      final fakeMessage = V2TimMessage(elemType: 1);

      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: fakeMessage);
      mock
        ..setExpections({
          "text": fakeText,
          "groupID": fakeGroupID,
          "priority": fakePriority
        })
        ..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager
          .sendGroupTextMessage(
              text: fakeText, groupID: fakeGroupID, priority: fakePriority);
      expect(response, fakeReturnValue);
    });
    test(
        ".sendGroupCustomMessage should call platform interface with correct params",
        () async {
      final fakeCustomData = "{data: 'test data'}";
      final fakeGroupID = '940928';
      final fakePriority = MessagePriorityEnum.V2TIM_PRIORITY_NORMAL;
      final fakeMessage = V2TimMessage(elemType: 1);

      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: fakeMessage);
      mock
        ..setExpections({
          "customData": fakeCustomData,
          "groupID": fakeGroupID,
          "priority": fakePriority
        })
        ..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager
          .sendGroupCustomMessage(
              customData: fakeCustomData,
              groupID: fakeGroupID,
              priority: fakePriority);
      expect(response, fakeReturnValue);
    });

    test(
        ".sendC2CCustomMessage should call platform interface with correct params",
        () async {
      final fakeCustomData = "{data: 'test data'}";
      final fakeUserID = '940928';
      final fakeMessage = V2TimMessage(elemType: 2);

      final fakeReturnValue =
          V2TimValueCallback(code: 0, desc: 'ok', data: fakeMessage);
      mock
        ..setExpections({"customData": fakeCustomData, "userID": fakeUserID})
        ..setResponses(Future.value(fakeReturnValue));
      final response = await TencentImSDKPlugin.v2TIMManager
          .sendC2CCustomMessage(customData: fakeCustomData, userID: fakeUserID);
      expect(response, fakeReturnValue);
    });

    // test(
    //     ".createGroup should call platform interface with correct params",
    //     () async {
    //   final fakeCustomData = "{data: 'test data'}";
    //   final fakeUserID = '940928';
    //   final fakeMessage = V2TimMessage(elemType: 2);

    //   final fakeReturnValue =
    //       V2TimValueCallback(code: 0, desc: 'ok', data: fakeMessage);
    //   mock
    //     ..setExpections({"customData": fakeCustomData, "userID": fakeUserID})
    //     ..setResponses(fakeReturnValue);
    //   final response = await TencentImSDKPlugin.v2TIMManager
    //       .sendC2CCustomMessage(customData: fakeCustomData, userID: fakeUserID);
    //   expect(response, fakeReturnValue);
    // });
    test(".joinGroup should call platform interface with correct params",
        () async {
      final fakeGroupID = 'test group id';
      final fakeMessage = 'hello join message';
      final fakeGroupType = 'Work';
      final arguments = {
        "groupID": fakeGroupID,
        "message": fakeMessage,
        "groupType": fakeGroupType,
      };
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');

      mock
        ..setExpections(arguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response = await TencentImSDKPlugin.v2TIMManager.joinGroup(
          groupID: fakeGroupID, message: fakeMessage, groupType: fakeGroupType);
      expect(response, fakeReturnValue);
    });
    test(".quitGroup should call platform interface with correct params",
        () async {
      final fakeGroupID = 'test group id';
      final arguments = {
        "groupID": fakeGroupID,
      };
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');

      mock
        ..setExpections(arguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response =
          await TencentImSDKPlugin.v2TIMManager.quitGroup(groupID: fakeGroupID);
      expect(response, fakeReturnValue);
    });
    test(".dismissGroup should call platform interface with correct params",
        () async {
      final fakeGroupID = 'test group id';
      final arguments = {
        "groupID": fakeGroupID,
      };
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');

      mock
        ..setExpections(arguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response = await TencentImSDKPlugin.v2TIMManager
          .dismissGroup(groupID: fakeGroupID);
      expect(response, fakeReturnValue);
    });
    test(".getUsersInfo should call platform interface with correct params",
        () async {
      final fakeUserIDList = ['userID1', 'userID2'];
      final arguments = {
        "userIDList": fakeUserIDList,
      };
      final fakeReturnValue = V2TimValueCallback(code: 0, desc: 'ok', data: [
        V2TimUserFullInfo(userID: 'userID1'),
        V2TimUserFullInfo(userID: 'userID2')
      ]);

      mock
        ..setExpections(arguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response = await TencentImSDKPlugin.v2TIMManager
          .getUsersInfo(userIDList: fakeUserIDList);
      expect(response, fakeReturnValue);
    });
    test(".setSelfInfo should call platform interface with correct params",
        () async {
      final fakeUserFullInfo = V2TimUserFullInfo();
      final arguments = {
        "userFullInfo": fakeUserFullInfo,
      };
      final fakeReturnValue = V2TimCallback(code: 0, desc: 'ok');

      mock
        ..setExpections(arguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response = await TencentImSDKPlugin.v2TIMManager
          .setSelfInfo(userFullInfo: fakeUserFullInfo);
      expect(response, fakeReturnValue);
    });

    test(
        ".callExperimentalAPI should call platform interface with correct params",
        () async {
      final fakeApi = 'test api';
      final arguments = {
        "api": fakeApi,
      };
      final fakeReturnValue = V2TimValueCallback(code: 0, desc: 'ok', data: {});

      mock
        ..setExpections(arguments)
        ..setResponses(Future.value(fakeReturnValue));

      final response = await TencentImSDKPlugin.v2TIMManager
          .callExperimentalAPI(api: fakeApi);
      expect(response, fakeReturnValue);
    });
  });
}
