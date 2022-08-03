// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';
import 'package:timuikit/src/user_profile.dart';

class BlackList extends StatelessWidget {
  const BlackList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
      appBar: AppBar(
          title: Text(
            imt("黑名单"),
            style: const TextStyle(color: Colors.white, fontSize: 17),
          ),
          shadowColor: Colors.white,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
          iconTheme: const IconThemeData(
            color: Colors.white,
          )),
      body: TIMUIKitBlackList(
        emptyBuilder: (_) {
          return Center(
            child: Text(imt("暂无黑名单")),
          );
        },
        onTapItem: (V2TimFriendInfo friendInfo) {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserProfile(userID: friendInfo.userID),
              ));
        },
      ),
    );
  }
}
