import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class Invite extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InviteState();
}

class InviteState extends State<Invite> {
  Map<String, dynamic>? resData;
  String data = '';
  List<String> receiver = List.empty(growable: true);
  bool onlineUserOnly = false;
  int timeout = 30;
  invite() async {
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getSignalingManager().invite(
              invitee: receiver.first,
              data: data,
              timeout: timeout,
              onlineUserOnly: onlineUserOnly,
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
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    receiver = data;
                  });
                },
                switchSelectType: true,
                value: receiver,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child:
                      Text(receiver.length > 0 ? receiver.toString() : "未选择"),
                ),
              )
            ],
          ),
          // Row(
          //   children: [
          //     GroupSelector(
          //       onSelect: (data) {
          //         setState(() {
          //           groupID = data;
          //         });
          //       },
          //       switchSelectType: true,
          //       value: groupID,
          //     ),
          //     Expanded(
          //       child: Container(
          //         margin: EdgeInsets.only(left: 10),
          //         child: Text(groupID.length > 0 ? groupID.toString() : "未选择"),
          //       ),
          //     )
          //   ],
          // ),
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
                  onPressed: invite,
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
