import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_friend_info_result.dart';
import 'package:discuss/common/arrowright.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/profile/component/textwithcommonstyle.dart';
import 'package:discuss/pages/userNick/userNick.dart';

class UserRemark extends StatelessWidget {
  const UserRemark(this.userInfo, this.getUserInfo, {Key? key})
      : super(key: key);
  final V2TimFriendInfoResult? userInfo;
  final Function getUserInfo;
  getNickName() {
    if (userInfo!.friendInfo!.friendRemark == '' ||
        userInfo!.friendInfo!.friendRemark == null) {
      return '暂无备注';
    } else {
      return userInfo!.friendInfo!.friendRemark;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userInfo == null) {
      return Container();
    }
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => UserNick(userInfo!, getUserInfo),
              ),
            );
          },
          child: Container(
            height: 55,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                const TextWithCommonStyle("备注"),
                Expanded(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ArrowRight(),
                      Expanded(
                        child: Text(
                          getNickName(),
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 14,
                            color: CommonColors.getTextWeakColor(),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
