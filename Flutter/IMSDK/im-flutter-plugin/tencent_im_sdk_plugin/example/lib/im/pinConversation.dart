import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:example/i18n/i18n_utils.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class PinConversation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => PinConversationState();
}

class PinConversationState extends State<PinConversation> {
  Map<String, dynamic>? resData;
  List<String> conversaions = List.empty(growable: true);
  bool isPinned = false;
  pinConversation() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .pinConversation(
            conversationID: conversaions.first, isPinned: isPinned);
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
              Text(imt("会话置顶/取消置顶")),
              Switch(
                value: isPinned,
                onChanged: (res) {
                  setState(() {
                    isPinned = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: pinConversation,
                  child: Text(imt("会话置顶")),
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
