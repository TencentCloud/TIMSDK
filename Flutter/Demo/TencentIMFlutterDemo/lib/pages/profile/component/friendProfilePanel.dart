import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:tencent_im_sdk_plugin_example/common/avatar.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

class FriendProfilePanel extends StatelessWidget {
  FriendProfilePanel(this.userInfo, this.isSelf);
  final V2TimFriendInfoResult? userInfo;
  final bool isSelf;
  getSelfSignature() {
    if (userInfo!.friendInfo!.userProfile!.selfSignature == '' ||
        userInfo!.friendInfo!.userProfile!.selfSignature == null) {
      return "";
    } else {
      return userInfo!.friendInfo!.userProfile!.selfSignature;
    }
  }

  hasNickName() {
    return !(userInfo!.friendInfo!.userProfile!.nickName == '' ||
        userInfo!.friendInfo!.userProfile!.nickName == null);
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return Container(
        height: 112,
      );
    }

    return Container(
      height: 112,
      padding: EdgeInsets.all(16),
      color: CommonColors.getWitheColor(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 80,
            child: Avatar(
              avtarUrl: userInfo!.friendInfo!.userProfile!.faceUrl == null ||
                      userInfo!.friendInfo!.userProfile!.faceUrl == ''
                  ? 'images/logo.png'
                  : userInfo!.friendInfo!.userProfile!.faceUrl,
              width: 80,
              height: 80,
              radius: 9.6,
            ),
          ),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 昵称
                  Container(
                    height: 34,
                    child: Text(
                      (userInfo!.friendInfo!.userProfile!.nickName == null ||
                              userInfo!.friendInfo!.userProfile!.nickName == '')
                          ? "${userInfo!.friendInfo!.userProfile!.userID}"
                          : "${userInfo!.friendInfo!.userProfile!.nickName}",
                      style: TextStyle(
                        fontSize: 24,
                        color: CommonColors.getTextBasicColor(),
                      ),
                    ),
                  ),
                  Container(
                    height: 23,
                    child: Text(
                      '用户ID：${userInfo!.friendInfo!.userProfile!.userID}',
                      style: TextStyle(
                        fontSize: 14,
                        color: CommonColors.getTextWeakColor(),
                      ),
                    ),
                  ),
                  !isSelf
                      ? Container(
                          height: 23,
                          child: Text(
                            '个性签名：${getSelfSignature()}',
                            style: TextStyle(
                              fontSize: 14,
                              color: CommonColors.getTextWeakColor(),
                            ),
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
