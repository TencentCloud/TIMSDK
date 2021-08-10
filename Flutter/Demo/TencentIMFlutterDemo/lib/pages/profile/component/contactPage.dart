import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

class ContactPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("联系我们"),
          backgroundColor: CommonColors.getThemeColor(),
        ),
        body: Center(
            child: Column(
          children: [
            Text(
              "反馈及建议可以加入QQ群：788910197",
              style: TextStyle(
                color: CommonColors.getTextWeakColor(),
              ),
            ),
            Text(
              "在线时间，周一到周五，早上10点 - 晚上8点",
              style: TextStyle(
                color: CommonColors.getTextWeakColor(),
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        )));
  }
}
