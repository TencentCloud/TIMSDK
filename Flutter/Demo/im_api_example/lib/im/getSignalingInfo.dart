import 'package:flutter/material.dart';
import 'package:im_api_example/im/conversationSelector.dart';

import 'package:im_api_example/im/messageSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';

import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetSignalingInfo extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetSignalingInfoState();
}

class GetSignalingInfoState extends State<GetSignalingInfo> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  List<String> conversaions = List.empty(growable: true);
  List<String> msgIDs = List.empty(growable: true);
  getSignalingInfo() async {
    var res = await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .getSignalingInfo(
          msgID: msgIDs[0],
        );
    print("msgIDs[0]:${msgIDs[0]}");
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
                  onPressed: getSignalingInfo,
                  child: Text("获取信令信息"),
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
