本文主要介绍腾讯云 Im SDK 的几个最基本功能的使用方法，阅读此文档有助于您对 IM 的基本使用流程有一个简单的认识。
## 初始化
ImSDK 一切操作都是由通讯管理器 `TIMManager` 开始，SDK 操作第一步需要获取 `TIMManager` 单例。

**原型：**
```
/**
*  获取管理器实例
*
*  @return 管理器实例
*/
public static TIMManager getInstance()
```

**示例：**
```
TIMManager.getInstance();
```
在使用 SDK 进一步操作之前，需要初始 SDK。

**原型:**
```
/**
 * 初始化 ImSDK
 * @param context  application context
 * @param config SDK 全局配置
 * @return true - 初始化成功， false - 初始化失败
 */
public boolean init(@NonNull Context context, @NonNull TIMSdkConfig config)
```
**示例：**
```
//初始化 SDK 基本配置
TIMSdkConfig config = new TIMSdkConfig(sdkAppId)
        .enableCrashReport(false);
        .enableLogPrint(true)
        .setLogLevel(TIMLogLevel.DEBUG)
        .setLogPath(Environment.getExternalStorageDirectory().getPath() + "/justfortest/")

//初始化 SDK
TIMManager.getInstance().init(getApplicationContext(), config);
```
**更多初始化操作请参考 [初始化](https://cloud.tencent.com/document/product/269/9229)**

## 登录/登出
### 登录
用户登录腾讯后台服务器后才能正常收发消息，登录需要用户提供 `identifier`、`userSig`。如果用户保存用户票据，可能会存在过期的情况，如果用户票据过期，`login` 将会返回 `70001` 错误码，开发者可根据错误码进行票据更换。登录为异步过程，通过回调函数返回是否成功，成功后方能进行后续操作。登录成功或者失败后使用闭包 `succ` 和 `fail` 进行回调。

> **注意：**
>- 如果此用户在其他终端被踢，登录将会失败，返回错误码（`ERR_IMSDK_KICKED_BY_OTHERS：6208`）。开发者必须进行登录错误码 `ERR_IMSDK_KICKED_BY_OTHERS` 的判断。关于被踢的详细描述，参见 [用户状态变更](https://cloud.tencent.com/document/product/269/9229#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)。
>- 只要登录成功以后，用户没有主动登出或者被踢，网络变更会自动重连，无需开发者关心。不过特别需要注意被踢操作，需要注册 [用户状态变更回调](https://cloud.tencent.com/document/product/269/9229#.E7.94.A8.E6.88.B7.E7.8A.B6.E6.80.81.E5.8F.98.E6.9B.B4)，否则被踢时得不到通知。

**原型：**
```
/** 登录
 * @param identifier 用户帐号
 * @param userSig userSig，用户帐号签名，由私钥加密获得，具体请参考文档
 * @param callback 回调接口
 */
public void login(@NonNull String identifier, @NonNull String userSig, @NonNull TIMCallBack callback)
```

**示例：**

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

### 登出

如用户主动注销或需要进行用户的切换，则需要调用注销操作。

**原型：**

```
/**
 * 注销
 * @param callback 回调，不需要可以填 null
 */
public void logout(@Nullable TIMCallBack callback)
```

**示例：**

> **注意：**
> 在需要切换帐号时，需要 `logout` 回调成功或者失败后才能再次 `login`，否则 `login`可能会失败。

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
**更多登录操作请参考 [登录](https://cloud.tencent.com/document/product/269/9233)**

## 消息发送

### 通用消息发送

#### 会话获取

会话是指面向一个人或者一个群组的对话，通过与单个人或群组之间会话收发消息，发消息时首先需要先获取会话，获取会话需要指定会话类型（群组或者单聊），以及会话对方标志（对方帐号或者群号）。获取会话由 `getConversation` 实现。

**原型：** 

```
/**
 * 获取会话
 * @param type 会话类型
 * @param peer 参与会话的对方, C2C 会话为对方帐号 identifier, 群组会话为群组 ID
 * @return 会话实例
 */
public TIMConversation getConversation(TIMConversationType type, String peer)
```

**获取对方 `identifier` 为『sample_user_1』的单聊会话示例： **

```
//获取单聊会话
String peer = "sample_user_1";  //获取与用户 "sample_user_1" 的会话
conversation = TIMManager.getInstance().getConversation(
        TIMConversationType.C2C,    //会话类型：单聊
        peer);                      //会话对方用户帐号//对方ID
```

**获取群组 ID 为『TGID1EDABEAEO』的群聊会话示例：** 

```
//获取群聊会话
String groupId = "TGID1EDABEAEO";  //获取与群组 "TGID1LTTZEAEO" 的会话
conversation = TIMManager.getInstance().getConversation(
        TIMConversationType.Group,      //会话类型：群组
        groupId);                       //群组 ID
```

#### 消息发送

通过 `TIMManager` 获取会话 `TIMConversation` 后，可发送消息和获取会话缓存消息。ImSDK 中消息的解释可参阅 [ImSDK 对象简介](https://cloud.tencent.com/document/product/269/9227#imsdk-.E5.AF.B9.E8.B1.A1.E7.AE.80.E4.BB.8B)。 ImSDK 中的消息由 `TIMMessage` 表达， 一个 `TIMMessage` 由多个 `TIMElem` 组成，每个 `TIMElem` 可以是文本和图片，也就是说每一条消息可包含多个文本和多张图片。发消息通过 `TIMConversation` 的成员 `sendMessage` 实现。有两种方式实现，一种使用闭包，另一种调用方实现 `protocol` 回调。

![](//mccdn.qcloud.com/static/img/7226ab79d4294cc53980c888892f5c6d/image.png)

**原型：**

```
/**
 * 发送消息
 * @param msg 消息
 * @param callback 回调
 */
public void sendMessage(@NonNull TIMMessage msg, @NonNull TIMValueCallBack<TIMMessage> callback)
```

### 文本消息发送

文本消息由 `TIMTextElem` 定义。

```
/**
  * 获取文本内容
  * @return 文本内容
  */
public String getText() {
		return text;
}

/**
 * 设置文本内容
 * @param text 文本内容
 */
public void setText(String text) {
		this.text = text;
}
```

**示例：**

> 注：
>- text 传递需要发送的文本消息。
>- 失败回调中，code 表示错误码，具体可参阅 [错误码](/doc/product/269/1671)，err 表示错误描述。

```
//构造一条消息
TIMMessage msg = new TIMMessage();

//添加文本内容
TIMTextElem elem = new TIMTextElem();
elem.setText("a new msg");

//将elem添加到消息
if(msg.addElement(elem) != 0) {
   Log.d(tag, "addElement failed");
   return;
}

//发送消息
conversation.sendMessage(msg, new TIMValueCallBack<TIMMessage>() {//发送消息回调
    @Override
    public void onError(int code, String desc) {//发送消息失败
        //错误码 code 和错误描述 desc，可用于定位请求失败原因
        //错误码 code 含义请参见错误码表
        Log.d(tag, "send message failed. code: " + code + " errmsg: " + desc);
    }

    @Override
    public void onSuccess(TIMMessage msg) {//发送消息成功
        Log.e(tag, "SendMsg ok");
    }
});
```

**更多消息发送操作请参考 [消息收发](https://cloud.tencent.com/document/product/269/9232)**

## 消息接收
在多数情况下，用户需要感知新消息的通知，这时只需注册新消息通知回调 `TIMMessageListener`，在用户登录状态下，会拉取离线消息，为了不漏掉消息通知，需要在登录之前注册新消息通知。

**原型：**

```
/**
 * 添加一个消息监听器
 * @param listener 消息监听器
 *                 默认情况下所有消息监听器都将按添加顺序被回调一次
 *                 除非用户在 onNewMessages 回调中返回 true，此时将不再继续回调下一个消息监听器
 */
public void addMessageListener(TIMMessageListener listener)

/**
* 收到新消息回调
* @param msgs 收到的新消息
* @return 正常情况下，如果注册了多个listener, SDK会顺序回调到所有的listener。当碰到listener的回调返回true的时候，将终止继续回调后续的listener。
*/
public boolean onNewMessages(List<TIMMessage> msgs)
```

回调消息内容通过参数 `TIMMessage` 传递，通过 `TIMMessage` 可以获取消息和相关会话的详细信息，如消息文本，语音数据，图片等。以下示例中设置消息回调通知，并且在有新消息时直接打印消息。详细可参阅 [消息解析](https://cloud.tencent.com/document/product/269/9232#.E6.B6.88.E6.81.AF.E8.A7.A3.E6.9E.90) 部分。

**示例：**

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
**更多消息接收操作请参考 [消息收发](https://cloud.tencent.com/document/product/269/9232)**

## 群组管理
IM 云通讯有多种群组类型，其特点以及限制因素可参考 [群组系统](/doc/product/269/群组系统)。群组使用唯一 ID 标识，通过群组 ID 可以进行不同操作，其中群组相关操作都由 `TIMGroupManager` 实现，需要用户登录成功后操作。

**获取单例原型：**

```
/** 获取实例
 * @return TIMGroupManager 实例
 */
public static TIMGroupManager getInstance()
```

### 创建群组

云通信中内置了私有群、公开群、聊天室、互动直播聊天室和在线成员广播大群五种群组类型，详情请见 [群组形态介绍](https://cloud.tencent.com/document/product/269/1502#.E7.BE.A4.E7.BB.84.E5.BD.A2.E6.80.81.E4.BB.8B.E7.BB.8D)。创建时可指定群组名称以及要加入的用户列表，创建成功后返回群组 ID，可通过群组 ID 获取 `Conversation` 收发消息等。

**原型：**

```
/**
 * 创建群组
 * @param param 创建群组需要的信息集, 详见{@see CreateGroupParam}
 * @param cb 回调，OnSuccess 函数的参数中将返回创建成功的群组 ID
 */
public void createGroup(@NonNull CreateGroupParam param, @NonNull TIMValueCallBack<String> cb)
```

以下示例创建一个公开群组，并且把用户『cat』拉入群组。 **示例：**

```
//创建公开群，且不自定义群 ID
TIMGroupManager.CreateGroupParam param = new TIMGroupManager.CreateGroupParam("Public", "test_group");
//指定群简介
param.setIntroduction("hello world");
//指定群公告
param.setNotification("welcome to our group");

//添加群成员
List<TIMGroupMemberInfo> infos = new ArrayList<TIMGroupMemberInfo>();
TIMGroupMemberInfo member = new TIMGroupMemberInfo();
member.setUser("cat");
member.setRoleType(TIMGroupMemberRoleType.Normal);
infos.add(member);        
param.setMembers(infos);

//设置群自定义字段，需要先到控制台配置相应的 key
try {
    param.setCustomInfo("GroupKey1", "wildcat".getBytes("utf-8"));
} catch (UnsupportedEncodingException e) {
    e.printStackTrace();
}

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

### 群组消息 
群组消息与 C2C （单聊）消息相同，仅在获取 `Conversation` 时的会话类型不同，可参照 [消息发送](https://cloud.tencent.com/document/product/269/9232#.E6.B6.88.E6.81.AF.E5.8F.91.E9.80.81) 部分。

**更多群组操作请参考 [群组管理](https://cloud.tencent.com/document/product/269/9236)**


