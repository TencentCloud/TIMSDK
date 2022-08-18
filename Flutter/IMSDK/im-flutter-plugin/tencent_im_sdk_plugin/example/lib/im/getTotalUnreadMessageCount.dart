import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class GetTotalUnreadMessageCount extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetTotalUnreadMessageCountState();
}

class GetTotalUnreadMessageCountState
    extends State<GetTotalUnreadMessageCount> {
  Map<String, dynamic>? resData;
  getTotalUnreadMessageCount() async {
    V2TimValueCallback<int> res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .getTotalUnreadMessageCount();
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
              Expanded(
                child: ElevatedButton(
                  onPressed: getTotalUnreadMessageCount,
                  child: Text(imt("获取会话未读总数")),
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
