import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_handle_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/blackList/blackList.dart';
import 'package:tencent_im_sdk_plugin_example/pages/contact/component/FriendNotice.dart';
import 'package:tencent_im_sdk_plugin_example/pages/friendNotice/friendNotice.dart';
import 'package:tencent_im_sdk_plugin_example/pages/goups/goups.dart';
import 'package:tencent_im_sdk_plugin_example/pages/userProfile/userProfile.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friend.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friendApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/groupApplication.dart';

class Contact extends StatefulWidget {
  State<StatefulWidget> createState() => ConcatState();
}

class MyGroups extends StatelessWidget {
  Widget build(BuildContext context) {
    List<V2TimGroupApplication> applicationList;
    bool hasApplication;
    applicationList =
        Provider.of<GroupApplicationModel>(context).groupApplicationList;
    hasApplication = applicationList.any((element) =>
        element.handleStatus ==
        GroupApplicationHandleStatus
            .V2TIM_GROUP_APPLICATION_HANDLE_STATUS_UNHANDLED);
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) =>
                hasApplication ? NewFriendOrGroupNotice(2) : Groups(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 55,
        child: Row(
          children: [
            Expanded(
                child: Container(
              child: Text(
                "我的群聊",
                style: TextStyle(
                    fontSize: 18,
                    color:
                        Color(int.parse('111111', radix: 16)).withAlpha(255)),
              ),
            )),
            Container(
              // color: Colors.green,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(
                      child: Text(
                        hasApplication ? "有新的加群申请" : "",
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                  Container(
                    height: 55,
                    width: 20,
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color:
                          Color(int.parse('111111', radix: 16)).withAlpha(255),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          border: Border(
              bottom: BorderSide(
            color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
            width: 1,
            style: BorderStyle.solid,
          )),
        ),
        color: Colors.amber[777],
      ),
    );
  }
}

class BlakList extends StatelessWidget {
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => BlackList(),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 55,
        child: Row(
          children: [
            Expanded(
                child: Container(
              child: Text(
                "我的黑名单",
                style: TextStyle(
                    fontSize: 18,
                    color:
                        Color(int.parse('111111', radix: 16)).withAlpha(255)),
              ),
            )),
            Container(
              // color: Colors.green,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  Container(
                    height: 55,
                    width: 20,
                    child: Icon(
                      Icons.keyboard_arrow_right,
                      color:
                          Color(int.parse('111111', radix: 16)).withAlpha(255),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
        ),
        color: Colors.amber[777],
      ),
    );
  }
}

// GestureDetector
class UserListItem extends StatelessWidget {
  UserListItem(this.userInfo);
  final V2TimFriendInfo userInfo;

  Widget build(BuildContext context) {
    String? faceUrl = userInfo.userProfile!.faceUrl;
    String? name =
        (userInfo.friendRemark == null || userInfo.friendRemark == '')
            ? userInfo.userProfile!.userID
            : userInfo.friendRemark;
    String userId = userInfo.userID;
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          new MaterialPageRoute(
            builder: (context) => UserProfile(userId),
          ),
        );
      },
      child: Container(
        height: 56,
        child: Row(
          children: [
            Container(
              width: 40,
              margin: EdgeInsets.fromLTRB(16, 0, 12, 0),
              child: Avatar(
                avtarUrl: (faceUrl == '' || faceUrl == null)
                    ? 'images/logo.png'
                    : faceUrl,
                width: 40,
                height: 40,
                radius: 4.8,
              ),
            ),
            Expanded(
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name!,
                      style: TextStyle(
                          fontSize: 18,
                          color: Color(int.parse('111111', radix: 16))
                              .withAlpha(255)),
                    ),
                  ],
                ),
                height: 56,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color:
                          Color(int.parse('ededed', radix: 16)).withAlpha(255),
                      width: 1,
                      style: BorderStyle.solid,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ConcatList extends StatelessWidget {
  Widget build(BuildContext context) {
    List<V2TimFriendInfo?> list =
        Provider.of<FriendListModel>(context, listen: true).friendList;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 32,
          color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
          padding: EdgeInsets.only(
            left: 16,
          ),
          child: Row(
            children: [
              Text(
                "好友列表",
                textAlign: TextAlign.left,
                style: TextStyle(),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.length > 0
              ? SingleChildScrollView(
                  child: Column(
                    children: list.map((e) => UserListItem(e!)).toList(),
                  ),
                )
              : Center(
                  child: Text(
                    '暂无联系人',
                    style: TextStyle(
                      color: CommonColors.getTextWeakColor(),
                    ),
                  ),
                ),
        )
      ],
    );
  }
}

class ConcatState extends State<Contact> {
  ConcatState() {
    getFrendList();
    getFriendApplication();
    getGroupApplicationList();
  }
  getFrendList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendList();
    if (friendRes.code == 0) {
      List<V2TimFriendInfo?>? list = friendRes.data;
      if (list != null && list.length > 0) {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(list);
      } else {
        Provider.of<FriendListModel>(context, listen: false)
            .setFriendList(new List.empty(growable: true));
      }
    }
  }

  getGroupApplicationList() async {
    // 获取加群申请
    V2TimValueCallback<V2TimGroupApplicationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupApplicationList();
    if (res.code == 0) {
      if (res.code == 0) {
        if (res.data!.groupApplicationList!.length > 0) {
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(res.data!.groupApplicationList);
        } else {
          List<V2TimGroupApplication> list = List.empty(growable: true);
          Provider.of<GroupApplicationModel>(context, listen: false)
              .setGroupApplicationResult(list);
        }
      }
    } else {
      print("获取加群申请失败${res.desc}");
    }
  }

  getFriendApplication() async {
    V2TimValueCallback<V2TimFriendApplicationResult> data =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendApplicationList();
    if (data.code == 0) {
      if (data.data!.friendApplicationList!.length > 0) {
        Provider.of<FriendApplicationModel>(context, listen: false)
            .setFriendApplicationResult(data.data!.friendApplicationList);
      } else {
        List<V2TimFriendApplication> list = List.empty(growable: true);
        Provider.of<FriendApplicationModel>(context, listen: false)
            .setFriendApplicationResult(list);
      }
    }
  }

  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          FrientNotice(),
          MyGroups(),
          BlakList(),
          Expanded(
            child: ConcatList(),
          )
        ],
      ),
    );
  }
}
