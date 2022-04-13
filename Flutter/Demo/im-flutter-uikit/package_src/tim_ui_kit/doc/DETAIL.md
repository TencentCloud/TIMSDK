## TIMUIKitCore
`TIMUIKitCore`提供两个静态方法`getInstance` 和 `getSDKInstance`。
- `getInstance`: 返回 `CoreServicesImpl` 实例。
- `getSDKInstance`:  返回SDK实例。

`CoreServicesImpl` 为`TIMUIKit` 核心类，包含初始化、登录、登出、获取用户信息等方法。
```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();

/// init
_coreInstance.init(
        sdkAppID: 0, // 控制台申请的sdkAppID
        loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
        listener: V2TimSDKListener());
/// unInit
_coreInstance.unInit();

/// login
_coreInstance.login(
    userID: 0, // 用户ID
    userSig: "" // 参考官方文档userSig
)

/// logout
_coreInstance.logout();

/// getUsersInfo
_coreInstance.getUsersInfo(userIDList: ["123", "456"]);

/// setOfflinePushConfig
_coreInstance.setOfflinePushConfig(
    businessID: businessID, // 	IM 控制台证书 ID，接入 TPNS 不需要填写
    token: token, // 注册应用到厂商平台或者 TPNS 时获取的 token
    isTPNSToken: false // 是否接入配置 TPNS，token 是否是从TPNS 获取
)

/// setSelfInfo
_coreInstance.setSelfInfo(userFullInfo: userFullInfo) // 设置用户信息

/// setTheme
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

## TIMUIKitConversation
`TIMUIKitConversation` 为会话组件，拉取用户会话列表，默认提供一套UI,用户也可自定义会话条目。同时提供对应的`TIMUIKitConversationController`。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

final TIMUIKitConversationController _controller =
      TIMUIKitConversationController();
void _handleOnConvItemTaped(V2TimConversation? selectedConv) {
    /// 处理逻辑，在此可跳转至聊天界面
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
    onTapItem: _handleOnConvItemTaped, /// 会话Item tap回调 可用于跳转至聊天界面
    itemSlidableBuilder: _itemSlidableBuilder, /// 会话Item 向左滑动 的操作项， 可自定义会话置顶等
    controller: _controller, /// 会话组件控制器， 可通过其获取会话的数据，设置会话数据，会话置顶等操作
    itembuilder: (conversationItem) {} /// 用于自定义会话Item 的UI。 可结合TIMUIKitConversationController 实现业务逻辑
    conversationCollector: (conversation) {} /// 会话收集器，可自定义会话是否显示
)
```

### TIMUIKitConversationController

#### 方法:

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
`TIMUIKitChat` 为聊天组件，提供消息列表的展示及消息发送的能力，同时支持自定义各种消息类型的展示。同时可结合TIMUIKitChatController 实现消息的本地存储及消息预渲染。
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
    conversationID: "", /// 会话ID
    conversationType: 0, /// 会话类型
    conversationShowName: "", /// 会话显示名称
    onTapAvatar: _onTapAvatar, /// 头像tap 回调，可用于跳转至用户详情界面。
    showNickName: false, /// 是否显示昵称
    messageItemBuilder: (message) {
        /// 自定义消息构造器、返回null 会使用默认构造器。
    },
    exteraTipsActionItemBuilder: (message, close) {
      /// 消息长按Tips自定义配置项，可根据业务额外配置
    },
    textFieldHintText: "", /// 输入框hintText
    appBarConfig: AppBar(), /// 用于自定chat appBar
    draftText: "", /// 会话草稿，用于草稿回显，
    initFindingTimestamp: 0, /// 用于消息跳转，使用场景为，搜索历史消息后，可跳转至指定消息位置。
    morePanelConfig: MorePanelConfig(), /// "+" 号面板配置，可用于自定义面板Action.
)
```

### TIMUIKitChatController

#### 方法
- **setMessageListener({V2TimAdvancedMsgListener? listener})**: 设置高级消息监听器
- **removeMessageListener({V2TimAdvancedMsgListener? listener})**: 移除高级消息监听器
- **clearHistory()**: 清除历史消息
- **dispose()**：销毁


---

## TIMUIKitProfile

`TIMUIKitProfile` 为用户详情展示。同时支持自定义添加操作项.

```dart
TIMUIKitProfile(
    userID: "",
    controller: TIMUIKitProfileController(),  // Profile Controller
    operationListBuilder: (context, userInfo, conversation) {
        ///自定义操作项，例如消息免打扰、消息置顶等。 如若不传，会提供默认的操作项
    },
    bottomOperationBuilder: (context, friendInfo, conversation) {
        /// 底部操作项，如删除好友等。
    },
    handleProfileDetailCardTap: (BuildContext context, V2TimUserFullInfo? userFullInfo) {
        /// 个人详情tile tap 回调
    },
    canJumpToPersonalProfile: false, // 是否可以跳转至个人详情界面
)
```

### TIMUIKitProfileController
- **pinedConversation(bool isPined, String convID)**:
会话置顶, `isPined` 为是否置顶，`convID` 为需要置顶的会话ID.
- **addUserToBlackList(bool shouldAdd, String userID)**:
添加用户至黑名单, `shouldAdd`为是否需要添加至黑名单, `userID`为需要被添加到黑名单的用户.
- **changeFriendVerificationMethod(int allowType)**:
更改好友验证方式, `0`为"同意任何用户添加好友"、`1`为"需要验证"、`2`为"拒绝任何人加好友".
- **updateRemarks(String userID, String remark)**:
更新好友备注, `userID`为被更新的用户ID, `remark`为备注.
- **loadData**:
加载数据
- **dispose()**:
销毁
- **addFriend(String userID)**:
添加好友，`userID`为被添加好友的用户ID.


---

## TIMUIKitGroupProfile
`TIMUIKitGroupProfile` 为群管理页面。同时支持自定义添加操作项.
```dart
TIMUIKitGroupProfile(
    groupID: "", //群ID 必填
    operationListBuilder:(){}, // 操作项自定义构造器
    bottomOperationListBuilder: () {}, // 底部操作项自定义构造器
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
    onTapItem: (_) {}, /// tap item 回调
    emptyBuilder: () {} /// 当列表为空时显示
    itemBuilder: () {} /// 自定义 item
)
```

---

## TIMUIKitGroup
`TIMUIKitGroup` 为群列表。

```dart
TIMUIKitGroup(
    onTapItem: (_) {}, /// tap item 回调
    emptyBuilder: () {} /// 当列表为空时显示
    itemBuilder: () {} /// 自定义 item
)
```

---

## TIMUIKitContact
`TIMUIKitContact` 为联系人组件，提供联系人列表。

```dart
import 'package:tim_ui_kit/tim_ui_kit.dart';

TIMUIKitContact(
      topList: [
        TopListItem(name: "新的联系人", id: "newContact"),
        TopListItem(name: "我的群聊", id: "groupList"),
        TopListItem(name: "黑名单", id: "blackList")
      ], /// 顶部操作列表
      topListItemBuilder: _topListBuilder, /// 顶部操作列表构造器
      onTapItem: (item) { }, /// 点击联系人
      emptyBuilder: (context) => const Center(
        child: Text("无联系人"),
      ), /// 联系人列表为空时显示
    );
```

---

## TIMUIKitNewContact
`TIMUIKitNewContact` 为新的联系人界面
```dart
TIMUIKitNewContact(
    onAccept: (applicationInfo) {
        /// 接受好友回调
    },
    onRefuse: (applicationInfo) {
        /// 拒绝好友回调
    },
    emptyBuilder: () {
        /// 未收到好友申请时回调
    },
    itemBuilder: () {
        /// 自定义好友申请项构造器
    }
)
```

