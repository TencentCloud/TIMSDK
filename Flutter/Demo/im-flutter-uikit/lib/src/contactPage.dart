import 'package:flutter/material.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';

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
          title: Text(
            imt("联系我们"),
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: hexToColor("EBF0F6"),
        ),
        body: Center(
            child: Column(
          children: [
            Text(
              imt("反馈及建议可以加入QQ群：788910197"),
              style: TextStyle(
                color: hexToColor("999999"),
              ),
            ),
            Text(
              imt("在线时间，周一到周五，早上10点 - 晚上8点"),
              style: TextStyle(
                color: hexToColor("999999"),
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        )));
  }
}
