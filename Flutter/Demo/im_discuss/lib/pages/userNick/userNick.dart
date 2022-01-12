import 'package:discuss/common/hextocolor.dart';
import 'package:discuss/utils/toast.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';

class UserNick extends StatefulWidget {
  const UserNick(this.userInfo, this.getUserInfo, {Key? key}) : super(key: key);
  final V2TimFriendInfoResult userInfo;
  final Function getUserInfo;
  @override
  State<StatefulWidget> createState() => UserNickState();
}

class UserNickState extends State<UserNick> {
  V2TimFriendInfoResult? userInfo;
  @override
  void initState() {
    userInfo = widget.userInfo;
    super.initState();
  }

  String nick = '';
  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return Container();
    }
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        shadowColor: hexToColor("ececec"),
        elevation: 1,
        title: const Text(
          '设置备注',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: CommonColors.getThemeColor(),
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              TextField(
                onChanged: (v) {
                  setState(() {
                    nick = v;
                  });
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        V2TimCallback res = await TencentImSDKPlugin
                            .v2TIMManager
                            .getFriendshipManager()
                            .setFriendInfo(
                              userID: userInfo!.friendInfo!.userID,
                              friendRemark: nick,
                            );
                        await widget.getUserInfo();
                        if (res.code == 0) {
                          Utils.log("succcess");
                          Navigator.pop(context);
                        } else {
                          Utils.log(res);
                        }
                      },
                      child: const Text("确定"),
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
