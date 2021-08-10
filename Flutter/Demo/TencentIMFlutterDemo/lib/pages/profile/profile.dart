import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/addFriendSetting.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/blog.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/buy.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/listGap.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/logout.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/profilePanel.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/privacy.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/exonerate.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/testApi.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/userSign.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/contact.dart';
import 'package:tencent_im_sdk_plugin_example/provider/user.dart';

class Profile extends StatefulWidget {
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  int type = 0; // 0 1 2,0=>自己打开个人中心，1=>单聊资料卡，2=>群聊资料卡

  Widget build(BuildContext context) {
    V2TimUserFullInfo? info = Provider.of<UserModel>(context).info;
    // print("个人信息${info.toJson()}");
    if (info == null) {
      return Container();
    }

    return ListView(
      children: [
        ProfilePanel(info, true),
        ListGap(),
        UserSign(info),
        ListGap(),
        // if (type == 0) NewMessageSetting(info),
        if (type == 0) AddFriendSetting(info),
        if (type == 0) ListGap(),
        if (type == 0) Blog(),
        if (type == 0) Buy(),
        if (type == 0) ListGap(),
        Privacy(),
        Exonerate(),
        if (type == 0) ListGap(),
        TestApiList(),
        if (type == 0) Contact(),
        if (type == 0) Logout(),
      ],
    );
  }
}
