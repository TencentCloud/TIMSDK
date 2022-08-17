import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class AppendMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AppendMessageState();
}

class AppendMessageState extends State<AppendMessage> {
  Map<String, dynamic>? resData;
  appendMessage() async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> message1 = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: "hhh");
    V2TimValueCallback<V2TimMsgCreateInfoResult> message2 = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: "heihei");
    V2TimValueCallback<V2TimMessage> message =  await TencentImSDKPlugin.v2TIMManager.getMessageManager().appendMessage(createMessageBaseId: message1.data?.id ?? "", createMessageAppendId: message2.data?.id ?? "");
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(id: message1.data?.id ?? "", receiver: "940928", groupID: "");
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
                onPressed: appendMessage,
                child: Text(imt("多element消息发送")),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
