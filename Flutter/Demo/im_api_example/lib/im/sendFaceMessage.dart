import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SendFaceMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendFaceMessageState();
}

class SendFaceMessageState extends State<SendFaceMessage> {
  Map<String, dynamic>? resData;
  String data = '';
  int index = 0;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  sendFaceMessage() async {
    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendFaceMessage(
          index: index,
          data: data,
          receiver: receiver.length > 0 ? receiver.first : "",
          groupID: groupID.length > 0 ? groupID.first : "",
          priority: priority,
          onlineUserOnly: onlineUserOnly,
          isExcludedFromUnreadCount: isExcludedFromUnreadCount,
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
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "表情位置",
                    hintText: "表情位置",
                    prefixIcon: Icon(Icons.person),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (res) {
                    setState(() {
                      data = res;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "表情信息",
                    hintText: "表情信息",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      data = res;
                    });
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    receiver = data;
                  });
                },
                switchSelectType: true,
                value: receiver,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child:
                      Text(receiver.length > 0 ? receiver.toString() : "未选择"),
                ),
              )
            ],
          ),
          Row(
            children: [
              GroupSelector(
                onSelect: (data) {
                  setState(() {
                    groupID = data;
                  });
                },
                switchSelectType: true,
                value: groupID,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(left: 10),
                  child: Text(groupID.length > 0 ? groupID.toString() : "未选择"),
                ),
              )
            ],
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
          Row(
            children: [
              Text("是否仅在线用户接受到消息"),
              Switch(
                value: onlineUserOnly,
                onChanged: (res) {
                  setState(() {
                    onlineUserOnly = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Text("发送消息是否不计入未读数"),
              Switch(
                value: isExcludedFromUnreadCount,
                onChanged: (res) {
                  setState(() {
                    isExcludedFromUnreadCount = res;
                  });
                },
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: sendFaceMessage,
                  child: Text("发送表情消息"),
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
