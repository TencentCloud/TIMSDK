import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SetConversationDraft extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetConversationDraftState();
}

class SetConversationDraftState extends State<SetConversationDraft> {
  Map<String, dynamic>? resData;
  List<String> conversaions = List.empty(growable: true);
  bool isSetting = true;
  setConversationDraft() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getConversationManager()
        .setConversationDraft(
          conversationID: conversaions.first,
          draftText: isSetting ? imt("草稿内容，null为取消") : null,
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
          Row(
            children: [
              ConversationSelector(
                onSelect: (data) {
                  setState(() {
                    conversaions = data;
                  });
                },
                switchSelectType: true,
                value: conversaions,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(conversaions.length > 0
                      ? conversaions.toString()
                      : imt("未选择")),
                ),
              )
            ],
          ),
          Row(
            children: [
              Text(imt("设置草稿/取消草稿")),
              Switch(
                value: isSetting,
                onChanged: (res) {
                  setState(() {
                    isSetting = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: setConversationDraft,
                  child: Text(imt("设置会话草稿")),
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
