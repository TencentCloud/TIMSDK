import 'package:flutter/material.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SendC2CTextMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendC2CTextMessageState();
}

class SendC2CTextMessageState extends State<SendC2CTextMessage> {
  Map<String, dynamic>? resData;
  String text = '';
  List<String> users = List.empty(growable: true);
  /*
    3.6.0 后已经弃用建议不要使用
  */
  sendC2CTextMessage() async {
    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.sendC2CTextMessage(
      text: text,
      userID: users.first,
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
          Form(
            child: Column(
              children: <Widget>[
                TextField(
                  decoration: InputDecoration(
                    labelText: imt("发送文本"),
                    hintText: imt("发送文本"),
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      text = res;
                    });
                  },
                ),
                new Row(
                  children: [
                    FriendSelector(
                      onSelect: (data) {
                        setState(() {
                          users = data;
                        });
                      },
                      switchSelectType: true,
                      value: users,
                    ),
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        child:
                            Text(users.length > 0 ? users.toString() : imt("未选择")),
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendC2CTextMessage,
                  child: Text(imt("发送C2C文本消息（已经弃用）")),
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
