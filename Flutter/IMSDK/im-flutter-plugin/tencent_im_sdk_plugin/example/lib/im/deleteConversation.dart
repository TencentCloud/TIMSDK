import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class DeleteConversation extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => DeleteConversationState();
}

class DeleteConversationState extends State<DeleteConversation> {
  Map<String, dynamic>? resData;
  List<String> conversaions = List.empty(growable: true);
  deleteConversation() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .deleteConversation(
          conversationID: conversaions.first,
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
                      : imt("未选择")),
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteConversation,
                  child: Text(imt("删除会话")),
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
