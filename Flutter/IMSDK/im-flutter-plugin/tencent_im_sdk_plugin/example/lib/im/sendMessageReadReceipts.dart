import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/im/messageSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SendMessageReadReceipts extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendMessageReadReceiptsState();
}

class SendMessageReadReceiptsState extends State<SendMessageReadReceipts> {
  Map<String, dynamic>? resData;

  List<String> conversaions = List.empty(growable: true);
  List<String> msgIDs = List.empty(growable: true);
  sendMessageReadReceipts() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessageReadReceipts(
          messageIDList: msgIDs
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
                      : imt("未选择,这里只能选群消息，且非自己发的消息"),),
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
                  onPressed: sendMessageReadReceipts,
                  child: Text(imt("发送群消息已读回执")),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text("群已读回执需要先到控制台开通"),
            ],
          ),
          SDKResponse(resData),
        ],
      ),
    );
  }
}
