import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/add_friend.dart';
import 'package:timuikit/src/add_group.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/contact.dart';
import 'package:timuikit/src/conversation.dart';
import 'package:timuikit/src/profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';

/// 首页
class HomePage extends StatefulWidget {
  final int pageIndex;
  const HomePage({Key? key, this.pageIndex = 0}) : super(key: key);

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool hasInit = false;
  var subscription;
  final Connectivity _connectivity = Connectivity();
  bool hasInternet = true;
  final CoreServicesImpl _coreInstance = TIMUIKitCore.getInstance();

  /// 当前选择下标
  int currentIndex = 0;

  SuperTooltip? tooltip;

  Widget _emptyAvatarBuilder(context) {
    return Image.asset("assets/logo.png");
  }

  @override
  initState() {
    super.initState();
    _coreInstance.setEmptyAvatarBuilder(_emptyAvatarBuilder);
    setState(() {
      currentIndex = widget.pageIndex;
    });
    subscription =
        _connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      if (result == ConnectivityResult.none) {
        setState(() {
          hasInternet = false;
        });
      } else {
        setState(() {
          hasInternet = true;
        });
      }
    });
  }

  @override
  dispose() {
    super.dispose();
    TIMUIKitChatController().dispose();
    // subscription.cancle();
  }

  Map<int, String> pageTitle() {
    return {
      0: hasInternet ? imt("消息") : imt("连接中..."),
      1: imt("通讯录"),
      2: imt("我的"),
    };
  }

  static List<NavigationBarData> getBottomNavigatorList(
      BuildContext context, theme) {
    List<NavigationBarData> list = [];
    final List<NavigationBarData> bottomNavigatorList = [
      NavigationBarData(
        widget: const Conversation(),
        title: imt("消息"),
        selectedIcon: ColorFiltered(
          child: Image.asset(
            "assets/chat_active.png",
            width: 24,
            height: 24,
          ),
          colorFilter: ColorFilter.mode(
              theme.primaryColor ?? CommonColor.primaryColor,
              BlendMode.srcATop),
        ),
        unselectedIcon: Image.asset(
          "assets/chat.png",
          width: 24,
          height: 24,
        ),
      ),
      NavigationBarData(
        widget: const Contact(),
        title: imt("通讯录"),
        selectedIcon: ColorFiltered(
            child: Image.asset(
              "assets/contact_active.png",
              width: 24,
              height: 24,
            ),
            colorFilter: ColorFilter.mode(
                theme.primaryColor ?? CommonColor.primaryColor,
                BlendMode.srcATop)),
        unselectedIcon: Image.asset(
          "assets/contact.png",
          width: 24,
          height: 24,
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

  _showTooltip(BuildContext context) {
    tooltip = SuperTooltip(
        minimumOutSidePadding: 5,
        arrowTipDistance: 15,
        arrowBaseWidth: 15.0,
        arrowLength: 10.0,
        maxHeight: 110,
        maxWidth: 110,
        borderColor: Colors.white,
        backgroundColor: Colors.white,
        shadowColor: Colors.black26,
        content: Column(
          children: [
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddFriend(),
                  ),
                );
                tooltip!.close();
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/add_friend.png",
                    width: 21,
                    height: 21,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  const Text("添加好友")
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddGroup(),
                  ),
                );
                tooltip!.close();
              },
              child: Row(
                children: [
                  Image.asset(
                    "assets/add_group.png",
                    width: 21,
                    height: 21,
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  const Text("添加群聊")
                ],
              ),
            ),
          ],
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
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        shadowColor: theme.weakDividerColor,
        elevation: currentIndex == 0 ? 0 : 1,
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
          if (currentIndex == 1)
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
      ),
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
