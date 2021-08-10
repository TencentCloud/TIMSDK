#### 基本使用用例

- 初始化

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
//获取腾讯即时通信IM manager;
V2TIMManager timManager = TencentImSDKPlugin.v2TIMManager;
//初始化SDK
V2TimValueCallback<bool> initRes = await timManager.initSDK(
      sdkAppID: sdkAppID,//填入在控制台上申请的sdkappid
      loglevel: LogLevel.V2TIM_LOG_DEBUG,
      listener: initLisener,
);

//V2TimValueCallback 返回的所有数据结构
int code initRes.code；
String desc = initRes.desc;
bool data = initRes.data;//为V2TimValueCallback实例化时接收的泛型。

if(initRes.code == 0){
  //初始化成功
 	//以下监听可按需设置,为防止遗漏消息，请在登录前设置监听。
  //简单监听
  timManager.addSimpleMsgListener(
    listener: simpleMsgListener,
  );
  //群组监听
  timManager.setGroupListener(
    listener: groupListener,
  );
  //高级消息监听
  timManager.getMessageManager().addAdvancedMsgListener(
    listener: advancedMsgListener,
  );
  //关系链监听
  timManager.getFriendshipManager().setFriendListener(
    listener: friendListener,
  );
  //会话监听
  timManager.getConversationManager().setConversationListener(
    listener: conversationListener,
  );
  //设置信令相关监听
  timManager.getSignalingManager().addSignalingListener(
    listener: signalingListener,
  );
 V2TimCallback loginRes await timManager.login(
   userID: userId,
   userSig: userSig,
  );
  //V2TimCallback 返回的所有数据结构
  int code  = loginRes.code;
  String desc = loginRes.desc;
  
  if(code==0){
    //登录成功
    //发送消息
    timManager.sendC2CTextMessage(text:text,userID:userID,)
    //....
    //这里可调用SDK的任何方法。
  }else{
    //登录失败
    print(desc);
  }
}else{
  //初始化失败
}

```



**Managers**

- [**V2TIMManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_manager/V2TIMManager-class.html)

  群组高级接口，包含了群组的高级功能，例如群成员邀请、非群成员申请进群等操作接口。

  

- [**V2TIMFriendshipManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_friendship_manager/V2TIMFriendshipManager-class.html)

  关系链接口，包含了好友的添加和删除，黑名单的添加和删除等逻辑。

  

- [**V2TIMGroupManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_group_manager/V2TIMGroupManager-class.html)

  群组高级接口，包含了群组的高级功能，例如群成员邀请、非群成员申请进群等操作接口。

  

- [**V2TIMConversationManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_conversation_manager/V2TIMConversationManager-class.html)

  会话接口，包含了会话的获取，删除和更新的逻辑。

  

- [**V2TIMMessageManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_message_tim_manager/V2TIMMessageManager-class.html)

  提供高级消息处理相关接口

  

- [**V2TIMOfflinePushManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_offline_push_manager/V2TIMOfflinePushManager-class.html)

  提供离线推送相关的接口

  

- [**V2TIMSignalingManager**](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_signaling_manager/V2TIMSignalingManager-class.html) 

  提供了信令操作相关的接口

  