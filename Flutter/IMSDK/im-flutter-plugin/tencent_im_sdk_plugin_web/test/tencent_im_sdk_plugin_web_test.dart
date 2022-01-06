import 'package:flutter_test/flutter_test.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/enum/V2TimSimpleMsgListener.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_user_info.dart';
import 'package:tencent_im_sdk_plugin_web/src/manager/im_sdk_plugin_js.dart';

import 'package:tencent_im_sdk_plugin_web/tencent_im_sdk_plugin_web.dart';

import 'mock/mock_data/v2_tim_manager_mock_data.dart';
import 'mock/mock_data/v2_tim_message_manager_mock_data.dart';
import 'mock/mock_function/mock_tim.dart';

void main() {
  TencentImSDKPluginWeb timWeb = TencentImSDKPluginWeb();

  setUp(() {
    // print(MockTimWeb.login(""));
    // MockTimWeb.login({});
    V2TIMManagerWeb.setTimWeb(MockTimWeb());
  });

  tearDown(() {});

  group("V2TIMManager", () {
    test('login', () async {
      final result = await timWeb.login(
        userID: V2TimManagerMockData.loginMockParams["userID"] ?? "",
        userSig: V2TimManagerMockData.loginMockParams["userSig"] ?? "",
      );

      expect(result.toJson(), V2TimManagerMockData.loginMockRsultSuccMap);
    });
  });

  group("V2TIMMessageManager", () {
    test("addSimpleMsgListener", () async {
      final listener = V2TimSimpleMsgListener();
      listener.onRecvC2CTextMessage = (
        String msgID,
        V2TimUserInfo sender,
        String customData,
      ) {
        final originalData =
            V2TimMessageManagerMockData.textMessageResultList["data"][0];
        final senderUserInfo = V2TimUserInfo(
            userID: originalData["from"],
            nickName: originalData["nick"],
            faceUrl: originalData["avatar"]);

        expect(msgID, originalData["ID"]);
        expect(sender.toJson(), senderUserInfo.toJson());
        expect(customData, originalData["payload"]["text"]);
      };
      timWeb.addSimpleMsgListener(listener: listener);
    });
  });
}
