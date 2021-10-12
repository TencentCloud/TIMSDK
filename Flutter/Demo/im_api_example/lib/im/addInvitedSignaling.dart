import 'package:flutter/material.dart';
import 'package:im_api_example/im/conversationSelector.dart';

import 'package:im_api_example/im/messageSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_offline_push_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_signaling_info.dart';

import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class AddInvitedSignaling extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddInvitedSignalingState();
}

class AddInvitedSignalingState extends State<AddInvitedSignaling> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  List<String> conversaions = List.empty(growable: true);
  List<String> msgIDs = List.empty(growable: true);
  getSignalingInfo() async {
    var signalInfo = await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .getSignalingInfo(
          msgID: msgIDs[0],
        );

    V2TimSignalingInfo info = V2TimSignalingInfo(
        actionType: signalInfo.data!.actionType,
        timeout: signalInfo.data!.timeout,
        inviteID: signalInfo.data!.inviteID,
        data: signalInfo.data!.data,
        groupID: signalInfo.data!.groupID,
        businessID: 1,
        isOnlineUserOnly: false,
        offlinePushInfo: V2TimOfflinePushInfo(),
        inviter: signalInfo.data!.inviter,
        inviteeList: signalInfo.data!.inviteeList);
    var res = await TencentImSDKPlugin.v2TIMManager
        .getSignalingManager()
        .addInvitedSignaling(info: info);

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
                  child: Text("添加信令信息（选择已有的信令信息进行测试）"),
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
