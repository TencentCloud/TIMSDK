import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_conversation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetConversationList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetConversationListState();
}

class GetConversationListState extends State<GetConversationList> {
  Map<String, dynamic>? resData;
  String nextSeq = "0";

  getConversationList() async {
    V2TimValueCallback<V2TimConversationResult> res = await TencentImSDKPlugin
        .v2TIMManager
        .getConversationManager()
        .getConversationList(nextSeq: nextSeq, count: 10);

    setState(() {
      resData = res.toJson();
      nextSeq = res.data!.nextSeq!;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
            children: [
              Text("nextSeq"),
              Container(
                child: Text(nextSeq.toString()),
                height: 60,
                margin: EdgeInsets.only(left: 12),
                alignment: Alignment.centerLeft,
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getConversationList,
                  child: Text("获取会话列表"),
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
