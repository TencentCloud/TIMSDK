import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetUserInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetUserInfoState();
}

class GetUserInfoState extends State<GetUserInfo> {
  Map<String, dynamic>? resData;
  List<String> users = List.empty(growable: true);
  getUserInfo() async {
    V2TimValueCallback<List<V2TimUserFullInfo>> res =
        await TencentImSDKPlugin.v2TIMManager.getUsersInfo(
      userIDList: users,
    );
    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          new Row(
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    users = data;
                  });
                },
                switchSelectType: false,
                value: users,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(users.length > 0 ? users.toString() : "未选择"),
                ),
              )
            ],
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getUserInfo,
                  child: Text("获取用户信息"),
                ),
              )
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
