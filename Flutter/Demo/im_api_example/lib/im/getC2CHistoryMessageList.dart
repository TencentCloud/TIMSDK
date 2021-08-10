import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetC2CHistoryMessageList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetC2CHistoryMessageListState();
}

class GetC2CHistoryMessageListState extends State<GetC2CHistoryMessageList> {
  Map<String, dynamic>? resData;
  String? lastMsgID;
  List<String> users = List.empty(growable: true);
  getC2CHistoryMessageList() async {
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getC2CHistoryMessageList(
          userID: users.first,
          count: 20,
          lastMsgID: lastMsgID,
        );
    setState(() {
      resData = res.toJson();
      if (res.data!.length > 0) {
        lastMsgID = res.data!.last.msgID;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Form(
            child: Column(
              children: <Widget>[
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
                        child:
                            Text(users.length > 0 ? users.toString() : "未选择"),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text("lastMessageID："),
              Expanded(
                child: Container(
                  height: 60,
                  margin: EdgeInsets.only(left: 12),
                  child: Text(lastMsgID == null ? '' : lastMsgID!),
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getC2CHistoryMessageList,
                  child: Text("获取C2C历史消息"),
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
