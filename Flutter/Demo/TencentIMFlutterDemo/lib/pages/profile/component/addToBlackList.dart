import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_operation_result.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_value_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/TextWithCommonStyle.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class AddToBlackList extends StatefulWidget {
  AddToBlackList(this.userInfo);
  final V2TimFriendInfoResult userInfo;
  State<StatefulWidget> createState() => AddToBlackListState();
}

class AddToBlackListState extends State<AddToBlackList> {
  void initState() {
    super.initState();
  }

  bool status = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
        color: CommonColors.getWitheColor(),
        border: Border(
          bottom: BorderSide(
            color: Color(int.parse('ededed', radix: 16)).withAlpha(255),
            width: 1,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Row(
        children: [
          TextWithCommonStyle(
            text: "加入黑名单",
          ),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CupertinoSwitch(
                  value: status,
                  onChanged: (data) async {
                    setState(() {
                      status = !status;
                    });
                    if (status) {
                      V2TimValueCallback<List<V2TimFriendOperationResult>> res =
                          await TencentImSDKPlugin.v2TIMManager
                              .getFriendshipManager()
                              .addToBlackList(userIDList: [
                        widget.userInfo.friendInfo!.userID
                      ]);
                      if (res.code == 0) {
                        List<V2TimFriendOperationResult>? opres = res.data;
                        print("黑名单返回${opres![0].resultCode}");
                        if (opres[0].resultCode == 0) {
                          Utils.toast("操作成功");
                        } else {
                          Utils.toast("操作失败");
                        }
                      }
                    } else {
                      V2TimValueCallback<List<V2TimFriendOperationResult>> res =
                          await TencentImSDKPlugin.v2TIMManager
                              .getFriendshipManager()
                              .deleteFromBlackList(userIDList: [
                        widget.userInfo.friendInfo!.userID
                      ]);
                      if (res.code == 0) {
                        List<V2TimFriendOperationResult>? opres = res.data;
                        print("黑名单返回${opres![0].resultCode}");
                        if (opres[0].resultCode == 0) {
                          Utils.toast("操作成功");
                        } else {
                          Utils.toast("操作失败");
                        }
                      }
                    }
                  },
                  activeColor: CommonColors.getThemeColor(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
