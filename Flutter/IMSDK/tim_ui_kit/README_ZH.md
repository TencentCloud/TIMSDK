[English](./README.md)|简体中文

# Flutter TUIKit

TUIKit 是基于 IM SDK 实现的一套 UI 组件，其包含会话、聊天、搜索、关系链、群组、音视频通话等功能，基于 UI 组件您可以像搭积木一样快速搭建起自己的业务逻辑。

## Widget

- TIMUIKitConversation 会话组件
- TIMUIKitChat 聊天组件
- TIMUIKitCore Core 组件
- TIMUIKitProfile 个人详情组件
- TIMUIKitGroupProfile 群组详情组件
- TIMUIKitGroup 群组列表组件
- TIMUIKitBlackList 黑名单列表组件
- TIMUIKitContact 联系人组件
- TIMUIKitNewContact 新的联系人
- TIMUIKitSearch 搜索

### 截图

![](https://imgcache.qq.com/operation/dianshi/other/uikit.e8f3557a9e34f99120644b7a4a5645ec30c2cbd2.jpg)

## 介绍及使用

![](https://imgcache.qq.com/operation/dianshi/other/191645543019_.pic.06d8f22e726287c07cf38d362ec40d4deb4799c7.jpg)

## 国际化

我们默认提供 `简体中文` `繁体中文` `英语` 的语言支持；并允许开发者新增语言包，扩展多语言支持。

如果您需要使用国际化多语言能力，请参考 [腾讯云 IM Flutter TUIKit 国际化指南](https://docs.qq.com/doc/DSVN4aHVpZm1CSEhv?u=c927b5c7e9874f77b40b7549f3fffa57)。

## TIMUIKitCore

`TIMUIKitCore`提供两个静态方法`getInstance` 和 `getSDKInstance`。

- `getInstance`: 返回 `CoreServicesImpl` 实例。
- `getSDKInstance`: 返回 SDK 实例。

`CoreServicesImpl` 为`TIMUIKit` 核心类，包含初始化、登录、登出、获取用户信息等方法。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();

// init
_coreInstance.init(
        language: LanguageEnum?, // 初始指定使用语言，`简体中文` `繁体中文` `英语`
        onTUIKitCallbackListener: ValueChanged<TIMCallback>, // TUIKit信息回调，包含SDK API错误信息/TUIKit界面相关提示信息/Flutter层报错。您可根据需要，选择性自定义展示给用户。详见下方说明
        sdkAppID: 0, // 控制台申请的sdkAppID
        loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
        listener: V2TimSDKListener());
// unInit
_coreInstance.unInit();

// login
_coreInstance.login(
    userID: 0, // 用户ID
    userSig: "" // 参考官方文档userSig
)

// logout
_coreInstance.logout();

// getUsersInfo
_coreInstance.getUsersInfo(userIDList: ["123", "456"]);

// setOfflinePushConfig
_coreInstance.setOfflinePushConfig(
    businessID: businessID, //  IM 控制台证书 ID，接入 TPNS 不需要填写
    token: token, // 注册应用到厂商平台或者 TPNS 时获取的 token
    isTPNSToken: false // 是否接入配置 TPNS，token 是否是从TPNS 获取
)

// setSelfInfo
_coreInstance.setSelfInfo(userFullInfo: userFullInfo) // 设置用户信息

// setTheme
_coreInstance.setTheme(TUITheme theme: theme) // 设置主题色
/*
  TUITheme(
    // 应用主色
    final Color? primaryColor;
    // 应用次色
    final Color? secondaryColor;
    // 提示颜色，用于次级操作或提示
    final Color? infoColor;
    // 浅背景颜色，比主背景颜色浅，用于填充缝隙或阴影
    final Color? weakBackgroundColor;
    // 浅分割线颜色，用于分割线或边框
    final Color? weakDividerColor;
    // 浅字色
    final Color? weakTextColor;
    // 深字色
    final Color? darkTextColor;
    // 浅主色，用于AppBar或Panels
    final Color? lightPrimaryColor;
    // 字色
    final Color? textColor;
    // 警示色，用于危险操作
    final Color? cautionColor;
    // 群主标识色
    final Color? ownerColor;
    // 群管理员标识色
    final Color? adminColor;)
*/
```

### 静态方法

- **TIMUIKitCore.getInstance()**:
  返回`CoreServicesImpl` 实例
- **TIMUIKitCore.getSDKInstance()**:
  返回为 `V2TIMManager` 为`SDK 实例` 具体使用方式请参考[`Flutter IM SDK 文档`](https://pub.dev/documentation/tencent_im_sdk_plugin/latest/manager_v2_tim_manager/V2TIMManager/initSDK.html)

---

### `onTUIKitCallbackListener`监听

该监听用于返回包括：SDK API 错误 / Flutter 报错 / 一些可能需要弹窗提示用户的场景信息。

通过`TIMCallbackType`确定类型。

> 这部分的处理逻辑[可参考我们的 DEMO](https://github.com/TencentCloud/TIMSDK/blob/master/Flutter/Demo/im-flutter-uikit/lib/src/pages/app.dart)，并根据您的需要，自行修改。

#### SDK API 错误（`TIMCallbackType.API_ERROR`）

该场景下，提供 SDK API 原生`errorMsg`及`errorCode`。

[错误码请参考该文档](https://cloud.tencent.com/document/product/269/1671)

#### Flutter 报错（`TIMCallbackType.FLUTTER_ERROR`）

该错误由监听 Flutter 原生抛出异常产生，提供错误发生时的`stackTrace`(来自`FlutterError.onError`)或`catchError`(来自 try-catch)。

#### 场景信息（`TIMCallbackType.INFO`）

这些信息建议根据实际情况，弹窗提示用户。具体弹窗规则和弹窗样式可由您决定。

提供`infoCode`场景码帮助您确定当前的场景，并提供默认的提示推荐语`infoRecommendText`。

您可直接弹窗我们的推荐语，也可根据场景码自定义推荐语。推荐语语言根据系统语言自适应，请勿根据推荐语来判断场景。

场景码规则如下：

场景码由七位数组成，前五位数确定场景发生的组件，后两位确定具体的场景表现。

| 场景码开头 | 对应的组件             |
| ---------- | ---------------------- |
| 66601      | `TIMUIKitAddFriend`    |
| 66602      | `TIMUIKitAddGroup`     |
| 66603      | `TIMUIKitBlackList`    |
| 66604      | `TIMUIKitChat`         |
| 66605      | `TIMUIKitContact`      |
| 66606      | `TIMUIKitConversation` |
| 66607      | `TIMUIKitGroup`        |
| 66608      | `TIMUIKitGroupProfile` |
| 66609      | `TIMUIKitNewContact`   |
| 66610      | `TIMUIKitGroupProfile` |
| 66611      | `TIMUIKitNewContact`   |
| 66612      | `TIMUIKitProfile`      |
| 66613      | `TIMUIKitSearch`       |
| 66614      | 通用组件               |

全部场景码清单如下：

| 场景码 `infoCode` | 推荐提示语 `infoRecommendText`                               | 场景描述                                                     |
| ----------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| 6660101           | 好友申请已发送                                               | 用户申请添加其他用户为联系人                                 |
| 6660102           | 该用户已是好友                                               | 用户申请添加其他已是好友的用户为好友时，触发 `onTapAlreadyFriendsItem` 回调 |
| 6660201           | 群申请已发送                                                 | 用户申请加入需要管理员审批的群聊                             |
| 6660202           | 您已是群成员                                                 | 用户申请加群时，判断用户已经是当前群成员，触发 `onTapExistGroup` 回调 |
| 6660401           | 无法定位到原消息                                             | 当用户需要跳转至@消息或者是引用消息时，在消息列表中查不到目标消息 |
| 6660402           | 视频保存成功                                                 | 用户在消息列表，点开视频消息后，选择保存视频                 |
| 6660403           | 视频保存失败                                                 | 用户在消息列表，点开视频消息后，选择保存视频                 |
| 6660404           | 说话时间太短                                                 | 用户发送了过短的语音消息                                     |
| 6660405           | 发送失败,视频不能大于 100MB                                  | 用户试图发送大于 100MB 的视频                                |
| 6660406           | 图片保存成功                                                 | 用户在消息列表，点开图片大图后，选择保存图片                 |
| 6660407           | 图片保存失败                                                 | 用户在消息列表，点开图片大图后，选择保存图片                 |
| 6660408           | 已复制                                                       | 用户在弹窗内选择复制文字消息                                 |
| 6660409           | 暂未实现                                                     | 用户在弹窗内选择非标功能                                     |
| 6660410           | 其他文件正在接收中                                           | 用户点击下载文件消息时，前序下载任务还未完成                 |
| 6660411           | 正在接收中                                                   | 用户点击下载文件消息                                         |
| 6661001           | 无网络连接，无法修改                                         | 当用户试图在无网络环境下，修改群资料                         |
| 6661002           | 无网络连接，无法查看群成员                                   | 当用户试图在无网络环境下，修改群资料                         |
| 6661003           | 成功取消管理员身份                                           | 用户将群内其他用户移除管理员                                 |
| 6661201           | 无网络连接，无法修改                                         | 当用户试图在无网络环境下，修改自己或联系人的资料             |
| 6661202           | 好友添加成功                                                 | 在资料页添加其他用户为好友，并自动添加成功，无需验证         |
| 6661203           | 好友申请已发出                                               | 在资料页添加其他用户为好友，对方设置需要验证                 |
| 6661204           | 当前用户在黑名单                                             | 在资料页添加其他用户为好友，对方在自己的黑名单内             |
| 6661205           | 好友添加失败                                                 | 在资料页添加其他用户为好友，添加失败，可能是由于对方禁止加好友 |
| 6661206           | 好友删除成功                                                 | 在资料页删除其他用户为好友，成功                             |
| 6661207           | 好友删除失败                                                 | 在资料页删除其他用户为好友，失败                             |
| 6661401           | 输入不能为空                                                 | 当用户在录入信息时，输入了空字符串                           |
| 6661402           | 请传入离开群组生命周期函数，提供返回首页或其他页面的导航方法 | 用户退出群或解散群时，为提供返回首页办法                     |

## TIMUIKitConversation

`TIMUIKitConversation` 为会话组件，拉取用户会话列表，默认提供一套 UI,用户也可自定义会话条目。同时提供对应的`TIMUIKitConversationController`。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

final TIMUIKitConversationController _controller =
      TIMUIKitConversationController();
void _handleOnConvItemTaped(V2TimConversation? selectedConv) {
    // 处理逻辑，在此可跳转至聊天界面
}

List<ConversationItemSlidablePanel> _itemSlidableBuilder(
      V2TimConversation conversationItem) {
    return [
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _clearHistory(conversationItem);
        },
        backgroundColor: hexToColor("006EFF"),
        foregroundColor: Colors.white,
        label: '清除聊天',
        autoClose: true,
      ),
      ConversationItemSlidablePanel(
        onPressed: (context) {
          _pinConversation(conversationItem);
        },
        backgroundColor: hexToColor("FF9C19"),
        foregroundColor: Colors.white,
        label: conversationItem.isPinned! ? '取消置顶' : '置顶',
      )
    ];
  }

TIMUIKitConversation(
    lifeCycle: ConversationLifeCycle(), // Conversation 组件生命周期钩子函数
    onTapItem: _handleOnConvItemTaped, // 会话Item tap回调 可用于跳转至聊天界面
    itemSlidableBuilder: _itemSlidableBuilder, // 会话Item 向左滑动 的操作项， 可自定义会话置顶等
    controller: _controller, // 会话组件控制器， 可通过其获取会话的数据，设置会话数据，会话置顶等操作
    itembuilder: (conversationItem) {} // 用于自定义会话Item 的UI。 可结合TIMUIKitConversationController 实现业务逻辑
    conversationCollector: (conversation) {} // 会话收集器，可自定义会话是否显示
    lastMessageBuilder: (V2TimMessage, List<V2TimGroupAtInfo?>) {} // 会话item第二行最后一条消息字段
)
```

### TIMUIKitConversationController

#### 方法

- **loadData(int count)**:  
  加载会话列表, count 为单次加载数量
- **reloadData(int count)**:  
  重新加载会话列表, count 为单次加载数量
- **pinConversation({required String conversationID, required bool isPinned})**:
  会话置顶
- **clearHistoryMessage({required V2TimConversation conversation})**:  
  清除指定会话消息
- **deleteConversation({required String conversationID})**:  
  删除指定会话
- **setConversationListener({V2TimConversationListener? listener})**:  
  添加会话监听器
- **dipose()**:  
  销毁

---

## TIMUIKitChat

`TIMUIKitChat` 为聊天组件，提供消息列表的展示及消息发送的能力，同时支持自定义各种消息类型的展示。同时可结合 TIMUIKitChatController 实现消息的本地存储及消息预渲染。
目前支持的消息解析:

- 文本消息
- 图片消息
- 视频消息
- 语音消息
- 群消息
- 合并消息
- 文件消息

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

TIMUIKitChat(
    lifeCycle: ChatLifeCycle(), // Chat 组件生命周期钩子函数
    conversationID: "", // 会话ID
    conversationType: ConversationType, // 会话类型， 1为单聊，2为群聊
    conversationShowName: "", // 会话显示名称
    appBarActions: [], // appBar操作项，可用于跳转至群详情、个人详情页面。
    onTapAvatar: _onTapAvatar, // 头像tap 回调，可用于跳转至用户详情界面。
    showNickName: false, // 是否显示昵称
    messageItemBuilder: (MessageItemBuilder) {
        // 消息构造器，可选择自定义部分消息类型或消息行布局逻辑。为空字段使用默认交互，全都不传整体使用默认交互。
    },
    extraTipsActionItemBuilder: (message) {
      // 消息长按Tips自定义配置项，可根据业务额外配置
    },
    morePanelConfig: MorePanelConfig(), //更多消息能力区域配置
    appBarConfig: AppBar(), // scafold 顶部
    mainHistoryListConfig: ListView(), // 历史消息列表一些额外自定义配置
    textFieldHintText: "", // inputTextField hint
    draftText: "", // 消息草稿
    initFindingTimestamp: 0, // 跳转至某条消息的时间戳，为0表示不跳转
    config: TIMUIKitChatConfig(), // Chat组件配置类
    onDealWithGroupApplication: (String groupID){
      // jump to the pages for the page of [TIMUIKitGroupApplicationList] or other pages to handle joining group application for specific group
    }
)
```

### TIMUIKitChatController

#### 方法

- **clearHistory()**: 清除历史消息
- **dispose()**：销毁
- **sendMessage({required V2TimMessage messageInfo, String? receiverID, String? groupID, required ConvType convType})**：发送消息。根据 ConvType，receiverID/groupID 二选一传入。
- **sendForwardMessage({required List<V2TimConversation> conversationList,})**：逐条转发
- **sendMergerMessage({ required List<V2TimConversation> conversationList, required String title, required List<String> abstractList, required BuildContext context, })**：合并转发

---

## TIMUIKitProfile

`TIMUIKitProfile` 为用户详情展示。同时支持自定义添加操作项.

```dart
TIMUIKitProfile(
    userID: "",
    controller: TIMUIKitProfileController(),  // Profile Controller
    profileWidgetBuilder: ProfileWidgetBuilder(), // 可自定义一些 Profile Widget 条目
    profileWidgetsOrder: List<ProfileWidgetEnum>, // 使用默认或自定义 Profile Widget，根据此处传入的纵向顺序，渲染页面
    builder: (
      BuildContext context, 
      V2TimFriendInfo friendInfo, 
      V2TimConversation conversation, 
      int friendType, 
      bool isMute) {
        // 自定义整页。如自定义，`profileWidgetBuilder` 及 `profileWidgetsOrder` 将不生效。
      },
    lifeCycle: ProfileLifeCycle(),// Profile 组件生命周期钩子函数
)
```

### TIMUIKitProfileController

- **pinedConversation(bool isPined, String convID)**:  
  会话置顶, `isPined` 为是否置顶，`convID` 为需要置顶的会话 ID.
- **addUserToBlackList(bool shouldAdd, String userID)**:  
  添加用户至黑名单, `shouldAdd`为是否需要添加至黑名单, `userID`为需要被添加到黑名单的用户.
- **changeFriendVerificationMethod(int allowType)**:  
  更改好友验证方式, `0`为"同意任何用户添加好友"、`1`为"需要验证"、`2`为"拒绝任何人加好友".
- **updateRemarks(String userID, String remark)**:  
  更新好友备注, `userID`为被更新的用户 ID, `remark`为备注.
- **loadData**:  
  加载数据
- **dispose()**:  
  销毁
- **addFriend(String userID)**:  
  添加好友，`userID`为被添加好友的用户 ID.

---

## TIMUIKitGroupProfile

`TIMUIKitGroupProfile` 为群管理页面。同时支持自定义添加操作项.

```dart
TIMUIKitGroupProfile(
    groupID: "", //群ID 必填
    profileWidgetBuilder: GroupProfileWidgetBuilder(), // 自定义部分Group Profile Widget条目
    profileWidgetsOrder: List<GroupProfileWidgetEnum>, // 使用默认或自定义Group Profile Widget，根据此处传入的纵向顺序，渲染页面
    builder: (BuildContext context, V2TimGroupInfo groupInfo, List<V2TimGroupMemberFullInfo?> groupMemberList){
      // 自定义整页。如自定义，`profileWidgetBuilder` 及 `profileWidgetsOrder` 将不生效。
    },
    lifeCycle: GroupProfileLifeCycle, // Group Profile 组件生命周期钩子函数
)
```

`operationListBuilder` 及 `bottomOperationListBuilder` 主要给予用户可配置操作条目的能力，同时可结合子组件配合使用，可以自己选择搭配。

### 静态方法

- **TIMUIKitGroupProfile.memberTile()**:  
  群成员卡片、用于显示群成员概览、群成员列表、删除群成员等操作
- **TIMUIKitGroupProfile.groupNotification()**:  
  群公告显示及群公告更改
- **TIMUIKitGroupProfile.groupManage()**:  
  群管理、可设置管理员、禁言等
- **TIMUIKitGroupProfile.groupType()**:  
  显示群类型
- **TIMUIKitGroupProfile.groupAddOpt()**:  
  加群方式及修改
- **TIMUIKitGroupProfile.nameCard()**:
  群昵称及修改

---

## TIMUIKitBlackList

`TIMUIKitBlackList` 为黑名单列表。

```dart
TIMUIKitBlackList(
    onTapItem: (_) {}, // tap item 回调
    emptyBuilder: () {} // 当列表为空时显示
    itemBuilder: () {} // 自定义 item
    lifeCycle: BlockListLifeCycle(), // 黑名单组件生命周期钩子函数
)
```

---

## TIMUIKitGroup

`TIMUIKitGroup` 为群列表。

```dart
TIMUIKitGroup(
    onTapItem: (_) {}, // tap item 回调
    emptyBuilder: () {} // 当列表为空时显示
    itemBuilder: () {} // 自定义 item
)
```

---

### TIMUIKitContact

`TIMUIKitContact` 为联系人组件，提供联系人列表。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

TIMUIKitContact(
      lifeCycle: FriendListLifeCycle(), // 联系人组件生命周期钩子函数
      topList: [
        TopListItem(name: "新的联系人", id: "newContact"),
        TopListItem(name: "我的群聊", id: "groupList"),
        TopListItem(name: "黑名单", id: "blackList")
      ], // 顶部操作列表
      topListItemBuilder: _topListBuilder, // 顶部操作列表构造器
      onTapItem: (item) { }, // 点击联系人
      emptyBuilder: (context) => const Center(
        child: Text("无联系人"),
      ), // 联系人列表为空时显示
    );
```

### TIMUIKitSearch

`TIMUIKitSearch` 为全局搜索组件。全局搜索支持"联系人"/"群组"/"聊天记录"。
`TIMUIKitSearchMsgDetail` 为会话内搜索组件，可搜索会话内聊天记录。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

// 全局搜索
TIMUIKitSearch(
    onTapConversation: _handleOnConvItemTapedWithPlace, // Function(V2TimConversation, V2TimMessage? message), 跳转到特定conversation的特定message
    conversation： V2TimConversation, // 可选传入，若传入，则表示在该conversation内搜索，若不传入，则表示全局搜索
    onEnterConversation: (V2TimConversation conversation, String initKeyword){}, // 跳转至对应Conversation的会话内搜索，请手动跳转至TIMUIKitSearchMsg组件。
);

// 会话内搜索
TIMUIKitSearchMsgDetail(
              currentConversation: conversation!,
              onTapConversation: onTapConversation,
              keyword: initKeyword ?? "",
            );
```

### 如何自定义 TIMUIKitChat 组件

为扩展`TIMUIKitChat`组件的自定义能力，我们将该组件包含的基础子组件对外暴露，用户可根据业务去选择和使用基础子组件实现满足自身的业务。基础子组件包含如下:

- `TIMUIKitAppBar`
- `TIMUIKitHistoryMessageList`
- `TIMUIKitHistoryMessageListItem`
- `TIMUIKitInputTextField`

下文将对以上组件介绍及使用用例。

#### TIMUIKitAppBar

该组件为`TIMUIKitChat`的 appbar 组件，用于自定义应用导航栏。相较于 flutter 默认的`appbar`, 该组件额外提供了`title`自适应`用户昵称， 群名称`改变而动态改变，主题色改变。具体参数如下:

| name                 | type   | desc                                 | optional |
| -------------------- | ------ | ------------------------------------ | -------- |
| config               | AppBar | flutter appbar, 具体使用参考官方文档 | 可选     |
| showTotalUnReadCount | bool   | 显示会话总未读数, 默认为 true        | 可选     |
| conversationID       | String | 会话 ID                              | 可选     |
| conversationShowName | String | 会话名称                             | 可选     |

#### TIMUIKitHistoryMessageList

该组件为消息列表渲染组件，提供消息自动拉取，自动加载更多，跳转到指定消息。 具体参数如下:

| name                  | type                                         | desc                         | optional |
| --------------------- | -------------------------------------------- | ---------------------------- | -------- |
| messageList           | List<V2TimMessage?>                          | 消息列表，渲染数据源         | 必填     |
| tongueItemBuilder     | TongueItemBuilder                            | 小舌头(回到底部)自定义构造器 | 可选     |
| groupAtInfoList       | List<V2TimGroupAtInfo?>                      | 艾特信息                     | 可选     |
| itemBuilder           | Widget Function(BuildContext, V2TimMessage?) | 消息构造器                   | 可选     |
| controller            | TIMUIKitHistoryMessageListController         | 控制列表跳转，滚动           | 可选     |
| onLoadMore            | Function                                     | 加载更多                     | 必填     |
| mainHistoryListConfig | ListView                                     | 自定义 ListView              | 可选     |

#### TIMUIKitHistoryMessageListItem

该组件为消息实例组件，可根据提供的消息渲染不通的消息类型，包含`文本消息`，`图片消息`, `文件消息`,`通话消息`, `语音消息`等。同时支持消息自定义，主题定制能力。

| name                             | type               | desc                                                         | optional |
| -------------------------------- | ------------------ | ------------------------------------------------------------ | -------- |
| message                          | V2TimMessage       | 消息实例                                                     | 必填     |
| onTapForOthersPortrait           | Function           | 远端用户头像 tap 回调                                        | 可选     |
| onScrollToIndex                  | Function           | TIMUIKitHistoryMessageListController 的 scrollToIndex 方法，用于回复消息点击跳转到指定消息 | 可选     |
| onScrollToIndexBegin             | Function           | TIMUIKitHistoryMessageListController 的 scrollToIndexBegin 方法，长消息长按位置矫正 | 可选     |
| onLongPressForOthersHeadPortrait | Function           | 远端用户头像长按                                             | 可选     |
| messageItemBuilder               | MessageItemBuilder | 消息自定义构造器                                             | 可选     |
| topRowBuilder                    | Function           | 昵称所在行自定义 builder                                     | 可选     |
| bottomRowBuilder                 | Function           | 消息显示之下 builder                                         | 可选     |
| showAvatar                       | bool               | 是否显示头像                                                 | 可选     |
| showNickName                     | bool               | 是否显示用户昵称                                             | 可选     |
| showMessageSending               | bool               | 是否显示消息发送中状态                                       | 可选     |
| showMessageReadRecipt            | bool               | 是否显示消息已读                                             | 可选     |
| showGroupMessageReadRecipt       | bool               | 是否显示群消息已读                                           | 可选     |
| allowLongPress                   | bool               | 是否允许消息长按                                             | 可选     |
| allowAvatarTap                   | bool               | 是否允许头像 tap                                             | 可选     |
| allowAtUserWhenReply             | bool               | 是否在回复消息中提示对方                                     | 可选     |
| onLongPress                      | Function           | 消息长按回掉                                                 | 可选     |
| toolTipsConfig                   | ToolTipsConfig     | 消息长按 tool tips 配置                                      | 可选     |
| padding                          | double             | 消息间的间距                                                 | 可选     |
| textPadding                      | EdgeInsetsGeometry | 文本消息内边距                                               | 可选     |
| userAvatarBuilder                | Function           | 用户头像构造器                                               | 可选     |
| themeData                        | MessageThemeData   | 消息主题配置，可自定义字体颜色，大小等                       | 可选     |

#### TIMUIKitInputTextField

该组件为输入框组件，提供`文本消息`,`图片消息`,`语音消息`等发送能力。参数如下

| name               | type                             | desc                               | optional |
| ------------------ | -------------------------------- | ---------------------------------- | -------- |
| conversationID     | String                           | 会话 ID                            | 必填     |
| conversationType   | String                           | 会话类型                           | 必填     |
| initText           | String                           | 初始化文本                         | 可选     |
| scrollController   | AutoScrollController             | 用于发送消息时将消息列表滚动到底部 | 可选     |
| hintText           | String                           | 提示文本                           | 可选     |
| morePanelConfig    | MorePanelConfig                  | 更多面板配置                       | 可选     |
| showSendAudio      | bool                             | 是否显示发送语音                   | 可选     |
| showSendEmoji      | bool                             | 是否显示发送表情                   | 可选     |
| showMorePannel     | bool                             | 是否显示更多面板                   | 可选     |
| backgroundColor    | Color                            | 背景色                             | 可选     |
| controller         | TIMUIKitInputTextFieldController | 控制器，可控制输入框文本           | 可选     |
| onChanged          | Function                         | 文本改变回调事件                   | 可选     |
| customStickerPanel | Function                         | 自定义表情                         | 可选     |

#### 如何使用基础组件

如下是一个完整的使用示例

```dart
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKItMessageList/tim_uikit_history_message_list.dart';
import 'package:tim_ui_kit/ui/views/TIMUIKitChat/TIMUIKitTextField/tim_uikit_text_field.dart';

class Chat extends StatefulWidget {
  final V2TimConversation selectedConversation;
  final V2TimMessage? initFindingMsg;

  const ChatV2(
      {Key? key, required this.selectedConversation, this.initFindingMsg})
      : super(key: key);
  @override
  State<StatefulWidget> createState() => _ChatV2State();
}

class _ChatV2State extends State<ChatV2> {
  final TIMUIKitChatController _controller = TIMUIKitChatController();
  final TIMUIKitHistoryMessageListController _historyMessageListController =
      TIMUIKitHistoryMessageListController();
  final TIMUIKitInputTextFieldController _textFieldController =
      TIMUIKitInputTextFieldController();
  bool _haveMoreData = true;
  String? _getConvID() {
    return widget.selectedConversation.type == 1
        ? widget.selectedConversation.userID
        : widget.selectedConversation.groupID;
  }

  loadHistoryMessageList(String? lastMsgID, [int? count]) async {
    if (_haveMoreData) {
      _haveMoreData = await _controller.loadHistoryMessageList(
          count: count ?? 20,
          userID: widget.selectedConversation.userID,
          groupID: widget.selectedConversation.groupID,
          lastMsgID: lastMsgID);
    }
  }

  @override
  Widget build(BuildContext context) {
    return TIMUIKitChatProviderScope(
      conversationID: _getConvID() ?? "",
      conversationType: widget.selectedConversation.type ?? 0,
      builder: (context, w) {
        return GestureDetector(
          onTap: () {
            _textFieldController.hideAllPanel();
          },
          child: Scaffold(
            appBar: TIMUIKitAppBar(
              config: AppBar(
                title: Text(widget.selectedConversation.showName ?? ""),
              ),
            ),
            body: Column(
              children: [
                Expanded(
                    child: TIMUIKitHistoryMessageListSelector(
                  builder: (context, messageList, w) {
                    return TIMUIKitHistoryMessageList(
                      controller: _historyMessageListController,
                      messageList: messageList,
                      onLoadMore: loadHistoryMessageList,
                      itemBuilder: (context, message) {
                        return TIMUIKitHistoryMessageListItem(
                          onScrollToIndex:
                              _historyMessageListController.scrollToIndex,
                          onScrollToIndexBegin:
                              _historyMessageListController.scrollToIndexBegin,
                          message: message!,
                        );
                      },
                    );
                  },
                  conversationID: _getConvID() ?? "",
                )),
                TIMUIKitInputTextField(
                  controller: _textFieldController,
                  conversationID: _getConvID() ?? "",
                  conversationType: widget.selectedConversation.type ?? 1,
                  scrollController:
                      _historyMessageListController.scrollController!,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

```

在如上示例中需要注意的点:

- 在使用基础组件时必须通过`TIMUIKitChatProviderScope`组件包裹， 他会根据传入的`conversationID` 及`conversationType` 拉取对应的历史消息.该组件提供是基于通过`MultiProvider` 实现,同时可注入自定义的`provider`.其目的在于基础组件能够消费到业务层数据，同时可通过`TIMUIKitChatController` 控制业务层数据达到数据触发视图渲染的目的。
- 可以使用提供的`TIMUIKitAppBar`组件实现应用导航栏，同时也可根据业务的需要，自己实现 appBar.
- `TIMUIKitChatProviderScope`会加载历史消息到业务层, 通过`TIMUIKitHistoryMessageListSelector` 获取到业务层历史消息数据用于渲染，当历史消息数据发生改变时会触发渲染。
- 通过`TIMUIKitHistoryMessageList` 结合 `TIMUIKitHistoryMessageListItem` 实现消息页面的渲染
- `TIMUIKitInputTextField`实现发送消息

基础组件可根据业务需要自行更换以及组合。如若需要控制业务层数据,可通过`TIMUIKitChatController`提供的方法。


## 联系我们

如果您在接入使用过程中有任何疑问，请加入QQ群：788910197 咨询。