import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/groupMemberSelector.dart';
import 'package:im_api_example/im/groupSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/group_member_role.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class SetGroupMemberRole extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => SetGroupMemberRoleState();
}

class SetGroupMemberRoleState extends State<SetGroupMemberRole> {
  Map<String, dynamic>? resData;
  List<String> group = List.empty(growable: true);
  List<String> memberList = List.empty(growable: true);
  int role = GroupMemberRoleType.V2TIM_GROUP_MEMBER_ROLE_MEMBER;
  setGroupMemberRole() async {
    V2TimCallback res = await TencentImSDKPlugin.v2TIMManager
        .getGroupManager()
        .setGroupMemberRole(
          groupID: group.first,
          userID: memberList.first, //注意：选择器没做单选，所以这里选第一个
          role: role,
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
          Row(
            children: [
              GroupMemberSelector(
                group.isNotEmpty ? group.first : "",
                memberList,
                (data) {
                  setState(() {
                    memberList = data;
                  });
                },
              ),
              Expanded(
                  child: Container(
                margin: EdgeInsets.only(left: 12),
                child: Text(memberList.toString()),
              ))
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
                        title: const Text('群角色'),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('V2TIM_GROUP_MEMBER_ROLE_ADMIN'),
                            onPressed: () {
                              setState(() {
                                role = GroupMemberRoleType
                                    .V2TIM_GROUP_MEMBER_ROLE_ADMIN;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_GROUP_MEMBER_ROLE_MEMBER'),
                            onPressed: () {
                              setState(() {
                                role = GroupMemberRoleType
                                    .V2TIM_GROUP_MEMBER_ROLE_MEMBER;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_GROUP_MEMBER_ROLE_OWNER'),
                            onPressed: () {
                              setState(() {
                                role = GroupMemberRoleType
                                    .V2TIM_GROUP_MEMBER_ROLE_OWNER;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('V2TIM_GROUP_MEMBER_UNDEFINED'),
                            onPressed: () {
                              setState(() {
                                role = GroupMemberRoleType
                                    .V2TIM_GROUP_MEMBER_UNDEFINED;
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
                    child: Text("选择群角色"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text('已选：$role'),
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: setGroupMemberRole,
                  child: Text("设置群成员角色"),
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
