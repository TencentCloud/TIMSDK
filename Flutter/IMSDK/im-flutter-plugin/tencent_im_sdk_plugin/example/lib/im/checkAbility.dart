import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class CheckAbility extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CheckAbilityState();
}

class CheckAbilityState extends State<CheckAbility> {
  Map<String, dynamic>? resData;
  checkAbility() async {
    V2TimValueCallback<int> res =
        await TencentImSDKPlugin.v2TIMManager
            .checkAbility();

    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: checkAbility,
                child: Text(imt("检测能力位")),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
