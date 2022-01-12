import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:discuss/common/arrowright.dart';
import 'package:discuss/common/colors.dart';
import 'package:discuss/pages/profile/component/textwithcommonstyle.dart';
import 'package:discuss/pages/selfSign/selfSign.dart';

class UserSign extends StatelessWidget {
  const UserSign(this.userInfo, {Key? key}) : super(key: key);
  final V2TimUserFullInfo userInfo;
  getSelfSignature() {
    if (userInfo.selfSignature == '' || userInfo.selfSignature == null) {
      return '暂无签名';
    } else {
      return userInfo.selfSignature;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Ink(
        color: CommonColors.getWitheColor(),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SelfSign(),
              ),
            );
          },
          child: Container(
            height: 50,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                const TextWithCommonStyle("个性签名"),
                Expanded(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const ArrowRight(),
                      Expanded(
                        child: Text(
                          getSelfSignature(),
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
