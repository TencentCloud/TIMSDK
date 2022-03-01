import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin/models/v2_tim_group_tips_elem.dart';
import 'package:tim_ui_kit/ui/utils/message.dart';

class TIMUIKitGroupTipsElem extends StatelessWidget {
  final V2TimGroupTipsElem groupTipsElem;

  const TIMUIKitGroupTipsElem({Key? key, required this.groupTipsElem})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final groupTipsAbstactText =
        MessageUtils.groupTipsMessageAbstract(groupTipsElem, context);
    return Text(
      groupTipsAbstactText,
      textAlign: TextAlign.center,
    );
  }
}
