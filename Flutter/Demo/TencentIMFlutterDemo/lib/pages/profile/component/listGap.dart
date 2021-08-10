import 'package:flutter/cupertino.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';

class ListGap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 8,
      color: CommonColors.getGapColor(),
    );
  }
}
