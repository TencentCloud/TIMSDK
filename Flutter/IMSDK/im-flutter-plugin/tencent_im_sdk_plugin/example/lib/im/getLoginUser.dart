import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class GetLoginUser extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetLoginUserState();
}

class GetLoginUserState extends State<GetLoginUser> {
  Map<String, dynamic>? resData;
  getLoginUser() async {
    V2TimValueCallback<String> res =
        await TencentImSDKPlugin.v2TIMManager.getLoginUser();
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
                  onPressed: getLoginUser,
                  child: Text(imt("获取当前登录用户")),
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
