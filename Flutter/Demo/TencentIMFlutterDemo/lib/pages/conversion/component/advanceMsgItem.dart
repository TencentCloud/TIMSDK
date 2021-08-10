import 'package:flutter/material.dart';
import 'package:tencent_im_sdk_plugin_example/common/colors.dart';
import 'package:tencent_im_sdk_plugin_example/pages/conversion/dataInterface/advanceMsgList.dart';

class AdvanceMsgItem extends StatelessWidget {
  onPressed() {
    list.onPressed();
  }

  final AdvanceMsgList list;
  AdvanceMsgItem(this.list);

  @override
  Widget build(BuildContext context) {
    return PhysicalModel(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: list.icon,
                onPressed: onPressed,
              ),
            ),
            Container(
              child: Text(
                list.name,
                style: TextStyle(
                  fontSize: 12,
                  color: CommonColors.getTextWeakColor(),
                ),
              ),
            )
          ],
        ));
  }
}
