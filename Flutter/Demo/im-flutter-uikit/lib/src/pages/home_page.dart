import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_conversation_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit_calling_plugin/tim_ui_kit_calling_plugin.dart';
import 'package:timuikit/src/add_friend.dart';
import 'package:timuikit/src/add_group.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/contact.dart';
import 'package:timuikit/src/conversation.dart';
import 'package:timuikit/src/create_group.dart';
import 'package:timuikit/src/profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';
import '../channel.dart';

/// 首页
class HomePage extends StatefulWidget {
  final int pageIndex;
  const HomePage({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool hasInit = false;
  int totalUnreadCount = 0;
  var subscription;
  final Connectivity _connectivity = Connectivity();
  bool hasInternet = true;
  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();
  final V2TIMManager _sdkInstance = TIMUIKitCore.getSDKInstance();
  final TUICalling _calling = TUICalling();
  final TIMUIKitConversationController _conversationController =
      TIMUIKitConversationController();
  final contactTooltip = [
    {"id": "addFriend", "asset": "assets/add_friend.png", "label": imt("添加好友")},
    {"id": "addGroup", "asset": "assets/add_group.png", "label": imt("添加群聊")}
  ];
  final conversationTooltip = [
    {"id": "createConv", "asset": "assets/c2c_conv.png", "label": imt("发起会话")},
    {"id": "createWork", "asset": "assets/group_conv.png", "label": imt("创建工作群")},
    {"id": "createPublic", "asset": "assets/group_conv.png", "label": imt("创建社交群")},
    {"id": "createMeeting", "asset": "assets/group_conv.png", "label": imt("创建会议群")},
    {"id": "createAvChat", "asset": "assets/group_conv.png", "label": imt("创建直播群")},
  ];

  /// 当前选择下标
  int currentIndex = 0;

  SuperTooltip? tooltip;

  Widget _emptyAvatarBuilder(context) {
    return Image.asset("assets/default_avatar.png");
  }

  _initConversationListener() {
    final listener = V2TimConversationListener(
        onTotalUnreadMessageCountChanged: ((unreadCount) {
      totalUnreadCount = unreadCount;
      setState(() {});
    }));

    _conversationController.setConversationListener(listener: listener);
  }

  _getTotalUnreadCount() async {
    final res = await _sdkInstance
        .getConversationManager()
        .getTotalUnreadMessageCount();
    if (res.code == 0) {
      totalUnreadCount = res.data ?? 0;
      setState(() {});
    }
  }

  _connectivityChange(ConnectivityResult result) {
    hasInternet = result != ConnectivityResult.none;
    setState(() {});
  }

  _initTrtc() {
    final loginInfo = _coreInstance.loginInfo;
    final userID = loginInfo.userID;
    final userSig = loginInfo.userSig;
    final sdkAppId = loginInfo.sdkAppID;
    _calling.init(sdkAppID: sdkAppId, userID: userID, userSig: userSig);
    _calling.enableFloatingWindow();
  }

  @override
  initState() {
    super.initState();
    currentIndex = widget.pageIndex;
    _coreInstance.setEmptyAvatarBuilder(_emptyAvatarBuilder);
    _initConversationListener();
    _getTotalUnreadCount();
    _initTrtc();
    setState(() {});
    subscription =
        _connectivity.onConnectivityChanged.listen(_connectivityChange);
  }

  @override
  dispose() {
    super.dispose();
    TIMUIKitChatController().dispose();
    // subscription.cancle();
  }

  Map<int, String> pageTitle() {
    return {
      0: imt("频道"),
      1: hasInternet ? imt("消息") : imt("连接中..."),
      2: imt("通讯录"),
      3: imt("我的"),
    };
  }

  List<NavigationBarData> getBottomNavigatorList(BuildContext context, theme) {
    final List<NavigationBarData> bottomNavigatorList = [
      NavigationBarData(
        widget: const Channel(),
        // widget: Text("1"),
        title: imt("频道"),
        selectedIcon: Icon(
          Icons.group_work_outlined,
          color: theme.primaryColor,
        ),
        unselectedIcon: const Icon(
          Icons.group_work_outlined,
          color: Colors.grey,
        ),
      ),
      NavigationBarData(
        widget: Conversation(
          conversationController: _conversationController,
        ),
        title: imt("消息"),
        selectedIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            ColorFiltered(
              child: Image.asset(
                "assets/chat_active.png",
                width: 24,
                height: 24,
              ),
              colorFilter: ColorFilter.mode(
                  theme.primaryColor ?? CommonColor.primaryColor,
                  BlendMode.srcATop),
            ),
            if (totalUnreadCount != 0)
              Positioned(
                top: -5,
                right: -6,
                child: UnconstrainedBox(
                  child: UnreadMessage(
                      width: 16, height: 16, unreadCount: totalUnreadCount),
                ),
              )
          ],
        ),
        unselectedIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              "assets/chat.png",
              width: 24,
              height: 24,
            ),
            if (totalUnreadCount != 0)
              Positioned(
                top: -5,
                right: -6,
                child: UnconstrainedBox(
                  child: UnreadMessage(
                      width: 16, height: 16, unreadCount: totalUnreadCount),
                ),
              )
          ],
        ),
      ),
      NavigationBarData(
        widget: const Contact(),
        title: imt("通讯录"),
        selectedIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            ColorFiltered(
              child: Image.asset(
                "assets/contact_active.png",
                width: 24,
                height: 24,
              ),
              colorFilter: ColorFilter.mode(
                  theme.primaryColor ?? CommonColor.primaryColor,
                  BlendMode.srcATop),
            ),
            const Positioned(
              top: -5,
              right: -6,
              child: UnconstrainedBox(
                child: TIMUIKitUnreadCount(
                  width: 16,
                  height: 16,
                ),
              ),
            )
          ],
        ),
        unselectedIcon: Stack(
          clipBehavior: Clip.none,
          children: [
            Image.asset(
              "assets/contact.png",
              width: 24,
              height: 24,
            ),
            const Positioned(
              top: -5,
              right: -6,
              child: UnconstrainedBox(
                child: TIMUIKitUnreadCount(
                  width: 16,
                  height: 16,
                ),
              ),
            )
          ],
        ),
      ),
      NavigationBarData(
        widget: const MyProfile(),
        title: imt("我的"),
        selectedIcon: ColorFiltered(
            child: Image.asset(
              "assets/profile_active.png",
              width: 24,
              height: 24,
            ),
            colorFilter: ColorFilter.mode(
                theme.primaryColor ?? CommonColor.primaryColor,
                BlendMode.srcATop)),
        unselectedIcon: Image.asset(
          "assets/profile.png",
          width: 24,
          height: 24,
        ),
      ),
    ];

    return bottomNavigatorList;
  }

  List<NavigationBarData> bottomNavigatorList(theme) {
    return getBottomNavigatorList(context, theme);
  }

  ///关闭
  close() {
    Navigator.of(context).pop();
  }

  //如果点击的导航页不是当前项，切换
  void _changePage(int index) {
    if (index != currentIndex) {
      setState(() {
        currentIndex = index;
      });
    }
  }

  Widget? getTitle() {
    return Text(
      pageTitle()[currentIndex]!,
      style: const TextStyle(
          color: Colors.white, fontSize: IMDemoConfig.appBarTitleFontSize),
    );
  }

  _handleTapTooltipItem(String id) {
    switch (id) {
      case "addFriend":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddFriend(),
          ),
        );
        break;
      case "addGroup":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const AddGroup(),
          ),
        );
        break;
      case "createConv":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateGroup(
              convType: ConversationType.single,
            ),
          ),
        );
        break;
      case "createWork":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateGroup(
              convType: ConversationType.work,
            ),
          ),
        );
        break;
      case "createPublic":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateGroup(
              convType: ConversationType.public,
            ),
          ),
        );
        break;
      case "createMeeting":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateGroup(
              convType: ConversationType.meeting,
            ),
          ),
        );
        break;
      case "createAvChat":
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const CreateGroup(
              convType: ConversationType.chat,
            ),
          ),
        );
        break;
    }
  }

  List<Widget> _getTooltipContent(BuildContext context) {
    List toolTipList = currentIndex == 1 ? conversationTooltip : contactTooltip;

    return toolTipList.map((e) {
      return InkWell(
        onTap: () {
          _handleTapTooltipItem(e["id"]!);
          tooltip!.close();
        },
        child: Row(
          children: [
            Image.asset(
              e["asset"]!,
              width: 21,
              height: 21,
            ),
            const SizedBox(
              width: 12,
            ),
            Text(e['label']!)
          ],
        ),
      );
    }).toList();
  }

  _showTooltip(BuildContext context) {
    tooltip = SuperTooltip(
        minimumOutSidePadding: 5,
        arrowTipDistance: 15,
        arrowBaseWidth: 15.0,
        arrowLength: 10.0,
        // maxHeight: 110,
        // maxWidth: 110,
        borderColor: Colors.white,
        backgroundColor: Colors.white,
        shadowColor: Colors.black26,
        content: Wrap(
          direction: Axis.vertical,
          spacing: 10,
          children: [..._getTooltipContent(context)],
        ),
        popupDirection: TooltipDirection.down);
    tooltip?.show(context);
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width,
          maxHeight: MediaQuery.of(context).size.height),
      // 设计稿尺寸：px
      designSize: const Size(750, 1624),
      context: context,
      minTextAdapt: true,
    );

    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: currentIndex != 0
          ? AppBar(
              iconTheme: const IconThemeData(
                color: Colors.white,
              ),
              shadowColor: theme.weakDividerColor,
              elevation: currentIndex == 1 ? 0 : 1,
              automaticallyImplyLeading: false,
              leading: null,
              title: getTitle(),
              centerTitle: true,
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                    theme.primaryColor ?? CommonColor.primaryColor
                  ]),
                ),
              ),
              actions: [
                if ([1, 2].contains(currentIndex))
                  Builder(builder: (BuildContext c) {
                    return IconButton(
                        onPressed: () {
                          _showTooltip(c);
                        },
                        icon: const Icon(
                          Icons.add_circle_outline,
                          color: Colors.white,
                        ));
                  })
              ],
            )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: bottomNavigatorList(theme).map((res) => res.widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: List.generate(
          bottomNavigatorList(theme).length,
          (index) => BottomNavigationBarItem(
            icon: index == currentIndex
                ? bottomNavigatorList(theme)[index].selectedIcon
                : bottomNavigatorList(theme)[index].unselectedIcon,
            label: bottomNavigatorList(theme)[index].title,
          ),
        ),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _changePage(index);
        },
        selectedItemColor: theme.primaryColor,
        unselectedItemColor: Colors.grey,
        backgroundColor: theme.weakBackgroundColor,
      ),
    );
  }
}

/// 底部导航栏数据对象
class NavigationBarData {
  /// 未选择时候的图标
  final Widget unselectedIcon;

  /// 选择后的图标
  final Widget selectedIcon;

  /// 标题内容
  final String title;

  /// 页面组件
  final Widget widget;

  NavigationBarData({
    required this.unselectedIcon,
    required this.selectedIcon,
    required this.title,
    required this.widget,
  });
}
