import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message_change_info.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class ModifyMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ModifyMessageState();
}

class ModifyMessageState extends State<ModifyMessage> {
  Map<String, dynamic>? resData;
  modifyMessage() async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> cusMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createCustomMessage(data: "hehhe");
    V2TimValueCallback<V2TimMessage> msg = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(id: cusMessage.data!.id!, receiver: "121405", groupID: "");
    msg.data!.customElem?.data = "haha";
    if (kIsWeb) {
      final decodedMessage = jsonDecode(msg.data!.messageFromWeb!);
      decodedMessage['payload']['data'] = 'hhaaha';
      msg.data!.messageFromWeb = jsonEncode(decodedMessage);
      print(msg.data!.messageFromWeb);
    }
    V2TimValueCallback<V2TimMessageChangeInfo> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .modifyMessage(message: msg.data!);

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
                onPressed: modifyMessage,
                child: Text(imt("修改消息")),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
