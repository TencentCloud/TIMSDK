import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupMemberSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MuteGroupMember extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MuteGroupMemberState();
}

class MuteGroupMemberState extends State<MuteGroupMember> {
  Map<String, dynamic>? resData;
  List<String> group = List.empty(growable: true);
  List<String> memberList = List.empty(growable: true);
  int seconds = 0;
  muteGroupMember() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.getGroupManager().muteGroupMember(
            groupID: group.first,
            userID: memberList.first, //注意：选择器没做单选，所以这里选第一个
            seconds: seconds);
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
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    group = data;
                  });
                },
                switchSelectType: true,
                value: group,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(group.length > 0 ? group.toString() : "未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              GroupMemberSelector(
                group.isNotEmpty ? group.first : "",
                memberList,
                (data) {
                  setState(() {
                    memberList = data;
                  });
                },
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(memberList.toString()),
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "seconds",
                    hintText: "seconds",
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (res) {
                    setState(() {
                      seconds = int.parse(res);
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: muteGroupMember,
                  child: Text("禁言群成员信息"),
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
