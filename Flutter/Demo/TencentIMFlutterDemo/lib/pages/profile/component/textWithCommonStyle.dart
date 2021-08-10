import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

class TextWithCommonStyle extends StatelessWidget {
  late String? text;
  TextWithCommonStyle({text}) {
    this.text = text;
  }
  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      style: TextStyle(
        color: CommonColors.getTextBasicColor(),
        fontSize: 18,
      ),
    );
  }
}
