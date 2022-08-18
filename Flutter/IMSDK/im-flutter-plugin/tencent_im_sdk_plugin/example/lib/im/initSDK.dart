import 'package:flutter/material.dart';
import 'package:example/provider/event.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:localstorage/localstorage.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/enum/V2TimSDKListener.dart';
import 'package:tencent_im_sdk_plugin/enum/log_level_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class InitSDK extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => InitSDKState();
}

class InitSDKState extends State<InitSDK> {
  final LocalStorage storage = new LocalStorage('package:example_user_info');

  Map<String, dynamic>? resData;
  initIMSDK() async {
    V2TimValueCallback<bool> res =
        await TencentImSDKPlugin.v2TIMManager.initSDK(
      sdkAppID: int.parse(storage.getItem('sdkappid')),
      loglevel: LogLevelEnum.V2TIM_LOG_DEBUG,
      listener: new V2TimSDKListener(
        onConnectFailed:
            Provider.of<Event>(context, listen: false).onConnectFailed,
        onConnectSuccess:
            Provider.of<Event>(context, listen: false).onConnectSuccess,
        onConnecting:
            Provider.of<Event>(context, listen: false).onConnectSuccess,
        onKickedOffline:
            Provider.of<Event>(context, listen: false).onKickedOffline,
        onSelfInfoUpdated:
            Provider.of<Event>(context, listen: false).onSelfInfoUpdated,
        onUserSigExpired:
            Provider.of<Event>(context, listen: false).onUserSigExpired,
        onUserStatusChanged: Provider.of<Event>(context, listen: false).onUserStatusChanged,
      ),
    );
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
                  onPressed: initIMSDK,
                  child: Text(imt("初始化")),
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
