
# 目录介绍：
└─ fluter 
   ├─ IMSDK                     // SDK 目录
   ├─ Demo                      // Demo 目录
   │  ├─im_api_example          // 接口测试Demo（主要进行SDK的测试）
   │  ├─TencentIMFlutterDemo    // IM测试Demo（进行功能体验）
   └─ README.md                 // 现在你就在读这个文件呀～


# 项目一、Flutter IM 的体验 Demo（TencentIMFlutterDemo）
接下来介绍如何快速跑通即时通信 Flutter IM 的体验 Demo（对应TencentIMFlutterDemo）。
- #### （1）在腾讯云即时通信IM控制台创建应用
使用Demo前请先配置`sdkappid`,`secret`,需到[腾讯云控制台](https://cloud.tencent.com/product/im)注册账号，创建应用.拿到所需的sdkappid和secret

- #### （2）运行demo

```
flutter run --dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID） --dart-define=KEY=xxxx（xxxx是你自己申请的密钥）
```
如需使用手机验证码登陆请再添加：--dart-define=ISPRODUCT_ENV=true

- #### 修改配置（可选）
目录：/example/lib/utils/config
这里配置了环境变量，建议通过运行环境时添加对应配置信息

- ### 若要使用vs的调试工具
请在launch.json中添加环境参数
```
"args": [
            "--dart-define=SDK_APPID=xxxx（xxxx是你自己申请的sdkappID）",
            "--dart-define=KEY=xxxx（xxxx是你自己申请的密钥）"
        ]
```

PS: 若出现白屏无法启动的情况，可能是SDK_APPID填写错误 请检查

[项目仓库点这里](https://cloud.tencent.com/product/im)


# 项目二、Flutter IM 的SDK（IMSDK）
## 基本使用用例

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

  




# 项目三、IM的接口测试Demo（im_api_example） 
该项目用于构建Flutter api demo, 包含相关api 的使用方式，便于用户使用及测试。

### Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 如何使用
- 根据Flutter [官方文档](https://flutter.dev/docs/get-started/install)配置对应的环境.
- 运行该项目， 如何运行Flutter项目可参考[文档](https://flutter.dev/docs/get-started/codelab).
- 调用相关Api前请先配置`sdkappid`,`secret`,需到[腾讯云控制台](https://cloud.tencent.com/product/im)注册账号，并创建应用.
- 在基础模块中，初始化SDK(initSDK), 并且登录(login)。

## QA
- **如何设置自定义字段**

自定义字段为满足于用户更多的使用场景。IM提供了 `用户自定义字段`， `好友自定义字段`， `群自定义字段` 和 `群成员自定义字段`， 首先需要到控制台配置对应的自定义字段名，后可调用对应的API(`setSelfInfo`, `setGourpInfo`, `setGroupMemberInfo`, `setFriendInfo`)去设置该字段值.

由于创建用户自定义字段和好友自定义字段时，控制台会自动加上 `Tag_Profile_Custom_` 和 `Tag_SNS_Custom_` 前缀，当我们调用API 设置该值时，不需要加上该前缀。 例如在控制台好友自定义字段为`Tag_SNS_Custom_test`, 当我们调用API 时字段名只需要设置为`test` 即可。

PS：如果需自己调试SDK，在pubspec.yaml修改tencent_im_sdk_plugin路径即可
例：
```
  tencent_im_sdk_plugin: 
    path: /Users/xingchenhe/Documents/work/Flutter/TencentImSDKPlugin
```

