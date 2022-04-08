import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:im_api_example/i18n/i18n_utils.dart';

class InsertC2CMessageToLocalStorage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InsertC2CMessageToLocalStorageState();
}

class InsertC2CMessageToLocalStorageState
    extends State<InsertC2CMessageToLocalStorage> {
  Map<String, dynamic>? resData;
  String? lastMsgID;
  List<String> users = List.empty(growable: true);
  List<String> senders = List.empty(growable: true);
  insertC2CMessageToLocalStorage() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .insertC2CMessageToLocalStorage(
          userID: users.first,
          data: "test",
          sender: senders.first,
        );
    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    String userStr = users.length > 0 ? (users.isNotEmpty ? users.first : "") : imt("未选择");
    String senderStr = users.length > 0 ? (senders.isNotEmpty ? senders.first : "") : imt("未选择");
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
                  child: Text(imt_para("要查询的用户: {{userStr}}", "要查询的用户: $userStr")(userStr: userStr)),
                ),
              )
            ],
          ),
          new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    senders = data;
                  });
                },
                switchSelectType: true,
                value: senders,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(imt_para("要查询的用户: {{senderStr}}", "要查询的用户: $senderStr")(senderStr: senderStr)),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: insertC2CMessageToLocalStorage,
                  child: Text(imt("向c2c会话中插入一条本地消息")),
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
