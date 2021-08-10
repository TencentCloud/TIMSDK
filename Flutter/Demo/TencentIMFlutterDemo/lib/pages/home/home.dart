import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tencent_im_sdk_plugin_example/common/hexToColor.dart';
import 'package:tencent_im_sdk_plugin_example/pages/contact/component/contactPopupMenu.dart';
import 'package:tencent_im_sdk_plugin_example/pages/contact/contact.dart';
import 'package:tencent_im_sdk_plugin_example/pages/message/message.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/profile.dart';

import 'component/popupMenu.dart';

/// 首页
class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  final List<NavigationBarData> data = [
    NavigationBarData(
      widget: Message(),
      // widget: Text("1"),
      title: "消息",
      selectedIcon: Icon(Icons.message),
      unselectedIcon: Icon(Icons.message),
    ),
    NavigationBarData(
      widget: Contact(),
      title: "通讯录",
      selectedIcon: Icon(Icons.supervised_user_circle),
      unselectedIcon: Icon(Icons.supervised_user_circle),
    ),
    NavigationBarData(
      widget: Profile(),
      // widget: Text("1"),
      // widget: TestApi(),
      title: "我",
      selectedIcon: Icon(Icons.perm_identity),
      unselectedIcon: Icon(Icons.perm_identity),
    ),
  ];

  /// 当前选择下标
  int currentIndex = 0;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        backgroundColor: Color(int.parse('006fff', radix: 16)).withAlpha(255),
        title: currentIndex == 0
            ? Text("腾讯·云通信")
            : currentIndex == 1
                ? Text("通讯录")
                : Text("我"),
        centerTitle: true,
        actions: <Widget>[
          currentIndex == 0
              ? MessagePopUpMenu()
              : currentIndex == 1
                  ? ContactPopUpMenu()
                  : Container(),
        ],
      ),
      body: IndexedStack(
        index: currentIndex,
        children: data.map((res) => res.widget).toList(),
      ),
      bottomNavigationBar: new BottomNavigationBar(
        items: List.generate(
          data.length,
          (index) => BottomNavigationBarItem(
            icon: index == currentIndex
                ? data[index].selectedIcon
                : data[index].unselectedIcon,
            label: data[index].title,
          ),
        ),
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          _changePage(index);
        },
        selectedItemColor: hexToColor('006fff'),
        unselectedItemColor: Color(0xFFFF90939A),
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
