import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/conversion/conversion.dart';
import 'package:discuss/pages/profile/component/addtoblacklist.dart';
import 'package:discuss/pages/profile/component/friendprofilepanel.dart';
import 'package:discuss/pages/profile/component/listgap.dart';
import 'package:discuss/pages/profile/component/userremak.dart';
import 'package:discuss/provider/friend.dart';
import 'package:discuss/utils/toast.dart';

class UserProfile extends StatefulWidget {
  const UserProfile(this.userID, {Key? key}) : super(key: key);
  final String userID;
  @override
  State<StatefulWidget> createState() => UserProfileState();
}

class SendMessage extends StatelessWidget {
  const SendMessage(this.userID, {Key? key}) : super(key: key);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
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
  const DeleteFriend(this.userID, {Key? key}) : super(key: key);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                  deleteType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH, //双向好友
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
                    if (list != null && list.isNotEmpty) {
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
  const AddFriend(this.userID, {Key? key}) : super(key: key);
  final String userID;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
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
                          addType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH,
                        );

                if (res.code == 0) {
                  Utils.toast('添加成功');
                  V2TimValueCallback<List<V2TimFriendInfo>> friendRes =
                      await TencentImSDKPlugin.v2TIMManager
                          .getFriendshipManager()
                          .getFriendList();
                  if (friendRes.code == 0) {
                    List<V2TimFriendInfo>? list = friendRes.data;
                    if (list != null && list.isNotEmpty) {
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
  const HandleButtons(this.userID, this.friendStatus, {Key? key})
      : super(key: key);
  final String userID;
  final bool friendStatus;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.only(
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
  @override
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
        .checkFriend(
      userIDList: [id],
      checkType: FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH,
    );
    Utils.log("查看好友状态");
    Utils.log(res.toJson());
    Utils.log(res.data[0].resultType);
    setState(() {
      friendStatus = res.data[0].resultType == 0 ? false : true; // 如果是0说明不是好友
    });
    Utils.log(friendStatus);
  }

  @override
  Widget build(Object context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: const Text(
          '用户资料',
          style: TextStyle(color: Colors.black),
        ),
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
                          const ListGap(),
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
