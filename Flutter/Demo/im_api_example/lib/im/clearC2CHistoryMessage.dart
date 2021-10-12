import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class ClearC2CHistoryMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ClearC2CHistoryMessageState();
}

class ClearC2CHistoryMessageState extends State<ClearC2CHistoryMessage> {
  Map<String, dynamic>? resData;
  String text = '';
  List<String> users = List.empty(growable: true);
  clearMessage() async {
    var res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .clearC2CHistoryMessage(
          userID: users.first,
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
          Form(
            child: Column(
              children: <Widget>[
                new Row(
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
              Expanded(
                child: ElevatedButton(
                  onPressed: clearMessage,
                  child: Text("清空单聊本地及云端的消息（不删除会话）"),
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
