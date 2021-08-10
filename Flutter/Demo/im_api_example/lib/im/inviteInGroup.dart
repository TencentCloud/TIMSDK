import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupMemberSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class InviteInGroup extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InviteInGroupState();
}

class InviteInGroupState extends State<InviteInGroup> {
  Map<String, dynamic>? resData;
  String data = '';
  List<String> group = List.empty(growable: true);
  List<String> inviteeList = List.empty(growable: true);
  bool onlineUserOnly = false;
  int timeout = 30;
  inviteInGroup() async {
    V2TimValueCallback<String> res = await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .inviteInGroup(
          groupID: group.first,
          inviteeList: inviteeList,
          data: data,
          timeout: timeout,
          onlineUserOnly: onlineUserOnly,
        );

    setState(() {
      resData = res.toJson();
    });
    TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .cancel(inviteID: res.data!)
        .then((value) {
      print(value.toJson());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "发送文本",
                    hintText: "文本内容",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      data = res;
                    });
                  },
                ),
              ),
            ],
          ),
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
                inviteeList,
                (data) {
                  setState(() {
                    inviteeList = data;
                  });
                },
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(inviteeList.toString()),
              ))
            ],
          ),
          Row(
            children: [
              Text("是否仅在线用户接受到消息"),
              Switch(
                value: onlineUserOnly,
                onChanged: (res) {
                  setState(() {
                    onlineUserOnly = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: inviteInGroup,
                  child: Text("邀请"),
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
