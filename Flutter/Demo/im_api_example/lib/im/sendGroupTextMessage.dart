import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SendGroupTextMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendGroupTextMessageState();
}

class SendGroupTextMessageState extends State<SendGroupTextMessage> {
  Map<String, dynamic>? resData;
  String text = '';
  int priority = 0;
  List<String> groups = List.empty(growable: true);
  sendGroupTextMessage() async {
    V2TimValueCallback<V2TimMessage> res =
        await TencentImSDKPlugin.v2TIMManager.sendGroupTextMessage(
      text: text,
      groupID: groups.first,
      priority: priority,
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
                    labelText: "发送文本",
                    hintText: "发送文本",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      text = res;
                    });
                  },
                ),
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.black45,
                      ),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        child: Icon(
                          Icons.person,
                          color: Colors.black45,
                        ),
                        margin: EdgeInsets.only(left: 12),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: ElevatedButton(
                          onPressed: () {
                            showAdaptiveActionSheet(
                              context: context,
                              title: const Text('优先级'),
                              actions: <BottomSheetAction>[
                                BottomSheetAction(
                                  title: const Text('0'),
                                  onPressed: () {
                                    setState(() {
                                      priority = 0;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                BottomSheetAction(
                                  title: const Text('1'),
                                  onPressed: () {
                                    setState(() {
                                      priority = 1;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                BottomSheetAction(
                                  title: const Text('2'),
                                  onPressed: () {
                                    setState(() {
                                      priority = 2;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                                BottomSheetAction(
                                  title: const Text('3'),
                                  onPressed: () {
                                    setState(() {
                                      priority = 3;
                                    });
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                              cancelAction: CancelAction(
                                title: const Text('Cancel'),
                              ), // onPressed parameter is optional by default will dismiss the ActionSheet
                            );
                          },
                          child: Text("选择优先级"),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 12),
                        child: Text('已选：$priority'),
                      )
                    ],
                  ),
                ),
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
                        child:
                            Text(groups.length > 0 ? groups.toString() : "未选择"),
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
                  onPressed: sendGroupTextMessage,
                  child: Text("发送Group文本消息"),
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
