import 'package:adaptive_action_sheet/adaptive_action_sheet.dart';
import 'package:flutter/material.dart';
import 'package:im_api_example/im/friendApplicationSelector.dart';
import 'package:im_api_example/utils/sdkResponse.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_application_type_enum.dart';
import 'package:tencent_im_sdk_plugin/enum/friend_type.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:im_api_example/i18n/i18n_utils.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';

class RefuseFriendApplication extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => RefuseFriendApplicationState();
}

class RefuseFriendApplicationState extends State<RefuseFriendApplication> {
  List<String> users = List.empty(growable: true);
  String? friendRemark;
  Map<String, dynamic>? resData;
  FriendApplicationTypeEnum acceptType =
      FriendApplicationTypeEnum.V2TIM_FRIEND_APPLICATION_COME_IN;
  deleteFromFriendList() async {
    V2TimValueCallback<V2TimFriendOperationResult> res =
        await TencentImSDKPlugin.v2TIMManager
            .getFriendshipManager()
            .refuseFriendApplication(userID: users[0], type: acceptType);

    setState(() {
      resData = res.toJson();
    });
  }

  @override
  Widget build(BuildContext context) {
    String chooseType = (acceptType == FriendApplicationType.V2TIM_FRIEND_APPLICATION_COME_IN ? imt("别人发给我的") : imt("我发别人的"));
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
                        title: Text(imt("请求类型类型")),
                        actions: <BottomSheetAction>[
                          BottomSheetAction(
                            title: Text(imt("别人发给我的加好友请求")),
                            onPressed: () {
                              setState(() {
                                acceptType = FriendApplicationTypeEnum
                                    .V2TIM_FRIEND_APPLICATION_COME_IN;
                              });
                              Navigator.pop(context);
                            },
                          ),
                          BottomSheetAction(
                            title: Text(imt("我发给别人的加好友请求")),
                            onPressed: () {
                              setState(() {
                                acceptType = FriendApplicationTypeEnum
                                    .V2TIM_FRIEND_APPLICATION_SEND_OUT;
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
                    child: Text(imt("选择类型")),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(left: 12),
                  child: Text(
                      imt_para("已选：{{chooseType}}", "已选：$chooseType")(chooseType: chooseType)),
                )
              ],
            ),
          ),
          new Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: deleteFromFriendList,
                  child: Text(imt("拒绝申请")),
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
