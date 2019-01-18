本文主要介绍腾讯云 Im SDK 的几个最基本功能的使用方法，阅读此文档有助于您对 IM 的基本使用流程有一个简单的认识。
## 初始化
- ImSDK 一切操作都是由通讯管理器 `TIMManager` 开始，这是一个单例模块，可以用 getInstance() 方法获取。

- sdkAppId 可以在云通讯 [控制台](https://console.cloud.tencent.com/avc) 创建应用后获取到。

![](https://main.qcloudimg.com/raw/826b903373db7cff2adebec6fa3a40a8.png)

```
//初始化 SDK 基本配置
TIMSdkConfig config = new TIMSdkConfig(sdkAppId) 
	.setAccoutType(accountType)
        .enableLogPrint(true)              // 是否在控制台打印Log?
        .setLogLevel(TIMLogLevel.DEBUG)    // Log输出级别（debug级别会很多）
        .setLogPath(Environment.getExternalStorageDirectory().getPath() + "/justfortest/") 
				// Log文件存放在哪里？

//初始化 SDK
TIMManager.getInstance().init(getApplicationContext(), config);
```



## 登录
- 用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供 `identifier`、[`userSig`](https://cloud.tencent.com/document/product/269/1507)。

- 登录为异步过程，通过回调函数返回是否成功，成功后方能进行后续操作。登录成功或者失败后使用闭包 `succ` 和 `fail` 进行回调。

```
// identifier为用户名，userSig 为用户登录凭证
TIMManager.getInstance().login(identifier, userSig, new TIMCallBack() {
    @Override
    public void onError(int code, String desc) {
        //错误码 code 和错误描述 desc，可用于定位请求失败原因
        //错误码 code 列表请参见错误码表
        Log.d(tag, "login failed. code: " + code + " errmsg: " + desc);
    }

    @Override
    public void onSuccess() {
        Log.d(tag, "login succ");
    }
});
```

- **onForceOffline**
如果此用户在其他终端被踢，登录将会失败，返回错误码（`ERR_IMSDK_KICKED_BY_OTHERS：6208`），如果用户被踢了，请务必用 Alert 等提示窗提示用户，关于被踢的详细描述，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/9229#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。

![](https://main.qcloudimg.com/raw/8138b665071522c29ade9de9424ebd51.png)

- **onUserSigExpired**
每一个 userSig 都有一个过期时间，如果 userSig 过期，`login` 将会返回 `70001` 错误码，如果您收到这个错误码，可以向您的业务服务器重新请求新的 userSig，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/9229#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。

## 登出

如用户主动注销或需要进行用户的切换，则需要调用注销操作。

```
//登出
TIMManager.getInstance().logout(new TIMCallBack() {
    @Override
    public void onError(int code, String desc) {

        //错误码 code 和错误描述 desc，可用于定位请求失败原因
        //错误码 code 列表请参见错误码表
        Log.d(tag, "logout failed. code: " + code + " errmsg: " + desc);
    }

    @Override
    public void onSuccess() {
        //登出成功
    }
});
```

> !在需要切换帐号时，需要 `logout` 回调成功或者失败后才能再次 `login`，否则 `login`可能会失败。


## 消息发送

### 会话获取

会话是指面向一个人或者一个群组的对话，通过与单个人或群组之间会话收发消息，发消息时首先需要先获取会话，获取会话需要指定会话类型（群组或者单聊），以及会话对方标志（对方帐号或者群号）。获取会话由 `getConversation` 实现。

- **获取对方 `identifier` 为『test_user』的单聊会话示例：** 

```
//获取单聊会话
String peer = "test_user";  //获取与用户 "test_user" 的会话
conversation = TIMManager.getInstance().getConversation(
        TIMConversationType.C2C,    //会话类型：单聊
        peer);                      //会话对方用户帐号//对方ID
```

- **获取群组 ID 为『test_group』的群聊会话示例：** 

```
//获取群聊会话
String groupId = "test_group";  //获取与群组 "test_group" 的会话
conversation = TIMManager.getInstance().getConversation(
        TIMConversationType.Group,      //会话类型：群组
        groupId);                       //群组 ID
```

### 消息发送

ImSDK 中的每一条消息都是一个 `TIMMessage` 对象， 一条完整的 `TIMMessage` 消息可以包含多个 `TIMElem` 单元，每个 `TIMElem` 单元可以是文本，也可以是图片，也就是说每一条消息可包含多个文本、多张图片、以及其他类型的单元。

![](https://main.qcloudimg.com/raw/2841a6842e0f46d2ac71eae1e5a13e05.png)

```
//构造一条消息并添加一个文本内容
TIMMessage msg = new TIMMessage();
TIMTextElem elem = new TIMTextElem();
elem.setText("A new test msg!");
msg.addElement(elem);

//发送消息
conversation.sendMessage(msg, new TIMValueCallBack<TIMMessage>() {
    @Override
    public void onError(int code, String desc) {//发送消息失败
        //错误码 code 和错误描述 desc，可用于定位请求失败原因
        Log.d(tag, "send message failed. code: " + code + " errmsg: " + desc);
    }

    @Override
    public void onSuccess(TIMMessage msg) {//发送消息成功
        Log.e(tag, "SendMsg ok");
    }
});
```

> 失败回调中，code 表示错误码，具体可参阅 [错误码表](https://cloud.tencent.com/document/product/269/1671)。


## 消息接收
在多数情况下，用户需要感知新消息的通知，这时只需注册新消息通知回调 `TIMMessageListener`，在用户登录状态下，会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知。

```
//设置消息监听器，收到新消息时，通过此监听器回调
TIMManager.getInstance().addMessageListener(new TIMMessageListener() {//消息监听器
    @Override
    public boolean onNewMessages(List<TIMMessage> msgs) {//收到新消息
        //消息的内容解析请参考消息收发文档中的消息解析说明
        return true; //返回true将终止回调链，不再调用下一个新消息监听器
    }
});
```

> 更多消息接收操作请参考 [消息收发](https://cloud.tencent.com/document/product/269/9232)。

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

以下示例创建一个叫做 “test_group” 的公开群组，并且把用户『cat』拉入群组。 

```
//创建公开群
TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam("Public", "test_group");
//指定群简介
param.setIntroduction("hello world");
//指定群公告
param.setNotification("welcome to our group");

//添加群成员“cat”
List<TIMGroupMemberInfo> infos = new ArrayList<TIMGroupMemberInfo>();
TIMGroupMemberInfo member = new TIMGroupMemberInfo();
member.setUser("cat");
member.setRoleType(TIMGroupMemberRoleType.Normal);
infos.add(member);        
param.setMembers(infos);

//创建群组
TIMGroupManager.getInstance().createGroup(param, new TIMValueCallBack<String>() {
    @Override
    public void onError(int code, String desc) {
        Log.d(tag, "create group failed. code: " + code + " errmsg: " + desc);
    }

    @Override
    public void onSuccess(String s) {
        Log.d(tag, "create group succ, groupId:" + s);
    }
});
```

> 更多群组操作请参考 [群组管理](https://cloud.tencent.com/document/product/269/9236)。


### 群组消息 
群组消息与 C2C （单聊）消息相同，仅在获取 `Conversation` 时需要将会话类型改为 `TIMConversationType.Group`，可参照 [消息发送](https://cloud.tencent.com/document/product/269/9232) 部分。


