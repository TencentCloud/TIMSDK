import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class AddFriend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AddFriendState();
}

class AddFriendState extends State<AddFriend> {
  Map<String, dynamic>? resData;
  String userID = '';
  String? remark;
  String? friendGroup;
  String addWording = '';
  String addSource = 'flutter';
  int addType = FriendType.V2TIM_FRIEND_TYPE_BOTH;
  List<String> receiver = List.empty(growable: true);
  List<String> groupID = List.empty(growable: true);
  int priority = 0;
  bool onlineUserOnly = false;
  bool isExcludedFromUnreadCount = false;
  addFriend() async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager.getFriendshipManager().addFriend(
              userID: userID,
              addType: addType,
              remark: remark,
              friendGroup: friendGroup,
              addWording: addWording,
              addSource: addSource,
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
                    labelText: "被添加好友ID",
                    hintText: "被添加好友ID",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      userID = res;
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
                    labelText: "好友备注",
                    hintText: "好友备注",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      remark = res;
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
                    labelText: "好友分组",
                    hintText: "好友分组，首先得有这个分组",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      friendGroup = res;
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
                    labelText: "添加简述",
                    hintText: "添加简述",
                    prefixIcon: Icon(Icons.person),
                  ),
                  onChanged: (res) {
                    setState(() {
                      addWording = res;
                    });
                  },
                ),
              ),
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
                        title: const Text('好友类型'),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('双向好友'),
                            onPressed: () {
                              setState(() {
                                addType = FriendType.V2TIM_FRIEND_TYPE_BOTH;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('单向好友'),
                            onPressed: () {
                              setState(() {
                                addType = FriendType.V2TIM_FRIEND_TYPE_SINGLE;
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
                  child: Text('已选：$addType'),
                )
              ],
            ),
          ),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: addFriend,
                  child: Text("添加好友"),
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
