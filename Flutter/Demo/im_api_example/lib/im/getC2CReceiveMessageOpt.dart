import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetC2CReceiveMessageOpt extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetC2CReceiveMessageOptState();
}

class GetC2CReceiveMessageOptState extends State<GetC2CReceiveMessageOpt> {
  Map<String, dynamic>? resData;
  String? lastMsgID;
  List<String> users = List.empty(growable: true);
  getC2CReceiveMessageOpt() async {
    V2TimValueCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getC2CReceiveMessageOpt(userIDList: users);
    print("resaa:$res");
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    users = data;
                  });
                },
                switchSelectType: true,
                value: users,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(users.length > 0
                      ? "要查询的用户：${users.isNotEmpty ? users.first : ""}"
                      : "要查询的用户：未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getC2CReceiveMessageOpt,
                  child: Text("查询针对某个用户的 C2C 消息接收选项（免打扰状态）"),
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
