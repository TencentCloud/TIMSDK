import 'package:discuss/common/hextocolor.dart';
import 'package:flutter/material.dart';
import 'package:discuss/common/colors.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
          shadowColor: hexToColor("ececec"),
          elevation: 1,
          title: const Text(
            "联系我们",
            style: TextStyle(color: Colors.black),
          ),
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
