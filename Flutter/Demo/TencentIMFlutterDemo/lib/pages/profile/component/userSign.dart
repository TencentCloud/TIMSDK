import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_user_full_info.dart';
import 'package:tencent_im_sdk_plugin_example/common/arrowRight.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/profile/component/textWithCommonStyle.dart';
import 'package:tencent_im_sdk_plugin_example/pages/selfSign/selfSign.dart';

class UserSign extends StatelessWidget {
  UserSign(this.userInfo);
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
              new MaterialPageRoute(
                builder: (context) => SelfSign(),
              ),
            );
          },
          child: Container(
            height: 55,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Row(
              children: [
                TextWithCommonStyle(
                  text: '个性签名',
                ),
                Expanded(
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ArrowRight(),
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
