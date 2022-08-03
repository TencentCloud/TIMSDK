// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:tim_ui_kit/tim_ui_kit.dart';

class TIMUIKitAddFriendExample extends StatelessWidget {
  const TIMUIKitAddFriendExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TIMUIKitAddFriend(onTapAlreadyFriendsItem: (String userID) {
    });
  }
}
