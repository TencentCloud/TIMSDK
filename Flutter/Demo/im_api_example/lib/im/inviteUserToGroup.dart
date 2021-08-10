import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class InviteUserToGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InviteUserToGroupState();
}

class InviteUserToGroupState extends State<InviteUserToGroup> {
  Map<String, dynamic>? resData;
  List<String> group = List.empty(growable: true);
  List<String> memberList = List.empty(growable: true);
  inviteUserToGroup() async {
    V2TimValueCallback<List<V2TimGroupMemberOperationResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .inviteUserToGroup(
              groupID: group.first,
              userList: memberList, //注意：选择器没做单选，所以这里选第一个
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
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    memberList = data;
                  });
                },
                switchSelectType: false,
                value: memberList,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                      memberList.length > 0 ? memberList.toString() : "未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: inviteUserToGroup,
                  child: Text("邀请好友进群"),
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
