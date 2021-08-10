import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupMemberSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_full_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetGroupMembersInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetGroupMembersInfoState();
}

class GetGroupMembersInfoState extends State<GetGroupMembersInfo> {
  Map<String, dynamic>? resData;
  List<String> group = List.empty(growable: true);
  List<String> memberList = List.empty(growable: true);

  getGroupMembersInfo() async {
    V2TimValueCallback<List<V2TimGroupMemberFullInfo>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMembersInfo(
              groupID: group.first,
              memberList: memberList,
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
                child: ElevatedButton(
                  onPressed: getGroupMembersInfo,
                  child: Text("获取群成员信息"),
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
