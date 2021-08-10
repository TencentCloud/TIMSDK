import 'package:flutter/material.dart';
import 'package:im_api_example/im/conversationSelector.dart';
import 'package:im_api_example/im/messageSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class RevokeMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RevokeMessageState();
}

class RevokeMessageState extends State<RevokeMessage> {
  Map<String, dynamic>? resData;
  List<String> conversaions = List.empty(growable: true);
  List<String> msgIDs = List.empty(growable: true);
  revokeMessage() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.getMessageManager().revokeMessage(
              msgID: msgIDs.first,
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
          new Row(
            children: [
              ConversationSelector(
                onSelect: (data) {
                  setState(() {
                    conversaions = data;
                  });
                },
                switchSelectType: true,
                value: conversaions,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(conversaions.length > 0
                      ? conversaions.toString()
                      : "未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              MessageSelector(
                conversaions.isNotEmpty ? conversaions.first : "",
                msgIDs,
                (data) {
                  setState(() {
                    msgIDs = data;
                  });
                },
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(msgIDs.toString()),
              ))
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: revokeMessage,
                  child: Text("撤回消息"),
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
