import 'package:flutter/material.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/group_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_application_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';
import 'package:tencent_im_sdk_plugin_platform_interface/models/v2_tim_group_application.dart';

class AcceptGroupApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AcceptGroupApplicationState();
}

class AcceptGroupApplicationState extends State<AcceptGroupApplication> {
  Map<String, dynamic>? resData;
  acceptGroupApplication() async {
    // V2TimValueCallback<V2TimMsgCreateInfoResult> message1 = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: "hhh");
    // V2TimValueCallback<V2TimMsgCreateInfoResult> message2 = await TencentImSDKPlugin.v2TIMManager.getMessageManager().createTextMessage(text: "heihei");
    // V2TimValueCallback<V2TimMessage> message =  await TencentImSDKPlugin.v2TIMManager.getMessageManager().appendMessage(createMessageBaseId: message1.data?.id ?? "", createMessageAppendId: message2.data?.id ?? "");
    // V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager.getMessageManager().sendMessage(id: message1.data?.id ?? "", receiver: "940928", groupID: "");
    V2TimValueCallback<V2TimGroupApplicationResult> apps = await TencentImSDKPlugin.v2TIMManager.getGroupManager().getGroupApplicationList();
    print(apps.toJson());
    List<V2TimGroupApplication?>? result = apps.data?.groupApplicationList;
    V2TimGroupApplication? app = result?.firstWhere((element) => element?.type == 1 && element?.handleStatus == 0);
    print(app?.toJson());
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.getGroupManager().acceptGroupApplication(fromUser: app?.fromUser ?? "",toUser: app?.toUser?? "", groupID: app?.groupID?? "",addTime: app?.addTime,type: GroupApplicationTypeEnum.values[app?.type??0],reason: "");
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
                onPressed: acceptGroupApplication,
                child: Text(imt("同意进群申请")),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
