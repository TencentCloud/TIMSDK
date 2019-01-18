本文主要介绍腾讯云 Im SDK 的几个最基本功能的使用方法，阅读此文档有助于您对 IM 的基本使用流程有一个简单的认识。
## 初始化
- ImSDK 一切操作都是由通讯管理器 `TIMManager` 开始，这是一个单例模块，可以用 getInstance() 方法获取。

- sdkAppId 和 accountType 可以在云通讯 [控制台](https://console.cloud.tencent.com/avc) 创建应用后获取到。

```
//初始化 SDK 基本配置
TIMSdkConfig *sdkConfig = [[TIMSdkConfig alloc] init];
sdkConfig.sdkAppId = 123456789;
sdkConfig.accountType = @"123";
sdkConfig.disableLogPrint = NO; // 是否允许log打印
sdkConfig.logLevel = TIM_LOG_DEBUG; //Log输出级别（debug级别会很多）
sdkConfig.logPath =  logPath; //Log文件存放在哪里？
[[TIMManager sharedInstance] initSdk:sdkConfig];
```

## 登录
- 用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供 `identifier`、[`userSig`](https://cloud.tencent.com/document/product/269/1507)。

- 登录为异步过程，通过回调函数返回是否成功，成功后方能进行后续操作。登录成功或者失败后使用闭包 `succ` 和 `fail` 进行回调。

```
TIMLoginParam * login_param = [[TIMLoginParam alloc ]init];
// identifier 为用户名，userSig 为用户登录凭证
// appidAt3rd 在私有帐号情况下，填写与 sdkAppId 一样
login_param.identifier = @"iOS_001";
login_param.userSig = @"usersig";
login_param.appidAt3rd = @"123456";
[[TIMManager sharedInstance] login: login_param succ:^(){
      NSLog(@"Login Succ");
} fail:^(int code, NSString * err) {
      NSLog(@"Login Failed: %d->%@", code, err);
}];
```
- **onForceOffline**
如果此用户在其他终端被踢，登录将会失败，返回错误码（`ERR_IMSDK_KICKED_BY_OTHERS：6208`），如果用户被踢了，请务必用 Alert 等提示窗提示用户，关于被踢的详细描述，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/9148#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。

![](https://main.qcloudimg.com/raw/e31ae59752f736b78be3dcf1578ff64b.png)

- **onUserSigExpired**
每一个 userSig 都有一个过期时间，如果 userSig 过期，`login` 将会返回 `70001` 错误码，如果您收到这个错误码，可以向您的业务服务器重新请求新的 userSig，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/9148#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。

## 登出

如用户主动注销或需要进行用户的切换，则需要调用注销操作。
```
[[TIMManager sharedInstance] logout:^() {
     NSLog(@"logout succ");
} fail:^(int code, NSString * err) {
     NSLog(@"logout fail: code=%d err=%@", code, err);
}];
```
> !在需要切换帐号时，需要 `logout` 回调成功或者失败后才能再次 `login`，否则 `login`可能会失败。

## 消息发送

### 会话获取

会话是指面向一个人或者一个群组的对话，通过与单个人或群组之间会话收发消息，发消息时首先需要先获取会话，获取会话需要指定会话类型（群组或者单聊），以及会话对方标志（对方帐号或者群号）。获取会话由 `getConversation` 实现。

**获取对方 `identifier` 为『iOS-001』的单聊会话示例： **

```
TIMConversation * c2c_conversation = [[TIMManager sharedInstance] getConversation:TIM_C2C receiver:@"iOS-001"];
```

**获取群组 ID 为『TGID1JYSZEAEQ』的群聊会话示例：** 

```
TIMConversation * grp_conversation = [[TIMManager sharedInstance] getConversation:TIM_GROUP receiver:@"TGID1JYSZEAEQ"];
```

### 消息发送

ImSDK 中的每一条消息都是一个 `TIMMessage` 对象， 一条完整的 `TIMMessage` 消息可以包含多个 `TIMElem` 单元，每个 `TIMElem` 单元可以是文本，也可以是图片，也就是说每一条消息可包含多个文本、多张图片、以及其他类型的单元。

![](//mccdn.qcloud.com/static/img/7226ab79d4294cc53980c888892f5c6d/image.png)

```
//构造一条消息并添加一个文本内容
TIMTextElem * text_elem = [[TIMTextElem alloc] init];
[text_elem setText:@"this is a text message"];
TIMMessage * msg = [[TIMMessage alloc] init];
[msg addElem:text_elem];

//发送消息
[conversation sendMessage:msg succ:^(){
    NSLog(@"SendMsg Succ");
}fail:^(int code, NSString * err) {
    NSLog(@"SendMsg Failed:%d->%@", code, err);
}];
```

> 失败回调中，code 表示错误码，具体可参阅 [错误码表](https://cloud.tencent.com/document/product/269/1671)。

## 消息接收
在多数情况下，用户需要感知新消息的通知，这时只需注册新消息通知回调 `TIMMessageListener`，在用户登录状态下，会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知。

```
//设置消息监听器，收到新消息时，通过此监听器回调
TIMMessageListenerImpl * impl = [[TIMMessageListenerImpl alloc] init];
[[TIMManager sharedInstance] addMessageListener:impl];

//收到新消息
- (void)onNewMessage:(NSArray*) msgs {
      NSLog(@"NewMessages: %@", msgs);
}
```
**更多消息接收操作请参考 [消息收发](https://cloud.tencent.com/document/product/269/9150)**

## 群组管理
IM 云通讯有多种群组类型，其特点以及限制因素可参考 [群组系统](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)，群组使用唯一 ID 标识，通过群组 ID 可以进行不同操作，其中群组相关操作都由 `TIMGroupManager` 实现，需要用户登录成功后操作。

| 类型 | 说明 |
|:---------:|:---------|
| 私有群（Private）| 适用于较为私密的聊天场景，群组资料不公开，只能通过邀请的方式加入，类似于微信群。|
| 公开群（Public） | 适用于公开群组，具有较为严格的管理机制、准入机制，类似于 QQ 群。|
| 聊天室（ChatRoom）| 群成员可以随意进出。|
| 直播聊天室（AVChatRoom）|与聊天室相似，但群成员人数无上限；支持以游客身份（不登录）接收消息。|
| 在线成员广播大群（BChatRoom）|适用于需要向全体在线用户推送消息的场景。 |

### 创建群组

以下示例创建一个私有群组，并且把用户『iOS_002』拉入群组。 **示例：**
 
```
// 添加一个用户 iOS_002
NSMutableArray * members = [[NSMutableArray alloc] init];
[members addObject:@"iOS_002"];

//创建群组
[[TIMGroupManager sharedInstance] createPrivateGroup:members groupName:@"GroupName" succ:^(NSString * group) {
   NSLog(@"create group succ, sid=%@", group);
} fail:^(int code, NSString* err) {
   NSLog(@"failed code: %d %@", code, err);
}];
```

**更多群组操作请参考 [群组管理](https://cloud.tencent.com/document/product/269/9152)**

### 群组消息 
群组消息与 C2C （单聊）消息相同，仅在获取 `Conversation` 时的会话类型不同，可参照 [消息发送](/doc/product/269/9150#.E6.B6.88.E6.81.AF.E5.8F.91.E9.80.81) 部分。



