import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_callback.dart';
import 'package:tencent_im_sdk_plugin/tencent_im_sdk_plugin.dart';
import 'package:tencent_im_sdk_plugin_example/common/arrowRight.dart';
import 'package:tencent_im_sdk_plugin_example/pages/login/login.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/TextWithCommonStyle.dart';
import 'package:tencent_im_sdk_plugin_example/provider/conversion.dart';
import 'package:tencent_im_sdk_plugin_example/provider/currentMessageList.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friend.dart';
import 'package:tencent_im_sdk_plugin_example/provider/friendApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/groupApplication.dart';
import 'package:tencent_im_sdk_plugin_example/provider/user.dart';

class Logout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        V2TimCallback res = await TencentImSDKPlugin.v2TIMManager.logout();
        // 去掉provider里面的所有东西

        if (res.code == 0) {
          try {
            Provider.of<ConversionModel>(context, listen: false).clear();
            Provider.of<UserModel>(context, listen: false).clear();
            Provider.of<CurrentMessageListModel>(context, listen: false)
                .clear();
            Provider.of<FriendListModel>(context, listen: false).clear();
            Provider.of<FriendApplicationModel>(context, listen: false).clear();
            Provider.of<GroupApplicationModel>(context, listen: false).clear();
            // 去掉存的一些数据
            Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
            SharedPreferences prefs = await _prefs;
            prefs.remove('token');
            prefs.remove('sessionId');
            prefs.remove('phone');
            prefs.remove('code');
          } catch (err) {
            print("someError");
            print(err);
          }
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (BuildContext context) => LoginPage()),
            ModalRoute.withName('/'),
          );
        }
      },
      child: Container(
        height: 55,
        padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
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
            TextWithCommonStyle(
              text: "退出登录",
            ),
            Expanded(
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  ArrowRight(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
