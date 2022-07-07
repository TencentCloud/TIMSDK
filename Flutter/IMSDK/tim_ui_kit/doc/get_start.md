[toc]
通过阅读本文，您可以了解集成Flutter SDK的方法。

## 环境要求

|   | 版本 |
|---------|---------|
| Flutter | IM SDK最低要求Flutter 2.2.0版本，TUIKit集成组件库最低要求Flutter 2.8.1版本。|
|Android|Android Studio 3.5及以上版本，App 要求 Android 4.1及以上版本设备。|
|iOS|Xcode 11.0及以上版本，请确保您的项目已设置有效的开发者签名。|

## 前提条件

1. 您已 [注册腾讯云](https://cloud.tencent.com/document/product/378/17985) 帐号，并完成 [实名认证](https://cloud.tencent.com/document/product/378/3629)。
2. 参照 [创建并升级应用](https://cloud.tencent.com/document/product/269/32577) 创建应用，并记录好`SDKAppID`。

[](id:part1)

## Part1：创建测试用户

在[IM控制台](https://console.cloud.tencent.com/im)选择您的应用，在左侧导航栏依次点击 **辅助工具**->**UserSig 生成&校验** ，创建两个 UserID 及其对应的 UserSig，复制`UserID`、`签名（Key）`、`UserSig`这三个，后续登录时会用到。

>? 该账户仅限开发测试使用。应用上线前，正确的 `UserSig` 签发方式是由服务器端生成，并提供面向 App 的接口，在需要 `UserSig` 时由App向业务服务器发起请求获取动态 `UserSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

![](https://main.qcloudimg.com/raw/8315da2551bf35ec85ce10fd31fe2f52.png)

[](id:part2)

## Part2：选择合适的方案集成Flutter SDK


IM提供了三种方式来集成，您可以选择最合适的方案来集成：
|   | 适用场景 |
|---------|---------|
| [使用DEMO](#part3) | IM demo是一个完整的聊天app，代码已开源，如果您需要实现聊天类似场景，可以使用demo进行二次开发。 [点此体验demo](https://cloud.tencent.com/document/product/269/36852) |
| [含UI集成](#part4) | IM的UI组件库`TUIKit`提供了通用的 UI 组件，例如会话列表、聊天界面和联系人列表等，开发者可根据实际业务需求通过该组件库快速地搭建自定义 IM 应用。**推荐优先使用该方案** |
| [自实现UI集成](#part5) | 如果TUIKit不能满足您应用的界面需求，或者您需要比较多的定制，可以使用该方案。 |


为帮助您更好的理解IM SDK的各API，[我们还提供了API Example](https://github.com/TencentCloud/TIMSDK/tree/master/Flutter/IMSDK/im-flutter-plugin/tencent_im_sdk_plugin/example)，演示各API的调用及监听的触发。


[](id:part3)

## Part3：使用DEMO

### 跑通DEMO

1. 下载demo源码、安装依赖

```shell
#clone 代码
git clone https://github.com/TencentCloud/TIMSDK.git

#进入flutter的demo目录
cd TIMSDK/Flutter/Demo/im-flutter-uikit

#安装依赖
flutter pub get
```

2. 运行demo项目：

```shell
#启动demo项目，请替换SDK_APPID、KEY两个参数
flutter run --dart-define=SDK_APPID={YOUR_SDKAPPID} --dart-define=ISPRODUCT_ENV=false --dart-define=KEY={YOUR_KEY}
```

>?
>
>- `--dart-define=SDK_APPID={YOUR_SDKAPPID}` 其中`{YOUR_SDKAPPID}`需替换成您自己应用的 SDKAppID。
>- `--dart-define=ISPRODUCT_ENV=false` 对开发生产环境做判断，如您是开发环境请用 false。
>- `--dart-define=KEY={YOUR_KEY}` 其中`{YOUR_KEY}`需替换成 [Part1：创建测试用户](#part1) 中的`密钥（Key）`信息。
>

#### 也可以使用 IDE 运行：（可选步骤）

<dx-tabs>
::: Android 平台[](id:android)
1. 在 Android Studio 打开 discuss/andorid 目录。
![](https://qcloudimg.tencent-cloud.cn/raw/6516f9b17c58915c4ebc93c5c8829831.png)
2. 启动一个 Android 的模拟器，单击 **Build And Run**，Demo 可以运行起来。您可以随机输入一个 UserID（数字字母组合）。
>?UI 可能会有部分调整更新，请以最新版为准。
:::
::: iOS 平台[](id:ios)
1. 打开 Xcode，打开文件 discuss/ios/Runner.xcodeproj：
![](https://qcloudimg.tencent-cloud.cn/raw/6d74814ba9bce54c7439e8b3cea53e73.png)
2. 连接 iPhone 真机，单击 **Build And Run**，iOS 工程等待编译完成，会有新窗口弹出 Xcode 工程。
3. 打开 iOS 工程，设置主 Target 的 Signing & Capabilities（需要苹果开发者帐号），让项目可以在 iPhone 真机上运行。
4. 启动项目，在真机上进行 Demo 的调试。
![](https://qcloudimg.tencent-cloud.cn/raw/3fe6bbac88bb21ad7a7822bb297793b3.png)
:::
</dx-tabs>

#### DEMO代码结构概览

>? 我们DEMO的UI及业务逻辑部分，使用Flutter TUIKit。DEMO层本身仅用于构建APP，处理导航跳转及调用实例化TUIKit中各个组件。


|  文件夹  | 介绍 |
|---------|---------|
| lib | 程序核心目录 |
| lib/i18n | 国际化相关代码。这里的国际化，不包含TUIKit本身的国际化能力和国际化词条，您可按需引入 |
| lib/src | 项目主体目录 |
| lib/src/pages | 本DEMO几个重点导航页。项目初始化完成后，由 `app.dart` 负责展示加载动画，并判断登陆态，将用户引导至 `login.dart` 或 `home_page.dart`。用户登录后，会将登陆信息通过 `shared_preference` 插件，存储至本地。以后每次启动应用，若在本地发现原来的登录信息，则自动使用该信息进行登录，若无或登录失败，则引导至登录页。自动登录过程中，用户还在 `app.dart` ，可看到加载动画。`home_page.dart`含一个底部Tab，支撑本demo的四个主功能页的切换。 |
| lib/utils | 一些工具函数类 |


基本上，`lib/src` 内每个dart文件引入了一个TUIKit组件，在文件内，实例化组件后，即可渲染页面。

主要文件如下：


|  lib/src 主要文件  | 文件介绍 |
|---------|---------|
| add_friend.dart | 申请添加好友页面，使用 `TIMUIKitAddFriend` 组件|
| add_group.dart | 申请入群页面，使用 `TIMUIKitAddGroup` 组件|
| blacklist.dart| 黑名单列表页面，使用 `TIMUIKitBlackList` 组件 |
| chat.dart | 主聊天页面，使用全套TUIKit聊天能力，使用 `TIMUIKitChat` 组件 |
| chatv2.dart | 主聊天页面，使用原子化能力，使用 `TIMUIKitChat` 组件 |
| contact.dart | 联系人页面 ，使用 `TIMUIKitContact` 组件|
| conversation.dart | 会话列表界面，使用 `TIMUIKitConversation` 组件 |
| create_group.dart | 发起群聊页面，纯Demo实现，未使用组件 |
| group_application_list.dart | 入群申请列表页面，使用 `TIMUIKitGroupApplicationList` 组件 |
| group_list.dart | 群列表页面，使用 `TIMUIKitGroup` 组件  |
| group_profile.dart | 群资料及群管理页面，使用 `TIMUIKitGroupProfile` 组件 |
| newContact.dart | 联系人好友申请页面，使用 `TIMUIKitNewContact` 组件 |
| routes.dart | Demo的路由，导航至登录页 `login.dart` 或主页面 `home_page.dart`。 |
| search.dart | 全局搜索及会话内搜索页面，使用 `TIMUIKitSearch`（全局搜索） 及 `TIMUIKitSearchMsgDetail`（会话内搜索） 组件 |
| user_profile.dart | 用户信息及关系链维护页面，使用 `TIMUIKitProfile` 组件|

大部分TUIKit组件需要传入导航跳转方法，因此需要DEMO层处理 `Navigator` 。

以上介绍了我们的DEMO，您可以直接直接修改它二次开发，或参照它实现您的业务需求。

[](id:part4)

## Part4：含UI集成，使用TUIKit组件库，半天完成IM能力植入

TUIKit 是基于腾讯云 IM SDK 的一款 UI 组件库，它提供了一些通用的 UI 组件，例如会话列表、聊天界面和联系人列表等，开发者可根据实际业务需求通过该组件库快速地搭建自定义 IM 应用。[点此查看TUIKit详细介绍](https://cloud.tencent.com/document/product/269/70746)

### 前提条件

您已经完成创建Flutter项目，或有可以基于的Flutter项目。

### 接入步骤

#### 安装IM TUIkit

我们的TUIkit已经内含IM SDK，因此仅需安装`tim_ui_kit`，不需要再安装基础im sdk。

```shell
#在命令行执行：
flutter pub add tim_ui_kit
```

#### 初始化

在您应用启动时，初始化TUIKit。

请务必保证先执行 `TIMUIKitCore.getInstance()` ，再调用初始化函数 `init()` ，并将您的[sdkAppID]传入。

```dart
/// main.dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  @override
 void initState() {
   _coreInstance.init(
     sdkAppID: 0, // Replace 0 with the SDKAppID of your IM application when integrating
     loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
     listener: V2TimSDKListener());    
   super.initState();
 }
}
```

#### 登录测试账户

此时，您可以使用最开始的时候，在控制台生成的测试账户，完成登录验证。

调用`_coreInstance.login`方法，登录一个测试账户。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
_coreInstance.login(userID: userID, userSig: userSig);
```

>? 该账户仅限开发测试使用。应用上线前，正确的 `UserSig` 签发方式是由服务器端生成，并提供面向 App 的接口，在需要 `UserSig` 时由App向业务服务器发起请求获取动态 `UserSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

#### 实现：会话列表页面

您可以以会话列表作为您的IM功能首页，其涵盖了与所有有聊天记录的用户的会话。

![wecom-temp-320803-502538740c22124e9f3e0efc1d5a10ee](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/wecom-temp-320803-502538740c22124e9f3e0efc1d5a10ee.jpg)

请创建一个 `Conversation` 类，`body` 中使用 `TIMUIKitConversation` 组件，渲染会话列表。

您仅需传入一个 `onTapItem` 事件的处理函数，用于跳转至具体会话聊天页的导航。关于 `Chat` 类，会在下一步讲解。

```dart
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class Conversation extends StatelessWidget {
const Conversation({Key? key}) : super(key: key);
@override
Widget build(BuildContext context) {
return Scaffold(
  appBar: AppBar(
    title: const Text(
      "Message",
      style: TextStyle(color: Colors.black),
    ),
  ),
  body: TIMUIKitConversation(
    onTapItem: (selectedConv) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Chat(
              selectedConversation: selectedConv,
            ),
          ));
    },
  ),
);
}
}
```

#### 实现：会话聊天页面

该页面由顶部主体聊天历史记录及底部发送消息模块组成。

![20220701202206](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/20220701202206.png)

请创建一个 `Chat` 类，`body` 中使用 `TIMUIKitChat` 组件，渲染聊天页面。

您最好传入一个 `onTapAvatar` 事件的处理函数，用于跳转至联系人的详细信息页。关于 `UserProfile` 类，会在下一步讲解。

```dart
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class Chat extends StatelessWidget {
final V2TimConversation selectedConversation;
const Chat({Key? key, required this.selectedConversation}) : super(key: key);
String? _getConvID() {
return selectedConversation.type == 1
    ? selectedConversation.userID
    : selectedConversation.groupID;
}
@override
Widget build(BuildContext context) {
return TIMUIKitChat(
  conversationID: _getConvID() ?? '', // groupID or UserID
  conversationType: selectedConversation.type ?? 1, // Conversation type
  conversationShowName: selectedConversation.showName ?? "", // Conversation display name
  onTapAvatar: (_) {
        Navigator.push(
            context,
            MaterialPageRoute(
             builder: (context) => UserProfile(userID: userID),
        ));
  }, // Callback for the clicking of the message sender profile photo. This callback can be used with `TIMUIKitProfile`.
);
}
```

#### 实现：用户详情页面

该页面默认，可在只传入一个 `userID` 的情况下，自动根据是否是好友，生成用户详情页。

请创建一个 `UserProfile` 类，`body` 中使用 `TIMUIKitProfile` 组件，渲染用户详情及关系链页面。

>? 如果您希望自定义该页面，请优先考虑使用 `profileWidgetBuilder` 传入需自定义的profile组件并配合 `profileWidgetsOrder` 确定纵向排列顺序；如果无法满足，才可使用 `builder` 。

![wecom-temp-215357-bdcdaa6f33a21573e0a2785a8cff72c0](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/wecom-temp-215357-bdcdaa6f33a21573e0a2785a8cff72c0.jpg)

```dart
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class UserProfile extends StatelessWidget {
    final String userID;
    const UserProfile({required this.userID, Key? key}) : super(key: key);

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       title: const Text(
         "Message",
         style: TextStyle(color: Colors.black),
       ),
     ),
     body: TIMUIKitProfile(
          userID: widget.userID,
     ),
    );
  }
}
```

此时，您的应用已经可以完成消息收发，管理好友关系，展示用户详情及展示会话列表。

#### 更多能力

您还可以继续使用以下TUIKit插件快速实现完整IM功能。

[TIMUIKitContact](https://intl.cloud.tencent.com/document/product/1047/46297#timuikitcontact): 联系人列表页面。

[TIMUIKitGroupProfile](https://intl.cloud.tencent.com/document/product/1047/46297#timuikitgroupprofile): 群资料页面，使用方式与 `TIMUIKitProfile` 基本一致。

[TIMUIKitGroup](https://intl.cloud.tencent.com/document/product/1047/46297#timuikitgroup): 群列表界面。

[TIMUIKitBlackList](https://intl.cloud.tencent.com/document/product/1047/46297#timuikitblacklist): 黑名单列表界面。

[TIMUIKitNewContact](https://intl.cloud.tencent.com/document/product/1047/46297#timuikitnewcontact): 联系人（好友）申请列表。如需在外部显示小红点，可使用 `TIMUIKitUnreadCount` 小红点组件，其会自动挂载监听。

[TIMUIKitSearch](https://pub.dev/documentation/tim_ui_kit/latest/ui_views_TIMUIKitSearch_tim_uikit_search/TIMUIKitSearch-class.html): 搜索组件，支持全局搜索联系人/群组/聊天记录，也支持在特定会话中搜索聊天记录。两种模式取决于是否传入 `conversation`。

详细UI插件指南[可参考本文档](https://cloud.tencent.com/document/product/269/70747#timuikitcontact)或[插件README](https://pub.dev/packages/tim_ui_kit)。

[](id:part5)

## Part5：自实现UI集成

### 前提条件

您已经完成创建Flutter项目，或有可以基于的Flutter项目。

### 接入步骤

#### 安装IM SDK

[本节详细文档](https://cloud.tencent.com/document/product/269/75286)

使用如下命令，安装Flutter IM SDK最新版本。

在命令行执行：

```shell
flutter pub add tencent_im_sdk_plugin
```

#### 完成SDK初始化

[本节详细文档](https://cloud.tencent.com/document/product/269/75293)

调用`initSDK`，完成SDK初始化。

将您的[sdkAppID]传入。

```Dart
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
    TencentImSDKPlugin.v2TIMManager.initSDK(
    sdkAppID: 0, // Replace 0 with the SDKAppID of your IM application when integrating
    loglevel: LogLevelEnum.V2TIM_LOG_DEBUG, // Log
    listener: V2TimSDKListener(),
  );
```

在本步骤，你可以针对IM SDK挂载一些监听，主要包括网络状态及用户信息变更等，[详情可参考该文档](https://pub.dev/documentation/tencent_im_sdk_plugin_platform_interface/latest/enum_V2TimSDKListener/V2TimSDKListener-class.html)。

#### 登录测试账户

[本节详细文档](https://cloud.tencent.com/document/product/269/75296)

此时，您可以使用最开始的时候，在控制台生成的测试账户，完成登录验证。

调用`TencentImSDKPlugin.v2TIMManager.login`方法，登录一个测试账户。

当返回值`res.code`为0时，登录成功。

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
 V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.login(
    userID: userID,
    userSig: userSig, 
  );
```

>? 该账户仅限开发测试使用。应用上线前，正确的 `UserSig` 签发方式是将 `UserSig` 的计算代码集成到您的服务端，并提供面向 App 的接口，在需要 `UserSig` 时由您的 App 向业务服务器发起请求获取动态 `UserSig`。更多详情请参见 [服务端生成 UserSig](https://cloud.tencent.com/document/product/269/32688#GeneratingdynamicUserSig)。

#### 发送消息

[本节详细文档](https://cloud.tencent.com/document/product/269/75317)

此处以发送文本消息举例，其流程为：

1. 调用 `createTextMessage(String)`创建一个文本消息。
2. 根据其返回值，拿到消息ID。
3. 调用 `sendMessage()` 发送该ID的消息。`receiver`可填入您此前创建的另一个测试账户ID。发送单聊消息无需填入`groupID`。

代码示例：

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
      await TencentImSDKPlugin.v2TIMManager
          .getMessageManager()
          .createTextMessage(text: "The text to create");
          
String id = createMessage.data!.id!; // The message creation ID 

V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
      .getMessageManager()
      .sendMessage(
          id: id, // Pass in the message creation ID to
          receiver: "The userID of the destination user",
          groupID: "The groupID of the destination group",
          );
```

> 如果发送失败，可能是由于您的sdkAppID不支持陌生人发送消息，您可至控制台开启，用于测试。
>
> [请点击此链接](https://console.cloud.tencent.com/im/login-message)，关闭[好友关系链检查]。

#### 获取会话列表

[本节详细文档](https://cloud.tencent.com/document/product/269/75368)

在上一个步骤中，完成发送测试消息，现在可登录另一个测试账户，拉取会话列表。

![wecom-temp-320803-502538740c22124e9f3e0efc1d5a10ee](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/wecom-temp-320803-502538740c22124e9f3e0efc1d5a10ee.jpg)

获取会话列表的方式有两种：

1. 监听长连接回调，实时更新会话列表。
2. 请求API，根据分页一次性获取会话列表。

常见应用场景为：

在启动应用程序后立即获取对话列表，然后监听长连接以实时更新对话列表的变化。

##### 一次性请求会话列表

为了获取会话列表，需要维护`nextSeq`，记录当前位置。

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

getConversationList() async {
  V2TimValueCallback<V2TimConversationResult> res = await TencentImSDKPlugin
      .v2TIMManager
      .getConversationManager()
      .getConversationList(nextSeq: nextSeq, count: 10);

  V2TimValueCallback<V2TimConversationResult> nextSeq =
      await TencentImSDKPlugin.v2TIMManager
          .getConversationManager()
          .getConversationList(nextSeq: res.data?.nextSeq ?? "0", count: 20);
}
```

此时，你可以看到您在上一步中，使用另一个测试账号，发来消息的会话。

##### 监听长链接实时获取会话列表

您在此步骤中，需要先在SDK上挂载监听，然后处理回调事件，更新UI。

1. 挂载监听。

```dart
await TencentImSDKPlugin.v2TIMManager
      .getConversationManager()
      .setConversationListener(
        listener: new V2TimConversationListener(
          onConversationChanged: (List<V2TimConversation> list){
            _onConversationListChanged(list);
    },
          onNewConversation:(List<V2TimConversation> list){
            _onConversationListChanged(list);
    },
```

2. 处理回调事件，将最新的会话列表展示在界面上。

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

List<V2TimConversation> _conversationList = [];

_onConversationListChanged(List<V2TimConversation> list) {
  for (int element = 0; element < list.length; element++) {
    int index = _conversationList.indexWhere(
        (item) => item!.conversationID == list[element].conversationID);
    if (index > -1) {
      _conversationList.setAll(index, [list[element]]);
    } else {
      _conversationList.add(list[element]);
    }
  }
```

#### 接收消息

[本节详细文档](https://cloud.tencent.com/document/product/269/75320)

通过腾讯云IM Ffltter SDK接收消息有两种方式：

1. 监听长连接回调，实时获取消息变化，更新渲染历史消息列表。
2. 请求API，根据分页一次性获取历史消息。

常见应用场景为：

1. 界面进入新的会话后，首先一次性请求一定数量的历史消息，用于展示历史消息列表。
2. 监听长链接，实时接收新的消息，将其添加进历史消息列表中。

##### 一次性请求历史消息列表

每页拉取的消息数量不能太大，否则会影响拉取速度。建议此处设置为20左右。

您应该动态记录当前页数，用于下一轮请求。

示例代码如下：

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

  V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
      .v2TIMManager
      .getMessageManager()
      .getGroupHistoryMessageList(
        groupID: "groupID",
        count: 20,
        lastMsgID: "",
      );
      
  List<V2TimMessage> msgList = res.data ?? [];
  
  // here you can use msgList to render your message list
    }
```

##### 监听长链接实时获取新消息

历史消息列表初始化后，新消息来自长链接 `V2TimAdvancedMsgListener.onRecvNewMessage`。

`onRecvNewMessage`回调被触发后，您可以按需将新消息添加进历史消息列表中。

绑定监听器示例代码如下：

```dart
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

final adVancesMsgListener = V2TimAdvancedMsgListener(
onRecvNewMessage: (V2TimMessage newMsg) {
  _onReceiveNewMsg(newMsg);
},
/// ... other listeners related to message
);

TencentImSDKPlugin.v2TIMManager
    .getMessageManager()
    .addAdvancedMsgListener(listener: adVancesMsgListener);
```

此时，您已基本完成IM模块开发，可以发送接收消息，也可以进入不同的会话。

您可以继续完成[群组](https://cloud.tencent.com/document/product/269/75697)，[用户资料](https://cloud.tencent.com/document/product/269/75418)，[关系链](https://cloud.tencent.com/document/product/269/75421)，[离线推送](https://cloud.tencent.com/document/product/269/75430)，[本地搜索](https://cloud.tencent.com/document/product/269/75438)等相关功能开发。

详情可查看[自实现UI集成SDK文档](https://cloud.tencent.com/document/product/269/75260)。

### 常见问题

#### 支持哪些平台？

目前支持 iOS 、Android 和 Web 三个平台，另外 Windows 和 Mac 版正在开发中，敬请期待。

#### Android 单击 Build And Run 报错找不到可用设备？

确保设备没被其他资源占用，或单击 **Build** 生成 APK 包，再拖动进模拟器里运行。

#### iOS 第一次运行报错？

配置运行后，如果报错，可以单击 **Product** > **Clean**，清除产物后重新 Build，或者关闭 Xcode，重新打开后再次 Build。

#### Flutter 环境问题

如您需得知 Flutter 的环境是否存在问题，请运行 Flutter doctor 检测 Flutter 环境是否装好。

#### 使用Flutter自动生成的项目，引入TUIKit后报错

![20220706132722](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/20220706132722.png)

需要在\android\app\src\main\AndroidManifest.xml中进行修改。

打开 `\android\app\src\main\AndroidManifest.xml`，根据下图，补全。

![20220706133714](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/20220706133714.png)

打开 `\android\app\build.gradle`，根据下图，补全 `defaultConfig`。

![20220706133740](https://tuikit-1251787278.cos.ap-guangzhou.myqcloud.com/20220706133740.png)

### 联系我们

如果您在接入使用过程中有任何疑问，请加入QQ群：788910197 咨询。
