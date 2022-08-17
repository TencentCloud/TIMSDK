import 'package:flutter/material.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SetAPNSListener extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetAPNSListenerState();
}

class SetAPNSListenerState extends State<SetAPNSListener> {
  Map<String, dynamic>? resData;
  List<String> groups = List.empty(growable: true);
  setAPNSListener() async {
    dynamic res = await TencentImSDKPlugin.v2TIMManager.setAPNSListener();
    await TencentImSDKPlugin.v2TIMManager.getOfflinePushManager().doBackground(unreadCount: 100);
    setState(() {
      resData = {
        
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          new Row(
            children: [
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    groups = data;
                  });
                },
                switchSelectType: true,
                value: groups,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(groups.length > 0 ? groups.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: setAPNSListener,
                  child: Text(imt("设置APNS监听")),
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
