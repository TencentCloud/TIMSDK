import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class GetServerTime extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetServerTimeState();
}

class GetServerTimeState extends State<GetServerTime> {
  Map<String, dynamic>? resData;
  getServerTime() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager.getServerTime();
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
                  onPressed: getServerTime,
                  child: Text(imt("获取服务端时间")),
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
