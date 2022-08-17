import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/im/groupSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/message_elem_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_message.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetHistoryMessageList extends StatefulWidget {
  const GetHistoryMessageList({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => GetHistoryMessageListState();
}

class GetHistoryMessageListState extends State<GetHistoryMessageList> {
  Map<String, dynamic>? resData;
  String? lastMsgID;
  List<String> users = List.empty(growable: true);
  List<String> group = List.empty(growable: true);
  HistoryMsgGetTypeEnum type = HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG;
  getHistoryMessageList() async {
    V2TimValueCallback<List<V2TimMessage>> res = await TencentImSDKPlugin
        .v2TIMManager
        .getMessageManager()
        .getHistoryMessageList(
            userID: users.isNotEmpty ? users.first : null,
            groupID: group.isNotEmpty ? group.first : null,
            count: 20,
            lastMsgID: lastMsgID,
            getType: type,
            messageTypeList: [MessageElemType.V2TIM_ELEM_TYPE_CUSTOM]
            );
    setState(() {
      resData = res.toJson();
      if (res.data!.isNotEmpty) {
        lastMsgID = res.data!.last.msgID;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                margin: const EdgeInsets.only(left: 10),
                child: Text(users.isNotEmpty ? users.toString() : "未选择"),
              ),
            )
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GroupSelector(
              onSelect: (data) {
                setState(() {
                  group = data;
                });
              },
              switchSelectType: true,
              value: group,
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                child: Text(group.isNotEmpty ? group.toString() : "未选择"),
              ),
            )
          ],
        ),
        Container(
          height: 60,
          decoration: const BoxDecoration(
            border:  Border(
              bottom:  BorderSide(
                color: Colors.black45,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  showAdaptiveActionSheet(
                    context: context,
                    title: const Text('type'),
                    actions: <BottomSheetAction>[
                      BottomSheetAction(
                        title: const Text('V2TIM_GET_CLOUD_NEWER_MSG'),
                        onPressed: () {
                          setState(() {
                            type = HistoryMsgGetTypeEnum
                                .V2TIM_GET_CLOUD_NEWER_MSG;
                            lastMsgID = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      BottomSheetAction(
                        title: const Text('V2TIM_GET_CLOUD_OLDER_MSG'),
                        onPressed: () {
                          setState(() {
                            type = HistoryMsgGetTypeEnum
                                .V2TIM_GET_CLOUD_OLDER_MSG;
                            lastMsgID = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      BottomSheetAction(
                        title: const Text('V2TIM_GET_LOCAL_OLDER_MSG'),
                        onPressed: () {
                          setState(() {
                            type = HistoryMsgGetTypeEnum
                                .V2TIM_GET_LOCAL_OLDER_MSG;
                            lastMsgID = null;
                          });
                          Navigator.pop(context);
                        },
                      ),
                      BottomSheetAction(
                        title: const Text('V2TIM_GET_LOCAL_NEWER_MSG'),
                        onPressed: () {
                          setState(() {
                            type = HistoryMsgGetTypeEnum
                                .V2TIM_GET_LOCAL_NEWER_MSG;
                            lastMsgID = null;
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
                child: const Text("选择type"),
              ),
              Container(
                margin: const EdgeInsets.only(left: 12),
                child: Text("已选：$type"),
              )
            ],
          ),
        ),
        Row(
          children: [
            const Text("lastMessageID："),
            Expanded(
              child: Container(
                height: 60,
                margin: const EdgeInsets.only(left: 12),
                child: Text(lastMsgID == null ? '' : lastMsgID!),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: getHistoryMessageList,
                child: const Text("获取历史消息高级接口"),
              ),
            )
          ],
        ),
        SDKResponse(resData),
      ],
    );
  }
}
