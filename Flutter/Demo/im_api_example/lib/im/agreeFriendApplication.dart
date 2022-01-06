import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendApplicationSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_response_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class AgreeFriendApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => AgreeFriendApplicationState();
}

class AgreeFriendApplicationState extends State<AgreeFriendApplication> {
  List<String> users = List.empty(growable: true);
  String? friendRemark;
  Map<String, dynamic>? resData;
  FriendResponseTypeEnum acceptType =
      FriendResponseTypeEnum.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD;
  deleteFromFriendList() async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .acceptFriendApplication(
                userID: users[0],
                responseType: acceptType,
                type: FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_BOTH);

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
              FriendApplicationSelector(
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
                  child: Text(users.length > 0 ? users.toString() : "未选择"),
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
                        title: const Text('删除类型'),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: const Text('同意添加双向好友'),
                            onPressed: () {
                              setState(() {
                                acceptType = FriendResponseTypeEnum
                                    .V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: const Text('同意添加单向好友'),
                            onPressed: () {
                              setState(() {
                                acceptType = FriendResponseTypeEnum
                                    .V2TIM_FRIEND_ACCEPT_AGREE;
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
                    child: Text("选择同意类型类型"),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text(
                      '已选：${acceptType == FriendApplicationType.V2TIM_FRIEND_ACCEPT_AGREE_AND_ADD ? "双向好友" : "单项好友"}'),
                )
              ],
            ),
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteFromFriendList,
                  child: Text("同意申请"),
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
