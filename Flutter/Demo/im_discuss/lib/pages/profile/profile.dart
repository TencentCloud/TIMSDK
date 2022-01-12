import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:discuss/pages/profile/component/addfriendsetting.dart';
import 'package:discuss/pages/profile/component/blog.dart';
import 'package:discuss/pages/profile/component/listgap.dart';
import 'package:discuss/pages/profile/component/logout.dart';
import 'package:discuss/pages/profile/component/profilepanel.dart';
import 'package:discuss/pages/profile/component/privacy.dart';
import 'package:discuss/pages/profile/component/exonerate.dart';
import 'package:discuss/pages/profile/component/usersign.dart';
import 'package:discuss/pages/profile/component/contact.dart';
import 'package:discuss/provider/user.dart';

class Profile extends StatefulWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ProfileState();
}

class ProfileState extends State<Profile> {
  int type = 0; // 0 1 2,0=>自己打开个人中心，1=>单聊资料卡，2=>群聊资料卡

  @override
  Widget build(BuildContext context) {
    V2TimUserFullInfo? info = Provider.of<UserModel>(context).info;
    // Utils.log("个人信息${info.toJson()}");
    if (info == null) {
      return Container();
    }

    return ListView(
      children: [
        ProfilePanel(info, true),
        const ListGap(),
        UserSign(info),
        const ListGap(),
        if (type == 0) AddFriendSetting(info),
        if (type == 0) const ListGap(),
        if (type == 0) const Blog(),
        if (type == 0) const ListGap(),
        const Privacy(),
        const Exonerate(),
        if (type == 0) const ListGap(),
        if (type == 0) const Contact(),
        if (type == 0) const Logout(),
      ],
    );
  }
}
