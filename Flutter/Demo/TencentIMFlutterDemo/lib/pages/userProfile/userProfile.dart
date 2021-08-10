import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/conversion.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/addToBlackList.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/friendProfilePanel.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/listGap.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/userRemak.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friend.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class UserProfile extends StatefulWidget {
  UserProfile(this.userID);
  final String userID;
  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class SendMessage extends StatelessWidget {
  SendMessage(this.userID);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => Conversion('c2c_$userID'),
                  ),
                );
              },
              child: Text(
                '发送消息',
                style: TextStyle(
                  color: CommonColors.getWitheColor(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DeleteFriend extends StatelessWidget {
  DeleteFriend(this.userID);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                V2TimValueCallback<List<V2TimFriendOperationResult>> res =
                    await TencentImSDKPlugin.v2TIMManager
                        .getFriendshipManager()
                        .deleteFromFriendList(
                  userIDList: [userID],
                  deleteType: 2, //双向好友
                );
                if (res.code == 0) {
                  // 删除成功
                  Utils.toast('删除成功');
                  V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
                      await TencentImSDKPlugin.v2TIMManager
                          .getFriendshipManager()
                          .getFriendList();
                  if (friendRes.code == 0) {
                    List<V2TimFriendInfo>? list = friendRes.data;
                    if (list != null && list.length > 0) {
                      Provider.of<FriendListModel>(context, listen: false)
                          .setFriendList(list);
                    } else {
                      Provider.of<FriendListModel>(context, listen: false)
                          .setFriendList(List.empty(growable: true));
                    }
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(
                '删除好友',
                style: TextStyle(
                  color: CommonColors.getWitheColor(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AddFriend extends StatelessWidget {
  AddFriend(this.userID);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                V2TimValueCallback<V2TimFriendOperationResult> res =
                    await TencentImSDKPlugin.v2TIMManager
                        .getFriendshipManager()
                        .addFriend(
                          userID: userID,
                          addType: 1,
                        );

                if (res.code == 0) {
                  Utils.toast('添加成功');
                  V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
                      await TencentImSDKPlugin.v2TIMManager
                          .getFriendshipManager()
                          .getFriendList();
                  if (friendRes.code == 0) {
                    List<V2TimFriendInfo>? list = friendRes.data;
                    if (list != null && list.length > 0) {
                      Provider.of<FriendListModel>(context, listen: false)
                          .setFriendList(list);
                    } else {
                      Provider.of<FriendListModel>(context, listen: false)
                          .setFriendList(List.empty(growable: true));
                    }
                  }
                  Navigator.pop(context);
                }
              },
              child: Text(
                '添加好友',
                style: TextStyle(
                  color: CommonColors.getWitheColor(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class HandleButtons extends StatelessWidget {
  HandleButtons(this.userID, this.friendStatus);
  final String userID;
  final bool friendStatus;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.only(
        left: 10,
        right: 10,
      ),
      child: Column(
        children: [
          SendMessage(userID),
          friendStatus ? DeleteFriend(userID) : AddFriend(userID),
        ],
      ),
    );
  }
}

class UserProfileState extends State<UserProfile> {
  String? userID;
  V2TimFriendInfoResult? userInfo;
  bool friendStatus = false;
  void initState() {
    userID = widget.userID;
    getUserInfo();
    checkFriend(userID);
    super.initState();
  }

  getUserInfo() async {
    V2TimValueCallback<List<V2TimFriendInfoResult>> data =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .getFriendsInfo(userIDList: [userID!]);
    if (data.code == 0) {
      V2TimFriendInfoResult info = data.data![0];

      setState(() {
        userInfo = info;
      });
    }
  }

  // 检查是否为双向好友
  checkFriend(id) async {
    V2TimValueCallback res = await TencentImSDKPlugin.v2TIMManager
        .getFriendshipManager()
        .checkFriend(userIDList: [id], checkType: 2);
    print("查看好友状态");
    print(res.toJson());
    print(res.data[0].resultType);
    setState(() {
      friendStatus = res.data[0].resultType == 0 ? false : true; // 如果是0说明不是好友
    });
    print(friendStatus);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('用户资料'),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: CommonColors.getGapColor(),
                child: Column(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          FriendProfilePanel(userInfo, false),
                          ListGap(),
                          AddToBlackList(userInfo!),
                          UserRemark(userInfo, getUserInfo)
                        ],
                      ),
                    ),
                    HandleButtons(userID!, friendStatus),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
