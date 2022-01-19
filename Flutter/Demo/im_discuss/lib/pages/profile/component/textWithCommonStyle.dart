import 'package:flutter/material.dart';
import 'package:discuss/common/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextWithCommonStyle extends StatelessWidget {
  const TextWithCommonStyle(
    this.text, {
    Key? key,
  }) : super(key: key);
  final String? text;
  @override
  Widget build(BuildContext context) {
    return Text(
      text!,
      style: TextStyle(
        color: CommonColors.getTextBasicColor(),
        fontSize: ScreenUtil().setSp(32),
      ),
    );
  }
}
