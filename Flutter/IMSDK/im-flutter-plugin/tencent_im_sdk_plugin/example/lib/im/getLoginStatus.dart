import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class GetLoginStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetLoginStatusState();
}

class GetLoginStatusState extends State<GetLoginStatus> {
  Map<String, dynamic>? resData;
  getLoginStatus() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager.getLoginStatus();
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
                  onPressed: getLoginStatus,
                  child: Text(imt("获取当前登录状态")),
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
