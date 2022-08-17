import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SetSelfStatus extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetSelfStatusState();
}

class SetSelfStatusState extends State<SetSelfStatus> {
  Map<String, dynamic>? resData;
  setSelfStatus() async {
    V2TimCallback res =
        await TencentImSDKPlugin.v2TIMManager.setSelfStatus(status: "梦游中..");
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
                  onPressed: setSelfStatus,
                  child: Text(imt("设置个人状态")),
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
