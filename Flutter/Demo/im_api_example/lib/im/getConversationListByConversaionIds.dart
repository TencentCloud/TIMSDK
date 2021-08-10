import 'package:flutter/material.dart';
import 'package:im_api_example/im/conversationSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetConversationByIDs extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetConversationByIDsState();
}

class GetConversationByIDsState extends State<GetConversationByIDs> {
  Map<String, dynamic>? resData;
  List<String> conversaions = List.empty(growable: true);
  getConversation() async {
    V2TimValueCallback<List<V2TimConversation>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationListByConversaionIds(
          conversationIDList: conversaions,
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
                switchSelectType: false,
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
              Expanded(
                child: ElevatedButton(
                  onPressed: getConversation,
                  child: Text("获取会话详情"),
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
