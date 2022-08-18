import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class GetVersion extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetVersionState();
}

class GetVersionState extends State<GetVersion> {
  Map<String, dynamic>? resData;
  getVersion() async {
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getVersion();
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
                  onPressed: getVersion,
                  child: Text(imt("获取native sdk版本号")),
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
