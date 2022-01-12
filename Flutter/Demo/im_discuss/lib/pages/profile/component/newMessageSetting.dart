import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/profile/component/TextWithCommonStyle.dart';

class NewMessageSetting extends StatefulWidget {
  const NewMessageSetting(this.userInfo, {Key? key}) : super(key: key);
  final V2TimUserFullInfo userInfo;
  @override
  State<StatefulWidget> createState() => NewMessageSettingState();
}

class NewMessageSettingState extends State<NewMessageSetting> {
  bool status = true;
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 55,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: BoxDecoration(
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
          const TextWithCommonStyle(
            "新消息通知",
          ),
          Expanded(
            child: Row(
              textDirection: TextDirection.rtl,
              children: [
                CupertinoSwitch(
                  value: status,
                  onChanged: (data) {
                    setState(() {
                      status = !status;
                    });
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
