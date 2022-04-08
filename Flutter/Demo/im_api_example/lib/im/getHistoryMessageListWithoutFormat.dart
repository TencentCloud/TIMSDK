import 'dart:collection';
import 'dart:convert';

import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/history_msg_get_type_enum.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:im_api_example/i18n/i18n_utils.dart';

class GetHistoryMessageListWithoutFormat extends StatefulWidget {
  @override
  State<StatefulWidget> createState() =>
      GetHistoryMessageListWithoutFormatState();
}

class GetHistoryMessageListWithoutFormatState
    extends State<GetHistoryMessageListWithoutFormat> {
  LinkedHashMap<dynamic, dynamic>? resData;
  String? lastMsgID;
  List<String> users = List.empty(growable: true);
  List<String> group = List.empty(growable: true);
  HistoryMsgGetTypeEnum type = HistoryMsgGetTypeEnum.V2TIM_GET_LOCAL_OLDER_MSG;
  getHistoryMessageListWithoutFormat() async {
    LinkedHashMap<dynamic, dynamic> res = await TencentImSDKPlugin.v2TIMManager
        .getMessageManager()
        .getHistoryMessageListWithoutFormat(
            userID: users.isNotEmpty ? users.first : null,
            groupID: group.isNotEmpty ? group.first : null,
            count: 20,
            lastMsgID: lastMsgID,
            getType: type);
    setState(() {
      resData = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          new Row(
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
                  margin: EdgeInsets.only(left: 10),
                  child: Text(users.length > 0 ? users.toString() : imt("未选择")),
                ),
              )
            ],
          ),
          new Row(
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
                  margin: EdgeInsets.only(left: 10),
                  child: Text(group.length > 0 ? group.toString() : imt("未选择")),
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
                    child: Text(imt("选择type")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text(imt_para("已选：{{type}}", "已选：$type")(type: type)),
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getHistoryMessageListWithoutFormat,
                  child: Text(imt("获取历史消息高级接口（格式化数据）")),
                ),
              )
            ],
          ),
          SDKResponse(json.decode(json.encode(resData))),
        ],
      ),
    );
  }
}
