import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:tim_ui_kit/ui/widgets/avatar.dart';
import 'package:timuikit/src/blackList.dart';
import 'package:timuikit/src/group_list.dart';
import 'package:timuikit/src/provider/local_setting.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/user_profile.dart';
import 'newContact.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ContactState();
}

class _ContactState extends State<Contact> {
  @override
  void initState() {
    super.initState();
  }

  _topListItemTap(String id) {
    switch (id) {
      case "newContact":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const NewContact(),
            ));
        break;
      case "groupList":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => GroupList(),
            ));
        break;
      case "blackList":
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BlackList(),
            ));
    }
  }

  String _getImagePathByID(String id) {
    final themeTypeSubfix = Provider.of<DefaultThemeData>(context)
        .currentThemeType
        .toString()
        .replaceFirst('ThemeType.', '');
    switch (id) {
      case "newContact":
        return "assets/newContact_$themeTypeSubfix.png";
      case "groupList":
        return "assets/groupList_$themeTypeSubfix.png";
      case "blackList":
        return "assets/blackList_$themeTypeSubfix.png";
      default:
        return "";
    }
  }

  Widget? _topListBuilder(TopListItem item) {
    final showName = item.name;
    if (item.id == "newContact") {
      return InkWell(
        onTap: () {
          _topListItemTap(item.id);
        },
        child: Container(
          padding: const EdgeInsets.only(top: 10, left: 16),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                margin: const EdgeInsets.only(right: 12),
                child: Avatar(
                    faceUrl: _getImagePathByID(item.id),
                    showName: showName,
                    isFromLocal: true,
                    ),
              ),
              Expanded(
                  child: Container(
                padding: const EdgeInsets.only(top: 10, bottom: 19),
                decoration: BoxDecoration(
                    border: Border(
                        bottom: BorderSide(color: hexToColor("DBDBDB")))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      showName,
                      style:
                          TextStyle(color: hexToColor("111111"), fontSize: 18),
                    ),
                    Expanded(child: Container()),
                    const TIMUIKitUnreadCount(),
                    Container(
                      margin: const EdgeInsets.only(right: 16),
                      child: Icon(
                        Icons.keyboard_arrow_right,
                        color: hexToColor('BBBBBB'),
                      ),
                    )
                  ],
                ),
              ))
            ],
          ),
        ),
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final LocalSetting localSetting = Provider.of<LocalSetting>(context);
    return TIMUIKitContact(
      isShowOnlineStatus: localSetting.isShowOnlineStatus,
      topList: [
        TopListItem(
            name: imt("新的联系人"),
            id: "newContact",
            icon: Image.asset(_getImagePathByID("newContact")),
            onTap: () {
              _topListItemTap("newContact");
            }),
        TopListItem(
            name: imt("我的群聊"),
            id: "groupList",
            icon: Image.asset(_getImagePathByID("groupList")),
            onTap: () {
              _topListItemTap("groupList");
            }),
        TopListItem(
            name: imt("黑名单"),
            id: "blackList",
            icon: Image.asset(_getImagePathByID("blackList")),
            onTap: () {
              _topListItemTap("blackList");
            })
      ],
      topListItemBuilder: _topListBuilder,
      onTapItem: (item) {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserProfile(userID: item.userID),
            ));
      },
      emptyBuilder: (context) => Center(
        child: Text(imt("无联系人")),
      ),
    );
  }
}
