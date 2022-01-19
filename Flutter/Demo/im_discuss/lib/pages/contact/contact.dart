import 'package:discuss/utils/commonUtils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_handle_status.dart';

import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application.dart';

import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/blackList/blackList.dart';
import 'package:discuss/pages/contact/component/friendnotice.dart';
import 'package:discuss/pages/friendNotice/friendNotice.dart';
import 'package:discuss/pages/goups/goups.dart';
import 'package:discuss/pages/userProfile/userProfile.dart';
import 'package:discuss/provider/friend.dart';
import 'package:discuss/provider/groupapplication.dart';

class Contact extends StatefulWidget {
  const Contact({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ConcatState();
}

class MyGroups extends StatelessWidget {
  const MyGroups({Key? key}) : super(key: key);

  @override
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
          MaterialPageRoute(
            builder: (context) => hasApplication
                ? const NewFriendOrGroupNotice(2)
                : const Groups(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "我的群聊",
                style: TextStyle(
                  fontSize: CommonUtils.adaptFontSize(32),
                  color: Color(int.parse('111111', radix: 16)).withAlpha(255),
                ),
              ),
            ),
            SizedBox(
              // color: Colors.green,
              width: 200,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      hasApplication ? "有新的加群申请" : "",
                      textAlign: TextAlign.right,
                    ),
                  ),
                  SizedBox(
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
  const BlakList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const BlackList(),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: Text(
                "我的黑名单",
                style: TextStyle(
                  fontSize: CommonUtils.adaptFontSize(32),
                  color: Color(int.parse('111111', radix: 16)).withAlpha(255),
                ),
              ),
            ),
            SizedBox(
              // color: Colors.green,
              width: CommonUtils.adaptWidth(400),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Container(),
                  ),
                  SizedBox(
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
  const UserListItem(this.userInfo, {Key? key}) : super(key: key);
  final V2TimFriendInfo userInfo;

  @override
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
          MaterialPageRoute(
            builder: (context) => UserProfile(userId),
          ),
        );
      },
      child: SizedBox(
        height: CommonUtils.adaptHeight(112),
        child: Row(
          children: [
            Container(
              width: 40,
              margin: const EdgeInsets.fromLTRB(16, 0, 12, 0),
              child: Avatar(
                avtarUrl: (faceUrl == '' || faceUrl == null)
                    ? 'images/logo.png'
                    : faceUrl,
                width: CommonUtils.adaptWidth(80),
                height: CommonUtils.adaptHeight(80),
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
                          fontSize: CommonUtils.adaptFontSize(28),
                          color: Color(int.parse('111111', radix: 16))
                              .withAlpha(255)),
                    ),
                  ],
                ),
                height: CommonUtils.adaptHeight(112),
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
  const ConcatList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<V2TimFriendInfo?> list =
        Provider.of<FriendListModel>(context, listen: true).friendList;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 32,
          color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
          padding: const EdgeInsets.only(
            left: 16,
          ),
          child: Row(
            children: [
              Text(
                "好友列表",
                textAlign: TextAlign.left,
                style: TextStyle(fontSize: CommonUtils.adaptFontSize(28)),
              ),
            ],
          ),
        ),
        Expanded(
          child: list.isNotEmpty
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
  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        FrientNotice(),
        MyGroups(),
        BlakList(),
        Expanded(
          child: ConcatList(),
        )
      ],
    );
  }
}
