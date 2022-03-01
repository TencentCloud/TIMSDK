import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:tim_ui_kit/ui/controller/tim_uikit_chat_controller.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/src/config.dart';
import 'package:timuikit/src/contact.dart';
import 'package:timuikit/src/conversation.dart';
import 'package:timuikit/src/profile.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
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
  var subscription;
  final Connectivity _connectivity = Connectivity();

  /// 当前选择下标
  int currentIndex = 0;

  @override
  initState() {
    super.initState();
    setState(() {
      currentIndex = widget.pageIndex;
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
      0: imt("频道"),
      1: imt("消息"),
      2: imt("通讯录"),
      3: imt("我的"),
    };
  }

  static List<NavigationBarData> getBottomNavigatorList(BuildContext context) {
    List<NavigationBarData> list = [];
    final List<NavigationBarData> bottomNavigatorList = [
      NavigationBarData(
        widget: const Channel(),
        // widget: Text("1"),
        title: imt("频道"),
        selectedIcon: Icon(
          Icons.group_work_outlined,
          color: hexToColor("4f98f9"),
        ),
        unselectedIcon: const Icon(
          Icons.group_work_outlined,
          color: Colors.grey,
        ),
      ),
      NavigationBarData(
        widget: const Conversation(),
        title: imt("消息"),
        selectedIcon: Image.asset(
          "assets/chat_active.png",
          width: 24,
          height: 24,
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
        selectedIcon: Image.asset(
          "assets/contact_active.png",
          width: 24,
          height: 24,
        ),
        unselectedIcon: Image.asset(
          "assets/contact.png",
          width: 24,
          height: 24,
        ),
      ),
      NavigationBarData(
        widget: const MyProfile(),
        title: imt("我的"),
        selectedIcon: Image.asset(
          "assets/profile_active.png",
          width: 24,
          height: 24,
        ),
        unselectedIcon: Image.asset(
          "assets/profile.png",
          width: 24,
          height: 24,
        ),
      ),
    ];

    return bottomNavigatorList;
  }

  List<NavigationBarData> bottomNavigatorList() {
    return getBottomNavigatorList(context);
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
          color: Colors.black, fontSize: IMDemoConfig.appBarTitleFontSize),
    );
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
    return Scaffold(
      appBar: currentIndex != 0
          ? AppBar(
              iconTheme: const IconThemeData(
                color: Colors.black,
              ),
              shadowColor: hexToColor("ececec"),
              elevation: 1,
              automaticallyImplyLeading: false,
              leading: null,
              backgroundColor: hexToColor("EBF0F6"),
              title: getTitle(),
              centerTitle: true,
            )
          : null,
      body: IndexedStack(
        index: currentIndex,
        children: bottomNavigatorList().map((res) => res.widget).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: List.generate(
          bottomNavigatorList().length,
          (index) => BottomNavigationBarItem(
            icon: index == currentIndex
                ? bottomNavigatorList()[index].selectedIcon
                : bottomNavigatorList()[index].unselectedIcon,
            label: bottomNavigatorList()[index].title,
          ),
        ),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _changePage(index);
        },
        selectedItemColor: hexToColor('006fff'),
        unselectedItemColor: Colors.grey,
        backgroundColor: hexToColor("EBF0F6"),
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
