import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_status.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class GetUserStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetUserStatusState();
}

class GetUserStatusState extends State<GetUserStatus> {
  Map<String, dynamic>? resData;
  getUserStatus() async {
    V2TimValueCallback<List<V2TimUserStatus>> res =
        await TencentImSDKPlugin.v2TIMManager.getUserStatus(userIDList: ['940928']);
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
              Expanded(
                child: ElevatedButton(
                  onPressed: getUserStatus,
                  child: Text(imt("获取用户在线状态")),
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
