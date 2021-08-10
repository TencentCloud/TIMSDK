import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_filter_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_member_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class GetGroupMemberList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GetGroupMemberListState();
}

class GetGroupMemberListState extends State<GetGroupMemberList> {
  Map<String, dynamic>? resData;
  List<String> group = List.empty(growable: true);
  int filter = GroupMemberFilterType.V2TIM_GROUP_MEMBER_FILTER_ALL;
  String nextSeq = "0";
  getGroupMemberList() async {
    V2TimValueCallback<V2TimGroupMemberInfoResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getGroupManager()
            .getGroupMemberList(
              groupID: group.first,
              filter: filter,
              nextSeq: nextSeq,
            );
    setState(() {
      resData = res.toJson();
      if (res.data != null) {
        nextSeq = res.data!.nextSeq!;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Row(
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
                  child: Text(group.length > 0 ? group.toString() : "未选择"),
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
                        title: const Text('filter'),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title:
                                const Text('V2TIM_GROUP_MEMBER_FILTER_ADMIN'),
                            onPressed: () {
                              setState(() {
                                filter = GroupMemberFilterType
                                    .V2TIM_GROUP_MEMBER_FILTER_ADMIN;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_GROUP_MEMBER_FILTER_ALL'),
                            onPressed: () {
                              setState(() {
                                filter = GroupMemberFilterType
                                    .V2TIM_GROUP_MEMBER_FILTER_ALL;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title:
                                const Text('V2TIM_GROUP_MEMBER_FILTER_COMMON'),
                            onPressed: () {
                              setState(() {
                                filter = GroupMemberFilterType
                                    .V2TIM_GROUP_MEMBER_FILTER_COMMON;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title:
                                const Text('V2TIM_GROUP_MEMBER_FILTER_OWNER'),
                            onPressed: () {
                              setState(() {
                                filter = GroupMemberFilterType
                                    .V2TIM_GROUP_MEMBER_FILTER_OWNER;
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
                  child: Text('已选：$filter'),
                )
              ],
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 60,
                child: Text(
                  "nextSeq",
                  style: TextStyle(height: 1),
                ),
                alignment: Alignment.centerLeft,
              ),
              Expanded(
                child: Container(
                  height: 60,
                  child: Text(
                    nextSeq.toString(),
                    style: TextStyle(
                      height: 1,
                      textBaseline: TextBaseline.ideographic,
                    ),
                  ),
                  margin: EdgeInsets.only(left: 12),
                  alignment: Alignment.centerLeft,
                ),
              )
            ],
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: getGroupMemberList,
                  child: Text("获取群成员列表"),
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
