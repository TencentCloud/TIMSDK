import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/profile/component/TextWithCommonStyle.dart';
import 'package:discuss/utils/toast.dart';

class AddFriendSetting extends StatefulWidget {
  const AddFriendSetting(this.userInfo, {Key? key}) : super(key: key);
  final V2TimUserFullInfo userInfo;
  @override
  State<StatefulWidget> createState() => AddFriendSettingState();
}

class AddFriendSettingState extends State<AddFriendSetting> {
  bool? status;
  V2TimUserFullInfo? userInfo;

  @override
  void initState() {
    userInfo = widget.userInfo;
    status = widget.userInfo.allowType == 1 ? true : false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      // color: Colors.green,
      child: Row(
        children: [
          const TextWithCommonStyle(
            "加我为朋友时需要验证",
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
