import 'dart:js';

import 'package:tencent_im_sdk_plugin_web/src/utils/utils.dart';

import '../mock_data/v2_tim_manager_mock_data.dart';
import '../mock_data/v2_tim_message_manager_mock_data.dart';

class MockTimWeb {
  static const event = {"MESSAGE_RECEIVED": "onMessageReceived"};

  /*
 * events-function(这是注释的说明)
 * @param enventName envent事件名称，根据不同的事件名称传金不同的参数
 * @param listenerCallback 传进来的监听回调
 */
  void on(String enventName, Function listenerCallback) {
    Map<String, dynamic> resultData = {};
    print("函数监听 enventName字段:");
    print(enventName);
    switch (enventName) {
      case "onMessageReceived":
        resultData = V2TimMessageManagerMockData.textMessageResultList;
        break;
    }

    listenerCallback(mapToJSObjForDeep(resultData));
  }

  PromiseJsImpl login(Object jsParam) {
    // success
    if (jsToMap(jsParam)["desc"] ==
        V2TimManagerMockData.loginMockParams["desc"]) {
      return returnJsSuccPromise(V2TimManagerMockData.loginMockRsultSuccMap);
    }

    // fail
    return returnJsFailPromise(V2TimManagerMockData.loginMockRsultFailMap);
  }

  // 返回JS Promise 成功
  PromiseJsImpl returnJsSuccPromise(Map<String, dynamic> data) => PromiseJsImpl(
      allowInterop((resolve, reject) => {resolve(mapToJSObj(data))}));

  // 返回JS Promise 失败
  PromiseJsImpl returnJsFailPromise(Map<String, dynamic> data) => PromiseJsImpl(
      allowInterop((resolve, reject) => {reject(mapToJSObj(data))}));
}
