import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/im/messageSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class RevokeMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RevokeMessageState();
}

class RevokeMessageState extends State<RevokeMessage> {
  Map<String, dynamic>? resData;
  List<String> conversaions = List.empty(growable: true);
  List<String> msgIDs = List.empty(growable: true);
  revokeMessage() async {
    // 注意：web中webMessageInstatnce 为必填写
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .revokeMessage(
            msgID: msgIDs.first,
            webMessageInstatnce:
                '{"ID":"144115234457185510-1659689444-77842438","conversationID":"C2C3708","conversationType":"C2C","time":1659689445,"sequence":1645050002,"clientSequence":1645050002,"random":77842438,"priority":"Normal","nick":"xxxxx","avatar":"\\"\\"","isPeerRead":false,"nameCard":"","_elements":[{"type":"TIMTextElem","content":{"text":"test"}}],"isPlaceMessage":0,"isRevoked":false,"from":"940928","to":"3708","flow":"out","isSystemMessage":false,"protocol":"JSON","isResend":false,"isRead":true,"status":"success","_onlineOnlyFlag":false,"_groupAtInfoList":[],"_relayFlag":false,"atUserList":[],"cloudCustomData":"","isDeleted":false,"isModified":false,"_isExcludedFromUnreadCount":false,"_isExcludedFromLastMessage":false,"clientTime":1659689444,"senderTinyID":"144115234457185510","readReceiptInfo":{},"needReadReceipt":false,"version":0,"isBroadcastMessage":false,"payload":{"text":"test"},"type":"TIMTextElem"}');
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
                      : imt("未选择")),
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
                  child: Text(imt("撤回消息")),
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
