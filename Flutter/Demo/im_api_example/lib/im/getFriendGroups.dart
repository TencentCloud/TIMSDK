import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendGroupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_group.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetFriendGroups extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetFriendGroupsState();
}

class GetFriendGroupsState extends State<GetFriendGroups> {
  Map<String, dynamic>? resData;
  List<String> fgs = List.empty(growable: true);
  getFriendGroups() async {
    V2TimValueCallback<List<V2TimFriendGroup>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getFriendshipManager()
        .getFriendGroups(
          groupNameList: fgs,
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
          Row(
            children: [
              FriendGroupSelector(
                onSelect: (data) {
                  setState(() {
                    fgs = data;
                  });
                },
                switchSelectType: false,
                value: fgs,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(fgs.length > 0 ? fgs.toString() : "未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getFriendGroups,
                  child: Text("获取好友分组信息"),
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
