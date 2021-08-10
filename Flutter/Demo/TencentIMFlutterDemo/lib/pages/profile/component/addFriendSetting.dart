import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/TextWithCommonStyle.dart';
import 'package:tencent_im_sdk_plugin_example/utils/toast.dart';

class AddFriendSetting extends StatefulWidget {
  AddFriendSetting(this.userInfo);
  final V2TimUserFullInfo userInfo;
  State<StatefulWidget> createState() => AddFriendSettingState();
}

class AddFriendSettingState extends State<AddFriendSetting> {
  bool? status;
  V2TimUserFullInfo? userInfo;

  void initState() {
    userInfo = widget.userInfo;
    status = widget.userInfo.allowType == 1 ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
      // color: Colors.green,
      child: Row(
        children: [
          TextWithCommonStyle(
            text: "加我为朋友时需要验证",
          ),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CupertinoSwitch(
                  value: status!,
                  onChanged: (data) async {
                    V2TimCallback res =
                        await TencentImSDKPlugin.v2TIMManager.setSelfInfo(
                      userFullInfo: V2TimUserFullInfo.fromJson(
                        {
                          "allowType": data ? 1 : 0,
                        },
                      ),
                    );
                    Utils.toast("修改成功");
                    if (res.code == 0) {
                      setState(() {
                        status = !status!;
                      });
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
