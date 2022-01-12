import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/avatar.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/utils/toast.dart';

class BlackList extends StatefulWidget {
  const BlackList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => BlackListState();
}

class BlackListState extends State<BlackList> {
  @override
  void initState() {
    super.initState();
    getBlackList();
  }

  List<V2TimFriendInfo> blackList = List.empty(growable: true);
  getBlackList() async {
    V2TimValueCallback<List<V2TimFriendInfo>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getBlackList();
    if (res.code == 0) {
      List<V2TimFriendInfo>? list = res.data;
      setState(() {
        blackList = list!;
      });
    } else {
      Utils.log("获取黑名单失败 ${res.desc} ${res.code} ");
    }
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
          '黑名单',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: blackList.isNotEmpty
          ? SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: blackList.map((e) => BlackListItem(e)).toList(),
                    ),
                  )
                ],
              ),
            )
          : Center(
              child: Text(
                "暂未添加黑名单数据",
                style: TextStyle(
                  color: CommonColors.getTextWeakColor(),
                ),
              ),
            ),
    );
  }
}

class BlackListItem extends StatelessWidget {
  const BlackListItem(this.info, {Key? key}) : super(key: key);
  final V2TimFriendInfo info;
  getNick() {
    if (info.friendRemark == null || info.friendRemark == '') {
      if (info.userProfile!.nickName == null ||
          info.userProfile!.nickName == '') {
        return info.userID;
      } else {
        return info.userProfile!.nickName;
      }
    } else {
      return info.friendRemark;
    }
  }

  remove(context) async {
    V2TimValueCallback<List<V2TimFriendOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .deleteFromBlackList(userIDList: [info.userID]);
    if (res.code == 0) {
      if (res.data![0].resultCode == 0) {
        Utils.toast("操作成功");
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {},
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1,
                  color: CommonColors.getBorderColor(),
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 10, right: 10),
            height: 50,
            child: Row(
              children: [
                Avatar(
                  width: 30,
                  height: 30,
                  radius: 0,
                  avtarUrl: info.userProfile!.faceUrl == '' ||
                          info.userProfile!.faceUrl == null
                      ? 'images/logo.png'
                      : info.userProfile!.faceUrl,
                ),
                Container(
                  margin: const EdgeInsets.only(left: 10),
                  child: Text(getNick()),
                ),
                Expanded(child: Container()),
                InkWell(
                  onTap: () {
                    remove(context);
                  },
                  child: Text(
                    "移除",
                    style: TextStyle(
                      color: CommonColors.getThemeColor(),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
