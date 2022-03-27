#### Basic use case

#### Online api test tool (scan code to download)

![img](https://main.qcloudimg.com/raw/4658a0d24c33f6ec42b07bc8e36234d9.png)

#### Api call use case

[GitHub address](https://github.com/tencentyun/imApiFlutterExample)

- Initialization

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level.dart';
import 'package:tencent_im_sdk_plugin/manager/v2_tim_manager.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
function initLisener(data){
  String type = data.type;
  switch(type){
      case: 'onConnecting':
      case: 'onConnectSuccess':
      case: 'onConnectFailed':
      case: 'onKickedOffline':
      case: 'onUserSigExpired':
      case: 'onSelfInfoUpdated':
  }
}
// Get Tencent instant messaging IM manager;
V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
// Initialize SDK
V2TimValueCallback<bool> initRes = await timManager.initSDK(
      sdkAppID: sdkAppID,// Fill in the sdkappid applied on the console
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: initLisener,
);

// All data structures returned by V2TimValueCallback
int code initRes.code；
String desc = initRes.desc;
bool data = initRes.data;// Generic type received when instantiating for V2TimValueCallback.

if(initRes.code == 0){
  // Initialization successful
  // The following monitoring can be set as needed. To prevent missing messages, please set monitoring before logging in.
  // simple monitor
  timManager.addSimpleMsgListener(
    listener: simpleMsgListener,
  );
 // Various monitoring can be added here, such as session monitoring, message receiving monitoring, group monitoring, etc.
 V2TimCallback loginRes await timManager.login(
   userID: userId,
   userSig: userSig,
  );
  // All data structures returned by V2TimCallback
  int code  = loginRes.code;
  String desc = loginRes.desc;
  
  if(code==0){
    // login successful
    // send messages
    timManager.sendC2CTextMessage(text:text,userID:userID,)
    //....
    // Any method of the SDK can be called here.
  }else{
    // Login failed
    print(desc);
  }
}else{
  // initialization failed
}

```



**Managers**

- [**V2TIMManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_manager/V2TIMManager-class.html)

  The group advanced interface includes advanced functions of the group, such as group member invitation, non-group member application to join the group and other operation interfaces.

  

- [**V2TIMFriendshipManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_friendship_manager/V2TIMFriendshipManager-class.html)

  The relationship chain interface includes logic for adding and deleting friends, and adding and deleting blacklists.

  

- [**V2TIMGroupManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_group_manager/V2TIMGroupManager-class.html)

  The group advanced interface includes advanced functions of the group, such as group member invitation, non-group member application to join the group and other operation interfaces.

  

- [**V2TIMConversationManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_conversation_manager/V2TIMConversationManager-class.html)

  The session interface contains the logic for acquiring, deleting and updating sessions.

  

- [**V2TIMMessageManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_message_tim_manager/V2TIMMessageManager-class.html)

  Provides advanced message processing related interfaces

  

- [**V2TIMOfflinePushManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_offline_push_manager/V2TIMOfflinePushManager-class.html)

  Provide offline push related interface

  

- [**V2TIMSignalingManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_signaling_manager/V2TIMSignalingManager-class.html) 

  Provides interfaces related to signaling operations

