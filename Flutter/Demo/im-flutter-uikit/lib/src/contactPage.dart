import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tim_ui_kit/ui/utils/color.dart';
import 'package:timuikit/i18n/i18n_utils.dart';
import 'package:timuikit/src/provider/theme.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<DefaultThemeData>(context).theme;
    return Scaffold(
        appBar: AppBar(
          iconTheme: const IconThemeData(
            color: Colors.white,
          ),
          shadowColor: theme.weakDividerColor,
          elevation: 1,
          title: Text(
            imt("联系我们"),
            style: const TextStyle(color: Colors.white),
          ),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                theme.lightPrimaryColor ?? CommonColor.lightPrimaryColor,
                theme.primaryColor ?? CommonColor.primaryColor
              ]),
            ),
          ),
        ),
        body: Center(
            child: Column(
          children: [
            Text(
              imt("反馈及建议可以加入QQ群：788910197"),
              style: TextStyle(
                color: theme.darkTextColor,
              ),
            ),
            Text(
              imt("在线时间，周一到周五，早上10点 - 晚上8点"),
              style: TextStyle(
                color: theme.darkTextColor,
              ),
            )
          ],
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
        )));
  }
}
