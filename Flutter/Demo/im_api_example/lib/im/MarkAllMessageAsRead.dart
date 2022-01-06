import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class MarkAllMessageAsRead extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => MarkAllMessageAsReadState();
}

class MarkAllMessageAsReadState extends State<MarkAllMessageAsRead> {
  Map<String, dynamic>? resData;
  markAllMessageAsRead() async {
    // V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
    //     .getMessageManager()
    //     .markAllMessageAsRead();
    // setState(() {
    //   resData = res.toJson();
    // });
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
                  onPressed: markAllMessageAsRead,
                  child: Text("标记所有消息为已读"),
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
