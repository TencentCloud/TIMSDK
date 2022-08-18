import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:example/im/friendSelector.dart';
import 'package:example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type_enum.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_check_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:example/i18n/i18n_utils.dart';

class CheckFriend extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CheckFriendState();
}

class CheckFriendState extends State<CheckFriend> {
  List<String> users = List.empty(growable: true);
  String? friendRemark;
  Map<String, dynamic>? resData;
  FriendTypeEnum checkType = FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH;
  checkFriend() async {
    V2TimValueCallback<List<V2TimFriendCheckResult>> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .checkFriend(
              userIDList: users,
              checkType: checkType,
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
              FriendSelector(
                onSelect: (data) {
                  setState(() {
                    users = data;
                  });
                },
                switchSelectType: false,
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
                        title: Text(imt("检测类型")),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: Text(imt("双向好友")),
                            onPressed: () {
                              setState(() {
                                checkType =
                                    FriendTypeEnum.V2TIM_FRIEND_TYPE_BOTH;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: Text(imt("单向好友")),
                            onPressed: () {
                              setState(() {
                                checkType =
                                    FriendTypeEnum.V2TIM_FRIEND_TYPE_SINGLE;
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
                    child: Text(imt("选择检测类型")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text("已选：$checkType"),
                )
              ],
            ),
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: checkFriend,
                  child: Text(imt("检测好友")),
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
