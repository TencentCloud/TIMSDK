import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/im/conversationSelector.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/im/messageSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/message_priority_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_msg_create_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class SendForwardMessage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SendForwardMessageState();
}

class SendForwardMessageState extends State<SendForwardMessage> {
  Map<String, dynamic>? resData;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  MessagePriorityEnum priority = MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  List<String> conversaions = List.empty(growable: true);
  List<String> msgIDs = List.empty(growable: true);
  sendForwardMessage() async {
    V2TimValueCallback<V2TimMsgCreateInfoResult> createMessage =
        await TencentImSDKPlugin.v2TIMManager
            .getMessageManager()
            .createForwardMessage(
              msgID: msgIDs.first,
            );
    String id = createMessage.data!.id!;

    V2TimValueCallback<V2TimMessage> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .sendMessage(
            id: id,
            receiver: receiver.length > 0 ? receiver.first : "",
            groupID: groupID.length > 0 ? groupID.first : "",
            priority: priority,
            onlineUserOnly: onlineUserOnly,
            isExcludedFromUnreadCount: isExcludedFromUnreadCount,
            localCustomData: imt("自定义localCustomData(sendForwardMessage)"));
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
              MessageSelector(
                conversaions.isNotEmpty ? conversaions.first : "",
                msgIDs,
                (data) {
                  setState(() {
                    msgIDs = data;
                  });
                },
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(msgIDs.toString()),
              ))
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
                      Text(receiver.length > 0 ? receiver.toString() : imt("未选择")),
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
                  child: Text(groupID.length > 0 ? groupID.toString() : imt("未选择")),
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
                        title: Text(imt("优先级")),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_DEFAULT'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_DEFAULT;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_HIGH'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_HIGH;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_LOW'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_LOW;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_PRIORITY_NORMAL'),
                            onPressed: () {
                              setState(() {
                                priority =
                                    MessagePriorityEnum.V2TIM_PRIORITY_NORMAL;
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
                    child: Text(imt("选择优先级")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text("已选：$priority"),
                )
              ],
            ),
          ),
          Row(
            children: [
              Text(imt("是否仅在线用户接受到消息")),
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
              Text(imt("发送消息是否不计入未读数")),
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
                  onPressed: sendForwardMessage,
                  child: Text(imt("转发消息")),
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
